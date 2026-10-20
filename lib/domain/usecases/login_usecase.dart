import '../entities/usuario.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso: iniciar sesión. Valida los datos y delega al repositorio.
class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<Usuario> call(String correo, String password) {
    final correoLimpio = correo.trim();
    final passwordLimpio = password.trim();

    if (correoLimpio.isEmpty || passwordLimpio.isEmpty) {
      throw AuthException('Por favor llena ambos campos');
    }

    return repository.login(correoLimpio, passwordLimpio);
  }
}
