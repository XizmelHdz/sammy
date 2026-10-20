/// Modelo que representa un registro de la tabla "roles"
/// de la base de datos sammy_app.
///
/// Columnas en la base de datos:
/// id_rol, nombre_rol
class Rol {
  final int idRol;
  final String nombreRol;

  Rol({
    required this.idRol,
    required this.nombreRol,
  });

  /// Crea un Rol a partir del JSON que devuelve la API (server.js).
  factory Rol.fromJson(Map<String, dynamic> json) {
    return Rol(
      idRol: json['id_rol'],
      nombreRol: json['nombre_rol'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre_rol': nombreRol,
    };
  }
}