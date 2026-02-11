import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shop_home_page.dart';
import 'package:boostdrive_ui/boostdrive_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'web_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable runtime fetching so the app can download Outfit font from Google servers
  GoogleFonts.config.allowRuntimeFetching = true; 

  // Register the reCAPTCHA container once
  WebUtils.registerViewFactory('recaptcha-container', 'recaptcha-container');
  

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://jpkkielcwlssmictmjrl.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impwa2tpZWxjd2xzc21pY3RtanJsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk4ODUzMTcsImV4cCI6MjA4NTQ2MTMxN30.sKkXhWmx0O6ZdszDRdzCYcz9hZPgxXJuDumzHlkCy8c',
  );
  
  runApp(
    const ProviderScope(
      child: BoostDriveWebApp(),
    ),
  );
}

class BoostDriveWebApp extends StatelessWidget {
  const BoostDriveWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BoostDrive Shop',
      debugShowCheckedModeBanner: false,
      theme: BoostDriveTheme.darkTheme(context),
      home: const ShopHomePage(),
    );
  }
}
