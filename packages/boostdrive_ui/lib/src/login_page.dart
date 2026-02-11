import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:boostdrive_auth/boostdrive_auth.dart';
import 'package:boostdrive_services/boostdrive_services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'login_widget.dart';
import 'theme.dart';
import 'role_selection_page.dart';
import 'reset_password_page.dart';

class BoostLoginPage extends ConsumerStatefulWidget {
  final VoidCallback? onLoginSuccess;

  const BoostLoginPage({super.key, this.onLoginSuccess});

  @override
  ConsumerState<BoostLoginPage> createState() => _BoostLoginPageState();
}

class _BoostLoginPageState extends ConsumerState<BoostLoginPage> {
  bool _isLoading = false;
  String? _errorText;
  String? _verificationId;
  String? _pendingName;
  String? _pendingRole;
  bool _isPasswordReset = false;

  String _getFriendlyErrorMessage(dynamic e) {
    if (e == null) return 'Unknown error occurred';
    final message = e.toString().toLowerCase();
    
    if (message.contains('invalid login credentials')) {
      return 'Invalid email or password. Please try again.';
    }
    if (message.contains('password should contain') || message.contains('weak_password')) {
      return 'Password is too weak. It must be at least 8 characters and include uppercase, lowercase, numbers, and symbols.';
    }
    if (message.contains('user already exists') || message.contains('already registered')) {
      return 'An account with this email already exists. Try logging in instead.';
    }
    if (message.contains('network') || message.contains('connection')) {
      return 'Poor network connection. Please check your internet.';
    }
    if (message.contains('otp') || message.contains('verification code')) {
      return 'Incorrect or expired verification code.';
    }
    
    // Fallback for other Supabase/Auth exceptions
    if (e is AuthException) {
      return e.message;
    }

    if (e is PostgrestException) {
      return 'Database error: ${e.message}';
    }
    
    final errStr = e.toString();
    if (errStr.length < 100) return errStr;
    
    return 'Something went wrong. Please try again later.';
  }

