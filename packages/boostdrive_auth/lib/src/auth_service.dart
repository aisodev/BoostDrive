import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final supabaseAuthProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

class AuthService {
  final SupabaseClient _supabase;
  AuthService(this._supabase);

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Sends OTP to the phone number
  Future<void> signInWithPhone({
    required String phoneNumber,
    required Function(String code) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      String formatted = phoneNumber.trim();
      // Ensure phone number starts with +
      if (!formatted.startsWith('+')) {
        formatted = formatted.startsWith('0') ? '+264${formatted.substring(1)}' : '+264$formatted';
      }

      await _supabase.auth.signInWithOtp(
        phone: formatted,
      );
      
      // Supabase signals success if no error is thrown
      onCodeSent(formatted); 
    } catch (e) {
      print("DEBUG: Supabase Auth Error: $e");
      onError(e.toString());
    }
  }

  /// Sends OTP to the email address
  Future<void> signInWithEmail({
    required String email,
    required Function(String email) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      await _supabase.auth.signInWithOtp(
        email: email.trim(),
        shouldCreateUser: true,
      );
      onCodeSent(email.trim());
    } catch (e) {
      print("DEBUG: Supabase Email Auth Error: $e");
      onError(e.toString());
    }
  }

  /// Sends a password reset OTP (using signInWithOtp as proxy for recovery)
  Future<void> sendPasswordResetOtp(String email) async {
    try {
      await _supabase.auth.signInWithOtp(
        email: email.trim(),
        shouldCreateUser: false, // Don't create new users for password reset
      );
    } catch (e) {
      print("DEBUG: Password Reset OTP Error: $e");
      // Security: Don't reveal if user exists or not, but for now rethrow for debugging
      rethrow;
    }
  }

