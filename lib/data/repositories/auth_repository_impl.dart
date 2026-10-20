import '../../domain/entities/usuario.dart';
import '../../domain/repositories/auth_repository.dart';


class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Usuario> login(String correo, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (correo == 'admin@detallessammy.com' && password == 'admin123') {
      return const Usuario(id: 1, nombre: 'Sammy Admin', correo: 'admin@detallessammy.com', rol: 'admin');
    }

    throw AuthException('Correo o contraseña incorrectos');
  }

  @override
  Future<Usuario> register({
    required String nombre,
    required String correo,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    // TODO: reemplazar por el INSERT real en tu tabla "usuarios" (rol = 'cliente')
    return Usuario(nombre: nombre, correo: correo, rol: 'cliente');
  }
}
