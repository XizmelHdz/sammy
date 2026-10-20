import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Mensaje de éxito (verde) mostrado tras un registro exitoso.
class SuccessBanner extends StatelessWidget {
  final String? message;
  const SuccessBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: message != null
          ? Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(color: const Color(0xFFE1F7EF), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: AppColors.teal, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(message!,
                          style: GoogleFonts.nunito(color: const Color(0xFF00806E), fontWeight: FontWeight.w700, fontSize: 13.5)),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