  void _login(String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      // Use signInWithUsernameOrEmail to handle both email and username inputs
      await authService.signInWithUsernameOrEmail(identifier: email, password: password);
      
      if (widget.onLoginSuccess != null) {
        _showSuccessDialog('Login Successful', 'Welcome back to BoostDrive!', onDismiss: widget.onLoginSuccess);
      } else if (mounted) {
        _showSuccessDialog('Login Successful', 'Welcome back to BoostDrive!', onDismiss: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorText = _getFriendlyErrorMessage(e);
          _isLoading = false;
        });
      }
    }
  }

  void _signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String role,
    String? username,
  }) async {
    setState(() {
      _isLoading = true;
      _errorText = null;
      _pendingName = fullName;
      _pendingRole = role;
    });

    try {
      final normalizedRole = role.toLowerCase().replaceAll(' ', '_');
      final userService = ref.read(userServiceProvider);
      final duplicateError = await userService.checkDuplicateAccount(
        email: email,
        phone: phone,
        role: normalizedRole,
      );

      if (duplicateError != null) {
        if (mounted) {
          setState(() {
            _errorText = duplicateError;
            _isLoading = false;
          });
        }
        return;
      }

      final authService = ref.read(authServiceProvider);
      await authService.signUpWithPhonePassword(
        phone: phone, 
        password: password,
        email: email,
        username: username,
      );
      
      if (mounted) {
        setState(() {
          _verificationId = phone; // Store phone for OTP verification
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorText = _getFriendlyErrorMessage(e);
          _isLoading = false;
        });
      }
    }
  }

  void _verifyOtp(String otp) async {
    if (_verificationId == null) return;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      // Try verifying via phone first since we switched sign-up to phone
      bool success = false;
      try {
        success = await authService.verifySmsCode(_verificationId!, otp);
      } catch (e) {
        // Fallback to email verification if phone fails (for legacy users)
        success = await authService.verifyEmailCode(_verificationId!, otp);
      }
      
      if (success) {
        if (_isPasswordReset) {
          if (mounted) {
            // Navigate to Reset Password Page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResetPasswordPage(
                  onPasswordChanged: () {
                    // Reset UI state
                    setState(() {
                      _verificationId = null;
                      _isPasswordReset = false;
                      _errorText = null;
                    });
                  },
                ),
              ),
            );
          }
          return;
        }

        final user = ref.read(currentUserProvider);
        if (user != null) {
          // Update profile with name
          if (_pendingName != null) {
            await authService.updateProfile(
              userId: user.id,
              fullName: _pendingName,
            );
          }
          
          // Update roles
          if (_pendingRole != null) {
            final normalizedRole = _pendingRole!.toLowerCase().replaceAll(' ', '_');
            final userSerivce = ref.read(userServiceProvider);
            bool isBuyer = normalizedRole == 'customer' || normalizedRole == 'vehicle_host';
            bool isSeller = normalizedRole == 'seller' || normalizedRole == 'service_pro';
            await userSerivce.updateRoles(
              uid: user.id,
              isBuyer: isBuyer,
              isSeller: isSeller,
              role: normalizedRole,
            );
          }
        }
        
        if (widget.onLoginSuccess != null) {
          _showSuccessDialog('Account Created', 'Your account has been successfully created.', onDismiss: widget.onLoginSuccess);
        } else if (mounted) {
          _showSuccessDialog('Account Created', 'Your account has been successfully created.', onDismiss: () {
             if (Navigator.canPop(context)) {
               Navigator.pop(context);
             }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorText = "Invalid verification code";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorText = _getFriendlyErrorMessage(e);
          _isLoading = false;
        });
      }
    }
  }

  void _resendCode() {
    if (_verificationId != null) {
      ref.read(authServiceProvider).signInWithEmail(
        email: _verificationId!,
        onCodeSent: (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Verification code resent!')),
            );
          }
        },
        onError: (e) => setState(() => _errorText = e),
      );
    }
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: BoostDriveTheme.backgroundDark,
        title: const Text('Reset Password', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your email address to receive a password reset link.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Email Address',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: BoostDriveTheme.primaryBlue),
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid email')),
                );
                return;
              }
              
              Navigator.pop(context); // Close dialog
              
              setState(() {
                _isLoading = true;
                _errorText = null;
              });

              try {
                await ref.read(authServiceProvider).sendPasswordResetOtp(email);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Verification code sent!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Switch to OTP view
                  setState(() {
                    _verificationId = email; // Using email as ID for OTP
                    _isPasswordReset = true;
                  });
                }
              } catch (e) {
                if (mounted) {
                  setState(() {
                    _errorText = _getFriendlyErrorMessage(e);
                  });
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  void _signInWithGoogle() async {
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      // On web, this will redirect away. On mobile, it might return.
      // If it returns successfully without redirecting (mobile), show success.
      if (!kIsWeb && mounted) {
         // Check if user is logged in
         final user = ref.read(currentUserProvider);
         if (user != null) {
            _showSuccessDialog('Login Successful', 'Successfully signed in with Google.');
         }
      }
    } catch (e) {
      if (mounted) setState(() => _errorText = _getFriendlyErrorMessage(e));
    }
  }

  void _signInWithApple() async {
    try {
      await ref.read(authServiceProvider).signInWithApple();
      if (!kIsWeb && mounted) {
         final user = ref.read(currentUserProvider);
         if (user != null) {
            _showSuccessDialog('Login Successful', 'Successfully signed in with Apple.');
         }
      }
    } catch (e) {
      if (mounted) setState(() => _errorText = _getFriendlyErrorMessage(e));
    }
  }

  void _showSuccessDialog(String title, String message, {VoidCallback? onDismiss}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: BoostDriveTheme.backgroundDark,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.green.withOpacity(0.5), width: 2)
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, style: const TextStyle(color: Colors.white70, fontSize: 16), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                        Navigator.pop(context);
                        if (onDismiss != null) onDismiss();
                    },
                    child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Allow global background to show if used in dialog
      body: Stack(
        children: [
          BoostLoginWidget(
            onLogin: _login,
            onSignUp: _signUp,
            onVerifyOtp: _verifyOtp,
            onResendOtp: _resendCode,
            onForgotPassword: _showForgotPasswordDialog,
            onGoogleSignIn: _signInWithGoogle,
            onAppleSignIn: _signInWithApple,
            isLoading: _isLoading,
            isOtpSent: _verificationId != null,
            errorText: _errorText,
          ),
          if (kIsWeb)
            const Positioned(
              top: 10,
              right: 10,
              child: SizedBox(
                height: 48,
                width: 48,
                child: HtmlElementView(viewType: 'recaptcha-container'),
              ),
            ),
        ],
      ),
    );
  }
}
