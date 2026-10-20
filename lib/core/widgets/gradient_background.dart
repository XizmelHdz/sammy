import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Fondo con degradado rosa y confeti decorativo, usado en Login y Registro.
class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6FA5),
            Color(0xFFFF8FB8),
            Color(0xFFFFF3F8),
          ],
          stops: [0.0, 0.28, 0.6],
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: 50, left: 30, child: _dot(14, AppColors.yellow)),
          Positioned(top: 100, right: 50, child: _dot(10, AppColors.teal)),
          Positioned(top: 40, right: 100, child: _dot(8, Colors.white)),
          Positioned(top: 180, left: 60, child: _dot(6, Colors.white)),
          Positioned(
            top: -50,
            right: -60,
            child: _decorCircle(160, AppColors.magenta.withOpacity(0.35)),
          ),
          Positioned(
            bottom: 40,
            left: -50,
            child: _decorCircle(130, AppColors.teal.withOpacity(0.18)),
          ),
          child,
        ],
      ),
    );
  }

  Widget _decorCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _dot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)],
      ),
    );
  }
}
