import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_text_field_style.dart';
import '../../core/widgets/auth_card.dart';
import '../../core/widgets/error_banner.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/gradient_button.dart';


class ProductoFormScreen extends StatefulWidget {
  /// Si viene null → modo "crear".
  /// Si viene con datos → modo "editar".
 final Productos? producto;
  final int idUsuario;

  const ProductoFormScreen({
    super.key,
    this.producto,
    required this.idUsuario,
  });

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _categoriaController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  bool _disponible = true;
  bool _isLoading = false;
  String? _errorMessage;

  /// Archivo de imagen seleccionado (solo para móvil/desktop).
  File? _imagenSeleccionada;

  final ImagePicker _picker = ImagePicker();

  bool get _esEdicion => widget.producto != null;

  String get hostUrl =>
      (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
          ? 'http://10.0.2.2:3000'
          : 'http://localhost:3000';

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    if (p != null) {
      _nombreController.text = p.nombre;
      _precioController.text = p.precio.toString();
      _categoriaController.text = p.categoria;
      _descripcionController.text = p.descripcion;
      _disponible = p.disponible;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _categoriaController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    try {
      final XFile? pick = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pick == null) return;
      setState(() => _imagenSeleccionada = File(pick.path));
    } catch (e) {
      debugPrint('ERROR IMAGEN -> $e');
      setState(() => _errorMessage = 'No se pudo seleccionar la imagen.');
    }
  }

  Future<void> _guardar() async {
    final nombre = _nombreController.text.trim();
    final precioTexto = _precioController.text.trim();
    final categoria = _categoriaController.text.trim();
    final descripcion = _descripcionController.text.trim();

    // Validaciones en cliente
    if (nombre.isEmpty || precioTexto.isEmpty) {
      setState(() => _errorMessage = 'Nombre y precio son obligatorios.');
      return;
    }

    final precio = double.tryParse(precioTexto);
    if (precio == null) {
      setState(() => _errorMessage = 'El precio debe ser un número válido.');
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      // Construimos la petición multipart porque enviamos archivo + campos
      final Uri url = _esEdicion
          ? Uri.parse('$hostUrl/api/productos/${widget.producto!.id}')
          : Uri.parse('$hostUrl/api/productos');

      final request = http.MultipartRequest(_esEdicion ? 'PUT' : 'POST', url);

      request.fields['nombre'] = nombre;
      request.fields['precio'] = precio.toString();
      request.fields['categoria'] = categoria;
      request.fields['descripcion'] = descripcion;
      request.fields['disponible'] = _disponible.toString();
      request.fields['id_usuario'] = widget.idUsuario.toString();

      if (_imagenSeleccionada != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'imagen',
            _imagenSeleccionada!.path,
          ),
        );
      }

      debugPrint('${_esEdicion ? "PUT" : "POST"} -> $url');

      final streamed = await request.send().timeout(
            const Duration(seconds: 30),
          );
      final response = await http.Response.fromStream(streamed);

      debugPrint('STATUS -> ${response.statusCode}');
      debugPrint('BODY -> ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        Navigator.pop(
          context,
          _esEdicion
              ? '¡Producto actualizado con éxito!'
              : '¡Producto creado con éxito!',
        );
      } else {
        String mensaje = 'No se pudo guardar el producto.';
        try {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          mensaje = json['message'] ?? mensaje;
        } catch (_) {}
        setState(() => _errorMessage = mensaje);
      }
    } catch (e, st) {
      debugPrint('ERROR GUARDAR PRODUCTO -> $e');
      debugPrint('STACK -> $st');
      setState(() => _errorMessage = 'Error de conexión: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, top: 4),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _esEdicion ? 'Editar producto' : 'Nuevo producto',
                            style: GoogleFonts.fredoka(
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '🎁 Completa los datos del regalo',
                            style: GoogleFonts.nunito(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.black.withOpacity(0.75),
                            ),
                          ),
                          const SizedBox(height: 24),
                          AuthCard(
                            child: Column(
                              children: [
                                // Selector de imagen
                                GestureDetector(
                                  onTap: _seleccionarImagen,
                                  child: Container(
                                    height: 140,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: AppColors.hotPink.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppColors.hotPink.withOpacity(0.3),
                                      ),
                                    ),
                                    child: _imagenSeleccionada != null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            child: Image.file(
                                              _imagenSeleccionada!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add_photo_alternate_outlined,
                                                size: 42,
                                                color: AppColors.hotPink,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Toca para elegir una imagen',
                                                style: GoogleFonts.nunito(
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.ink,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                TextField(
                                  controller: _nombreController,
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                  decoration: buildFieldDecoration(
                                    'Nombre',
                                    Icons.card_giftcard,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                TextField(
                                  controller: _precioController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                  decoration: buildFieldDecoration(
                                    'Precio',
                                    Icons.attach_money,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                TextField(
                                  controller: _categoriaController,
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                  decoration: buildFieldDecoration(
                                    'Categoría',
                                    Icons.category_outlined,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                TextField(
                                  controller: _descripcionController,
                                  maxLines: 3,
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink,
                                  ),
                                  decoration: buildFieldDecoration(
                                    'Descripción',
                                    Icons.description_outlined,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                SwitchListTile(
                                  value: _disponible,
                                  onChanged: (v) =>
                                      setState(() => _disponible = v),
                                  title: Text(
                                    'Disponible',
                                    style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  activeColor: AppColors.hotPink,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                ErrorBanner(message: _errorMessage),
                                const SizedBox(height: 20),
                                GradientButton(
                                  label: _esEdicion
                                      ? 'Guardar cambios'
                                      : 'Crear producto',
                                  onPressed: _guardar,
                                  isLoading: _isLoading,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
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