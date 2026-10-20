import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Tarjeta blanca con sombra, usada como contenedor de los formularios
/// de Login y Registro.
class AuthCard extends StatelessWidget {
  final Widget child;
  const AuthCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.softPink, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.magenta.withOpacity(0.18),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}
