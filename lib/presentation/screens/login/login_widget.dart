import 'package:App_Tomaticos/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final SupabaseClient supabase = Supabase.instance.client;
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/img_inicio_sesion.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Iniciar Sesión',
                        style:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Text(
                        'Utilice su cuenta para iniciar sesión',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: const Color.fromARGB(255, 255, 255, 255),
                            ),
                      ),
                      SizedBox(height: size.height * 0.05),
                      _buildUsernameField(),
                      SizedBox(height: size.height * 0.02),
                      _buildPasswordField(),
                      SizedBox(height: size.height * 0.02),
                      SizedBox(height: size.height * 0.02),
                      isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _handleLogin,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: size.height * 0.02,
                                  horizontal: size.width * 0.2,
                                ),
                                backgroundColor: buttonGreen,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Iniciar Sesión',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                            ),
                      SizedBox(height: size.height * 0.02),
                      _buildFooterLinks(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///  **Maneja el inicio de sesión y redirige según el rol**
  Future<void> _handleLogin() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid != true) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await supabase.auth.signInWithPassword(
        email: userController.text,
        password: passwordController.text,
      );

      final user = response.user;
      if (user == null) throw 'Error en la autenticación';

      // ✅ Redirigir a AuthApp para que verifique el rol
      GoRouter.of(context).go('/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Inicio de sesión fallido. Verifique sus credenciales.'),
          backgroundColor: redApp,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false; // ⏳ Ocultar loading
        });
      }
    }
  }

  ///  **Campo de usuario**
  Widget _buildUsernameField() {
    return TextFormField(
      controller: userController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: 'Correo',
        hintStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        prefixIcon: Icon(Icons.person, color: redApp),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Ingrese su usuario' : null,
    );
  }

  ///  **Campo de contraseña**
  Widget _buildPasswordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: _isObscure,
      decoration: InputDecoration(
        hintText: 'Contraseña',
        hintStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        prefixIcon: Icon(Icons.lock, color: redApp),
        suffixIcon: IconButton(
          icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off,
              color: redApp),
          onPressed: () => setState(() {
            _isObscure = !_isObscure;
          }),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Ingrese su contraseña' : null,
    );
  }

  /// 🔹 **Enlaces de "Olvidó su contraseña" y "Registrarse"**
  Widget _buildFooterLinks() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {},
          child: const Text('¿Olvidó su contraseña?',
              style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('¿Aún no tienes una cuenta?',
                style: TextStyle(color: Colors.white)),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'Regístrate',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
