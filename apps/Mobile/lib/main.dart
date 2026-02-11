import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:boostdrive_ui/boostdrive_ui.dart';
import 'auth_gate.dart';
import 'package:boostdrive_services/src/seed_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'web_utils.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Register reCAPTCHA container for Web
  WebUtils.registerViewFactory('recaptcha-container', 'recaptcha-container');
  

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://jpkkielcwlssmictmjrl.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impwa2tpZWxjd2xzc21pY3RtanJsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk4ODUzMTcsImV4cCI6MjA4NTQ2MTMxN30.sKkXhWmx0O6ZdszDRdzCYcz9hZPgxXJuDumzHlkCy8c',
  );
  
  runApp(
    const ProviderScope(
      child: BoostDriveMobileApp(),
    ),
  );
}

class BoostDriveMobileApp extends StatelessWidget {
  const BoostDriveMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BoostDrive',
      debugShowCheckedModeBanner: false,
      theme: BoostDriveTheme.darkTheme(context).copyWith(
        scaffoldBackgroundColor: const Color(0xCC0D0D0D), // Semi-transparent black to show background
      ),
      builder: (context, child) {
        return Stack(
          children: [
            // Global Background Image
            Positioned.fill(
              child: Image.asset(
                BoostDriveTheme.globalBackgroundImage,
                // package: 'boostdrive_ui', // Removed: Loading from local assets now
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  print("DEBUG: Error loading background: $error");
                  return Container(color: const Color(0xFF0D0D0D));
                },
              ),
            ),
            // App Content
            if (child != null) child,
          ],
        );
      },
      home: const AuthGate(),
    );
  }
}
