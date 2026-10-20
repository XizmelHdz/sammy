/// Representa un producto dentro de las reglas de negocio de la app.
/// No sabe nada de bases de datos, APIs ni de Flutter.
class Producto {
  final int? id;
  final String nombre;
  final double precio;
  final String categoria;
  final String descripcion;
  final String? foto; // ruta o URL, puede ser null
  final bool disponible;
  final int idUsuario; // dueño del producto

  const Producto({
    this.id,
    required this.nombre,
    required this.precio,
    required this.categoria,
    required this.descripcion,
    this.foto,
    required this.disponible,
    required this.idUsuario,
  });

  /// Crea un Producto a partir del JSON que devuelve la API.
  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id_producto'],
      nombre: json['nombre'] ?? '',
      // precio puede venir como int, double, num o incluso String
      precio: _toDouble(json['precio']),
      categoria: json['categoria'] ?? '',
      descripcion: json['descripcion'] ?? '',
      foto: json['foto'],
      disponible: json['disponible'] ?? true,
      idUsuario: json['id_usuario'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'precio': precio,
      'categoria': categoria,
      'descripcion': descripcion,
      'foto': foto,
      'disponible': disponible,
      'id_usuario': idUsuario,
    };
  }

  /// Copia el producto cambiando solo algunos campos (útil para editar).
  Producto copyWith({
    int? id,
    String? nombre,
    double? precio,
    String? categoria,
    String? descripcion,
    String? foto,
    bool? disponible,
    int? idUsuario,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      precio: precio ?? this.precio,
      categoria: categoria ?? this.categoria,
      descripcion: descripcion ?? this.descripcion,
      foto: foto ?? this.foto,
      disponible: disponible ?? this.disponible,
      idUsuario: idUsuario ?? this.idUsuario,
    );
  }

  // Helper para convertir cualquier tipo numérico/string a double
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}