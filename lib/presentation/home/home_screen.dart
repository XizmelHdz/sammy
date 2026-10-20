import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/entities/usuario.dart';

class HomeScreen extends StatelessWidget {
  final Usuario? usuario;
  const HomeScreen({super.key, this.usuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3F8),
      appBar: AppBar(
        title: Text('Detalles Sammy', style: GoogleFonts.fredoka(fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.hotPink,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          usuario != null
              ? '¡Bienvenida, ${usuario!.nombre}! 🎉'
              : '¡Bienvenida! Login exitoso 🎉',
          style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
        ),
      ),
    );
  }
}
