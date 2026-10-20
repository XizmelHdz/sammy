import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Logo circular (oso 🐻 con anillo degradado) usado en Login y Registro.
Widget appLogo() {
  return Container(
    width: 96,
    height: 96,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(colors: [AppColors.yellow, AppColors.hotPink], begin: Alignment.topLeft, end: Alignment.bottomRight),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 24, offset: const Offset(0, 10))],
    ),
    padding: const EdgeInsets.all(4),
    child: Container(
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
      child: const Center(child: Text('🐻', style: TextStyle(fontSize: 42))),
    ),
  );
}
