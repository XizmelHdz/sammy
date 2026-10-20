import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores para obtener los datos escritos
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Controla si la contraseña se muestra
  bool mostrarPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: _crearContenido(),
    );
  }

  // Contenido general
  Widget _crearContenido() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _crearImagen(),
            _crearEspacio(25),
            _crearTituloRegistro(), // título + registro (método unido)
            _crearEspacio(25),
            _crearCampoCorreo(),
            _crearEspacio(20),
            _crearCampoPassword(),
            _crearEspacio(10),
            _crearOpciones(),
            _crearEspacio(20),
            _crearBotonLogin(),
          ],
        ),
      ),
    );
  }

  // Imagen
  Widget _crearImagen() {
    return Image.asset(
      'assets/images/delivery.png',
      width: 200,
      height: 200,
    );
  }

  // MÉTODO UNIDO: _crearTitulo + _crearRegistro
  Widget _crearTituloRegistro() {
    return Column(
      children: [
        const Text(
          'Bienvenido',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        _crearEspacio(8),
        const Text(
          'Inicio de sesión',
          style: TextStyle(
            fontSize: 16,
            color: Color.fromARGB(255, 21, 21, 21),
          ),
        ),
        _crearEspacio(8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('¿No tienes una cuenta?'),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Crear cuenta',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Correo
  Widget _crearCampoCorreo() {
    return TextField(
      controller: correoController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Correo electrónico',
        hintText: 'ejemplo@correo.com',
        prefixIcon: Icon(Icons.email),
      ),
    );
  }

  // Contraseña
  Widget _crearCampoPassword() {
    return TextField(
      controller: passwordController,
      obscureText: !mostrarPassword,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            mostrarPassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              mostrarPassword = !mostrarPassword;
            });
          },
        ),
      ),
    );
  }

  // Recordarme y contraseña olvidada
  Widget _crearOpciones() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: true,
              onChanged: (valor) {},
            ),
            const Text('Recordarme'),
          ],
        ),
        TextButton(
          onPressed: () {},
          child: const Text('¿Olvidaste tu contraseña?'),
        ),
      ],
    );
  }

  // Botón iniciar sesión
  Widget _crearBotonLogin() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          String correo = correoController.text;
          String password = passwordController.text;

          print('Correo: $correo');
          print('Contraseña: $password');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'INICIAR SESIÓN',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _crearEspacio(double enter) {
    return SizedBox(height: enter);
  }
}

//generar dos interfaces en vez de un Metodo solo un metodo que haga caja de texto Atributos
//metodos tres  decidimos los parametros

