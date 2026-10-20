import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Construye la decoración estándar (bordes, colores, ícono) para los
/// campos de texto de Login y Registro.
InputDecoration buildFieldDecoration(String label, IconData icon, {Widget? suffix}) {
  return InputDecoration(
    labelText: label,
    labelStyle: GoogleFonts.nunito(color: const Color(0xFFB05C82), fontWeight: FontWeight.w600),
    prefixIcon: Icon(icon, color: AppColors.hotPink),
    suffixIcon: suffix,
    filled: true,
    fillColor: AppColors.fieldBg,
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFFFC1DA), width: 1.6),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.hotPink, width: 2),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
  );
}
