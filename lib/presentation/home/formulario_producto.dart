import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ⚠️ IMPORTANTE: La ruta exacta a tu modelo de productos
import '../../domain/entities/productos.dart'; 

class FormularioProductoScreen extends StatefulWidget {
  final Productos? productoAEditar;

  const FormularioProductoScreen({super.key, this.productoAEditar});

  @override
  State<FormularioProductoScreen> createState() => _FormularioProductoScreenState();
}

class _FormularioProductoScreenState extends State<FormularioProductoScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreCtrl;
  late TextEditingController _precioCtrl;
  late TextEditingController _categoriaCtrl;
  late TextEditingController _descripcionCtrl;
  late TextEditingController _fotoCtrl;

  bool _disponible = true;
  bool _guardando = false;

  String get hostUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  bool get _esEdicion => widget.productoAEditar != null;

  @override
  void initState() {
    super.initState();
    final p = widget.productoAEditar;
    _nombreCtrl = TextEditingController(text: p?.nombre ?? '');
    _precioCtrl = TextEditingController(text: p?.precio.toString() ?? '');
    _categoriaCtrl = TextEditingController(text: p?.categoria ?? '');
    _descripcionCtrl = TextEditingController(text: p?.descripcion ?? '');
    _fotoCtrl = TextEditingController(text: p?.foto ?? '');
    _disponible = p?.disponible ?? true;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _precioCtrl.dispose();
    _categoriaCtrl.dispose();
    _descripcionCtrl.dispose();
    _fotoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final Map<String, dynamic> datos = {
      'nombre': _nombreCtrl.text.trim(),
      'precio': double.tryParse(_precioCtrl.text.trim()) ?? 0.0,
      'categoria': _categoriaCtrl.text.trim(),
      'descripcion': _descripcionCtrl.text.trim(),
      'foto': _fotoCtrl.text.trim().isEmpty ? null : _fotoCtrl.text.trim(),
      'disponible': _disponible,
      'id_usuario': 1, // Si manejas sesiones, pon aquí el ID del usuario
    };

    try {
      late http.Response response;

      if (_esEdicion) {
final id = widget.productoAEditar!.id;        response = await http.put(
          Uri.parse('$hostUrl/api/productos/$id'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(datos),
        );
      } else {
        response = await http.post(
          Uri.parse('$hostUrl/api/productos'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(datos),
        );
      }

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        _mostrarError('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      _mostrarError('Error de red: $e');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar Producto' : 'Nuevo Producto'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del regalo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.card_giftcard),
                ),
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _precioCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Precio (\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (v) {
                  if (v!.isEmpty) return 'Campo obligatorio';
                  if (double.tryParse(v) == null) return 'Ingresa un número válido';
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _categoriaCtrl,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _descripcionCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _fotoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la foto (Ej: taza.jpg)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                ),
              ),
              const SizedBox(height: 15),
              SwitchListTile(
                title: const Text('Producto Disponible'),
                value: _disponible,
                activeColor: Colors.pink,
                onChanged: (bool value) => setState(() => _disponible = value),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _guardando ? null : _guardar,
                  icon: _guardando
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _guardando ? 'Guardando...' : (_esEdicion ? 'Actualizar' : 'Guardar'),
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