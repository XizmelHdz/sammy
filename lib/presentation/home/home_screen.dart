import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../domain/entities/productos.dart';
import '../../domain/entities/usuario.dart';
import 'formulario_producto.dart';
import '../login/login_screen.dart'; 

class HomeScreen extends StatefulWidget {
  final Usuario usuario;

  const HomeScreen({super.key, required this.usuario});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // IP dinámica
  String get hostUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  // ============ READ (Leer productos) ============
  Future<List<Productos>> _obtenerProductos() async {
    final response = await http.get(Uri.parse('$hostUrl/api/productos'));
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body) as List<dynamic>;
      return body
          .map((item) => Productos.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Error al conectar con el servidor (${response.statusCode})');
  }

  // ============ DELETE (Eliminar producto) ============
  Future<void> _eliminarProducto(int id) async {
    try {
      final response = await http.delete(Uri.parse('$hostUrl/api/productos/$id'));
      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {}); // Refresca la lista
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto eliminado 🗑️')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo eliminar (código ${response.statusCode})')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de red: $e')),
      );
    }
  }

  // ============ CONFIRMAR ELIMINACIÓN ============
  void _confirmarEliminacion(int id, String nombre) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Seguro que deseas eliminar permanentemente "$nombre" de la tienda?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogContext);
              _eliminarProducto(id);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ============ LOGOUT (Cerrar sesión) ============
  Future<void> _cerrarSesion() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: Text('¿Seguro que quieres salir, ${widget.usuario.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Salir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (ok == true && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()), 
        (route) => false, 
      );
    }
  }

  // ============ RENDERIZADOR DE IMÁGENES ============
  // CORRECCIÓN 1: Acepta String? (puede ser nulo) y si es null muestra un ícono
  Widget _renderizarImagenProducto(String? ruta) {
    if (ruta == null || ruta.isEmpty) {
      return Container(
        width: 60, height: 60, color: Colors.grey[300],
        child: const Icon(Icons.card_giftcard, size: 30, color: Colors.grey),
      );
    }

    // Assets locales
    if (ruta.startsWith('assets/')) {
      return Image.asset(
        ruta, width: 60, height: 60, fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Container(
          width: 60, height: 60, color: Colors.grey[300],
          child: const Icon(Icons.card_giftcard, size: 30, color: Colors.grey),
        ),
      );
    }

    // URL completa (http/https)
    if (ruta.startsWith('http://') || ruta.startsWith('https://')) {
      String urlCorregida = ruta;
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        urlCorregida = ruta.replaceAll('localhost', '10.0.2.2');
      }
      return Image.network(
        urlCorregida, width: 60, height: 60, fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300], width: 60, height: 60,
          child: const Icon(Icons.broken_image, size: 30, color: Colors.grey),
        ),
      );
    }

    // CORRECCIÓN 2: Tu server.js usa /imagenes, no /uploads
    final urlCompleta = '$hostUrl/imagenes/$ruta';
    return Image.network(
      urlCompleta, width: 60, height: 60, fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[300], width: 60, height: 60,
        child: const Icon(Icons.broken_image, size: 30, color: Colors.grey),
      ),
    );
  }

  // ============ BUILD ============
  @override
  Widget build(BuildContext context) {
    final bool isAdmin = widget.usuario.rol.toLowerCase() == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles Sammy - Regalos'),
        backgroundColor: Colors.pink, 
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(widget.usuario.nombre),
              accountEmail: Text(widget.usuario.correo),
              currentAccountPicture: const CircleAvatar(child: Icon(Icons.person)),
              decoration: const BoxDecoration(color: Colors.pink),
            ),
            ListTile(
              leading: const Icon(Icons.card_giftcard, color: Colors.pink),
              title: const Text('Catálogo'),
              onTap: () => Navigator.pop(context),
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión'),
              onTap: _cerrarSesion,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: FutureBuilder<List<Productos>>(
        future: _obtenerProductos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.pink));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar datos: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay productos en el catálogo aún.'));
          }

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final producto = snapshot.data![index];
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  elevation: 2,
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _renderizarImagenProducto(producto.foto),
                    ),
                    title: Text(
                      producto.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      'Categoría: ${producto.categoria}\nPrecio: \$${producto.precio.toStringAsFixed(2)} | ${producto.disponible ? "Disponible" : "Agotado"}',
                    ),
                    isThreeLine: true,
                    trailing: isAdmin ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => FormularioProductoScreen(productoAEditar: producto)),
                            ).then((_) => setState(() {}));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          // CORRECCIÓN 3: Usamos producto.id! en lugar de producto.idProducto
                          onPressed: () => _confirmarEliminacion(producto.id!, producto.nombre),
                        ),
                      ],
                    ) : null, 
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: isAdmin ? FloatingActionButton.extended(
        backgroundColor: Colors.pink,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormularioProductoScreen()),
          ).then((_) => setState(() {}));
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuevo Producto', style: TextStyle(color: Colors.white)),
      ) : null,
    );
  }
}