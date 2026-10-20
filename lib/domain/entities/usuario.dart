/// Representa a un usuario dentro de las reglas de negocio de la app.
/// No sabe nada de bases de datos, APIs ni de Flutter.
class Usuario {
  final int? id;
  final String nombre;
  final String correo;
  final String rol; // 'admin' | 'vendedor' | 'cliente'

  const Usuario({
    this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
  });
}
