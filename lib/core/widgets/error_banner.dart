import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Mensaje de error con fondo e ícono, mostrado bajo los campos de un formulario.
class ErrorBanner extends StatelessWidget {
  final String? message;
  const ErrorBanner({super.key, required this.message});

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
                decoration: BoxDecoration(color: const Color(0xFFFFE0EC), borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(message!,
                          style: GoogleFonts.nunito(color: Colors.redAccent, fontWeight: FontWeight.w700, fontSize: 13.5)),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
