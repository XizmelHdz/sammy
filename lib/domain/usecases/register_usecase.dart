import '../entities/usuario.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: crear una cuenta nueva. Valida los datos y delega al repositorio.
class RegisterUseCase {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  Future<Usuario> call({
    required String nombre,
    required String correo,
    required String password,
    required String confirmPassword,
  }) {
    final nombreLimpio = nombre.trim();
    final correoLimpio = correo.trim();
    final passwordLimpio = password.trim();
    final confirmLimpio = confirmPassword.trim();

    if (nombreLimpio.isEmpty || correoLimpio.isEmpty || passwordLimpio.isEmpty || confirmLimpio.isEmpty) {
      throw AuthException('Por favor llena todos los campos');
    }
    if (!correoLimpio.contains('@')) {
      throw AuthException('Ingresa un correo válido');
    }
    if (passwordLimpio.length < 6) {
      throw AuthException('La contraseña debe tener al menos 6 caracteres');
    }
    if (passwordLimpio != confirmLimpio) {
      throw AuthException('Las contraseñas no coinciden');
    }

    return repository.register(nombre: nombreLimpio, correo: correoLimpio, password: passwordLimpio);
  }
}
