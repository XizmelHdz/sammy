import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/app_text_field_style.dart';
import '../../core/widgets/auth_card.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/gradient_button.dart';
import '../../domain/entities/usuario.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;

  /// Ajuste de IP dinámico: 10.0.2.2 para emuladores Android.
  /// ⚠️ Cambia el puerto (3000) por el que use tu server.js.
  String get hostUrl =>
      (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
          ? 'http://10.0.2.2:3000'
          : 'http://localhost:3000';

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final String nombre = _nombreController.text.trim();
    final String correo = _correoController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirm = _confirmController.text.trim();

    // Validaciones en cliente
    if (nombre.isEmpty ||
        correo.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty) {
      setState(() => _errorMessage = 'Por favor, completa todos los campos.');
      return;
    }

    if (password != confirm) {
      setState(() => _errorMessage = 'Las contraseñas no coinciden.');
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final Uri url = Uri.parse('$hostUrl/api/register');
    debugPrint('POST -> $url');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'nombre': nombre,
              'correo': correo,
              'contrasena': password,
              'id_rol': 3, // rol "cliente" por defecto; ajusta si tu BD usa otros IDs
            }),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('STATUS -> ${response.statusCode}');
      debugPrint('BODY -> ${response.body}');

      final Map<String, dynamic> respuestaJson =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        // Devuelve un mensaje al LoginScreen (se muestra en el SuccessBanner)
        Navigator.pop(
          context,
          '¡Cuenta creada con éxito! Ya puedes iniciar sesión.',
        );
      } else {
        final String mensajeError =
            respuestaJson['message'] ?? 'No se pudo crear la cuenta.';
        setState(() => _errorMessage = mensajeError);
      }
    } catch (e, st) {
      debugPrint('ERROR REGISTER -> $e');
      debugPrint('STACK -> $st');
      setState(() => _errorMessage = 'Error de conexión: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, top: 4),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          appLogo(),
                          const SizedBox(height: 18),
                          Text(
                            'Crear cuenta',
                            style: GoogleFonts.fredoka(
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '🎁 Únete y arma tu regalo perfecto',
                            style: GoogleFonts.nunito(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.black.withOpacity(0.75),
                            ),
                          ),
                          const SizedBox(height: 24),
                          AuthCard(
                            child: Column(
                              children: [
                                TextField(
                                  controller: _nombreController,
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                  decoration: buildFieldDecoration(
                                    'Nombre completo',
                                    Icons.person_outline,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                TextField(
                                  controller: _correoController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                  decoration: buildFieldDecoration(
                                    'Correo',
                                    Icons.email_outlined,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                  decoration: buildFieldDecoration(
                                    'Contraseña',
                                    Icons.lock_outline,
                                    suffix: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: const Color(0xFFB05C82),
                                      ),
                                      onPressed: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                TextField(
                                  controller: _confirmController,
                                  obscureText: _obscureConfirm,
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                  decoration: buildFieldDecoration(
                                    'Confirmar contraseña',
                                    Icons.lock_outline,
                                    suffix: IconButton(
                                      icon: Icon(
                                        _obscureConfirm
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: const Color(0xFFB05C82),
                                      ),
                                      onPressed: () => setState(
                                        () => _obscureConfirm = !_obscureConfirm,
                                      ),
                                    ),
                                  ),
                                ),
                                ErrorBanner(message: _errorMessage),
                                const SizedBox(height: 20),
                                GradientButton(
                                  label: 'Crear cuenta',
                                  onPressed: _register,
                                  isLoading: _isLoading,
                                ),
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: RichText(
                                    text: TextSpan(
                                      style: GoogleFonts.nunito(
                                        fontSize: 14,
                                        color: AppColors.ink.withOpacity(0.65),
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: '¿Ya tienes cuenta? ',
                                        ),
                                        TextSpan(
                                          text: 'Inicia sesión',
                                          style: GoogleFonts.nunito(
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.hotPink,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}