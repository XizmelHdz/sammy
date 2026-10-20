import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_colors.dart';
import 'presentation/login/login_screen.dart';

class SammyApp extends StatelessWidget {
  const SammyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Detalles Sammy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.hotPink,
        scaffoldBackgroundColor: const Color(0xFFFFF3F8),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.hotPink),
        textTheme: GoogleFonts.nunitoTextTheme(),
      ),
      home: const LoginScreen(),
    );
  }
}
