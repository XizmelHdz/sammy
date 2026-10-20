import 'dart:convert';

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
import '../../core/widgets/success_banner.dart';

import '../home/home_screen.dart';
import '../register/register_screen.dart';
import '../../domain/entities/usuario.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  String? _successMessage;

  /// Ajuste de IP dinámico: 10.0.2.2 para emuladores Android.
  /// ⚠️ Cambia el puerto (3000) por el que use tu server.js.
  String get hostUrl =>
      (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
          ? 'http://10.0.2.2:3000'
          : 'http://localhost:3000';

  @override
  void dispose() {
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _intentarLogin() async {
    final String correo = _correoController.text.trim();
    final String password = _passwordController.text.trim();

    // 1. Validación en el cliente: campos vacíos
    if (correo.isEmpty || password.isEmpty) {
      _mostrarAlertaError('Por favor, ingresa tus datos completos.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final Uri url = Uri.parse('$hostUrl/api/login');
    debugPrint('POST -> $url');

    try {
      // 2. Petición POST con formato JSON
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'correo': correo,
              'contrasena': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('STATUS -> ${response.statusCode}');
      debugPrint('BODY -> ${response.body}');

      final Map<String, dynamic> respuestaJson =
          jsonDecode(response.body) as Map<String, dynamic>;

      // 3. Evaluar respuesta del servidor
      if (response.statusCode == 200 && respuestaJson['status'] == 'ok') {
        final datosUsuario =
            respuestaJson['usuario'] as Map<String, dynamic>;

        final Usuario usuarioValido = Usuario(
          id: datosUsuario['id_usuario'],
          nombre: datosUsuario['nombre'],
          correo: datosUsuario['correo'],
          rol: datosUsuario['rol'],
        );

        if (!mounted) return;

        // Destruye la pantalla de login del historial y redirige
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(usuario: usuarioValido),
          ),
        );
      } else {
        // Credenciales inválidas devueltas por PostgreSQL
        final String mensajeError =
            respuestaJson['message'] ?? 'Error al iniciar sesión.';
        _mostrarAlertaError(mensajeError);
      }
    } catch (e, st) {
      // ⚠️ Diagnóstico: muestra el error real en consola
      debugPrint('ERROR LOGIN -> $e');
      debugPrint('STACK -> $st');
      _mostrarAlertaError('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarAlertaError(String mensaje) {
    if (!mounted) return;
    setState(() => _errorMessage = mensaje);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.pinkAccent),
            SizedBox(width: 10),
            Text('Error de Acceso'),
          ],
        ),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _goToRegister() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
    if (result != null && result is String) {
      if (!mounted) return;
      setState(() {
        _successMessage = result;
        _errorMessage = null;
        _correoController.clear();
        _passwordController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  appLogo(),
                  const SizedBox(height: 20),
                  Text(
                    'Detalles Sammy',
                    style: GoogleFonts.fredoka(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '🎀 Inicia sesión para continuar',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black.withOpacity(0.75),
                    ),
                  ),
                  const SizedBox(height: 28),
                  AuthCard(
                    child: Column(
                      children: [
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
                        const SizedBox(height: 16),
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
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                        ),
                        ErrorBanner(message: _errorMessage),
                        SuccessBanner(message: _successMessage),
                        const SizedBox(height: 22),
                        GradientButton(
                          label: 'Entrar',
                          onPressed: _intentarLogin,
                          isLoading: _isLoading,
                        ),
                        const SizedBox(height: 18),
                        GestureDetector(
                          onTap: _goToRegister,
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                color: AppColors.ink.withOpacity(0.65),
                              ),
                              children: [
                                const TextSpan(text: '¿No tienes cuenta? '),
                                TextSpan(
                                  text: 'Regístrate',
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
                  const SizedBox(height: 24),
                  Text(
                    '✨ Regalos que sí aciertan ✨',
                    style: GoogleFonts.nunito(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Colors.black.withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}