  /// Updates the user's password (requires authenticated session)
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      print("DEBUG: Update Password Error: $e");
      rethrow;
    }
  }


  Future<bool> signInWithGoogle() async {
    try {
      final res = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );
      return res;
    } catch (e) {
      print("DEBUG: Google Sign In Error: $e");
      rethrow;
    }
  }

  Future<bool> signInWithApple() async {
    try {
      final res = await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );
      return res;
    } catch (e) {
      print("DEBUG: Apple Sign In Error: $e");
      rethrow;
    }
  }

  /// New: Sign in with Email and Password
  Future<AuthResponse> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (response.user != null) {
        await _handlePostAuthSync(response.user!);
      }
      return response;
    } catch (e) {
      print("DEBUG: Supabase Login Error: $e");
      rethrow;
    }
  }


  /// Sign in with Email, Phone, or Username
  Future<AuthResponse> signInWithUsernameOrEmail({
    required String identifier,
    required String password,
  }) async {
    String loginIdentifier = identifier.trim();
    
    // Check if it's a phone number
    if (RegExp(r'^[0-9+]+$').hasMatch(loginIdentifier) && !loginIdentifier.contains('@')) {
       // It's a phone number
       // We can use signInWithPassword with phone if supported, 
       // but strictly speaking Supabase signInWithPassword takes email or phone.
       // Let's try passing it as phone to signInWithPassword if the SDK supports it,
       // otherwise we might need to use signInWithOtp for phone (which is what signInWithPhone does).
       // However, the user wants "Login with credentials", implying password.
       // Supabase `signInWithPassword` supports `phone`.
       return _supabase.auth.signInWithPassword(phone: _formatPhoneNumber(loginIdentifier), password: password);
    }

    // Check if it's a username (not email)
    if (!loginIdentifier.contains('@')) {
      try {
        final data = await _supabase
            .from('profiles')
            .select('email')
            .eq('username', loginIdentifier)
            .maybeSingle();
            
        if (data == null || data['email'] == null) {
          throw 'Username not found';
        }
        loginIdentifier = data['email'];
      } catch (e) {
        // If table doesn't exist or RLS issues, fall back to trying as email/phone or rethrow
        print("DEBUG: Username lookup failed: $e");
        rethrow;
      }
    }

    return signInWithEmailPassword(email: loginIdentifier, password: password);
  }

  /// Sign up with Phone and Password (triggers SMS verification)
  Future<AuthResponse> signUpWithPhonePassword({
    required String phone,
    required String password,
    String? email,
    String? username,
  }) async {
    try {
      String formatted = _formatPhoneNumber(phone);
      final Map<String, dynamic> data = {};
      if (email != null) data['email'] = email.trim();
      if (username != null) data['username'] = username.trim();

      final response = await _supabase.auth.signUp(
        phone: formatted,
        password: password,
        data: data.isNotEmpty ? data : null,
      );
      return response;
    } catch (e) {
      print("DEBUG: Supabase Phone SignUp Error: $e");
      rethrow;
    }
  }

  String _formatPhoneNumber(String phone) {
    // Remove all non-digit characters except the leading +
    String digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    String formatted = digits;
    
    if (formatted.startsWith('08')) {
      formatted = '264${formatted.substring(1)}';
    } else if (!formatted.startsWith('264')) {
      formatted = '264$formatted';
    }
    
    return '+$formatted';
  }

  /// Verifies the 6-digit OTP code (Phone)
  Future<bool> verifySmsCode(String phoneNumber, String token) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        phone: phoneNumber,
        token: token,
        type: OtpType.sms,
      );

      if (response.user != null) {
        try {
          await syncUserProfile(response.user!);
        } catch (syncError) {
          print("DEBUG: Profile sync failed (ignoring): $syncError");
        }
        return true;
      }
      return false;
    } catch (e) {
      print("DEBUG: OTP Verification Error: $e");
      rethrow;
    }
  }

  /// Verifies the 6-digit OTP code (Email)
  /// Tries both 'email' and 'signup' types to be robust across login/register flows.
  Future<bool> verifyEmailCode(String email, String token) async {
    try {
      print("DEBUG: Verifying Email OTP (type: email) for $email");
      final response = await _supabase.auth.verifyOTP(
        email: email.trim(),
        token: token,
        type: OtpType.email,
      );

      if (response.user != null) {
        await _handlePostAuthSync(response.user!);
        return true;
      }
      return false;
    } catch (e) {
      print("DEBUG: Email OTP Verification (type: email) failed: $e. Trying type: signup...");
      
      try {
        // Fallback for first-time signup verification
        final signupResponse = await _supabase.auth.verifyOTP(
          email: email.trim(),
          token: token,
          type: OtpType.signup,
        );

        if (signupResponse.user != null) {
          await _handlePostAuthSync(signupResponse.user!);
          return true;
        }
        return false;
      } catch (signupError) {
        print("DEBUG: Email OTP Verification (type: signup) also failed: $signupError");
        // Re-throw the original error if fallback also fails, 
        // unless the fallback error is more descriptive.
        rethrow;
      }
    }
  }

  Future<void> _handlePostAuthSync(User user) async {
    try {
      await syncUserProfile(user);
    } catch (syncError) {
      print("DEBUG: Profile sync failed (ignoring): $syncError");
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Syncs the user's basic info to Supabase profiles
  Future<void> syncUserProfile(User user) async {
    final Map<String, dynamic> updates = {
      'last_active': DateTime.now().toIso8601String(),
    };
    if (user.phone != null) updates['phone_number'] = user.phone!;
    if (user.email != null) updates['email'] = user.email!;
    
    // Check metadata for role and phone
    if (user.userMetadata != null) {
      if (user.userMetadata!['phone'] != null) {
        updates['phone_number'] = user.userMetadata!['phone'];
      }
      if (user.userMetadata!['email'] != null) {
        updates['email'] = user.userMetadata!['email'];
      }
      if (user.userMetadata!['username'] != null) {
        updates['username'] = user.userMetadata!['username'];
      }
      if (user.userMetadata!['role'] != null) {
        updates['role'] = user.userMetadata!['role'];
      }
    }
    
    // Default to customer if no role is set
    updates['role'] ??= 'customer';
    
    // Basic flags
    updates['is_buyer'] = true;

    await _supabase.from('profiles').upsert({'id': user.id, ...updates});
  }

  /// Updates specific profile fields (like full_name)
  Future<void> updateProfile({
    required String userId,
    String? fullName,
    String? avatarUrl,
    String? phoneNumber,
  }) async {
    final Map<String, dynamic> updates = {
      'last_active': DateTime.now().toIso8601String(),
    };
    if (fullName != null) updates['full_name'] = fullName;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (phoneNumber != null) updates['phone_number'] = phoneNumber;

    await _supabase.from('profiles').update(updates).eq('id', userId);
    print("DEBUG: Profile updated for $userId");
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(supabaseAuthProvider));
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseAuthProvider).auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(supabaseAuthProvider).auth.currentUser;
});
