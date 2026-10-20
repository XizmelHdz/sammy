import '../entities/usuario.dart';

/// Contrato que debe cumplir cualquier fuente de datos de autenticación
/// (Postgres, Sheety, Firebase, etc). La capa de dominio solo conoce esta
/// interfaz, nunca la implementación concreta.
abstract class AuthRepository {
  Future<Usuario> login(String correo, String password);

  Future<Usuario> register({
    required String nombre,
    required String correo,
    required String password,
  });
}

/// Excepción de negocio para errores de autenticación
/// (credenciales inválidas, datos faltantes, etc).
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
