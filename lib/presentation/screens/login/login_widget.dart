import 'package:apptomaticos/core/constants/colors.dart';
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

  bool singInLoading = false;
  bool singupLoading = false;
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true; // Para controlar la visibilidad de la contraseña
  bool _rememberMe = false; // Estado del checkbox "Recuérdame"

  @override
  void initState() {
    super.initState();
  }

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
              color: Colors.black.withValues(alpha: 0.4),
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
                              color: Colors.white70,
                            ),
                      ),
                      SizedBox(height: size.height * 0.05),
                      // Campo de usuario
                      _buildUsernameField(),
                      SizedBox(height: size.height * 0.02),
                      // Campo de contraseña
                      _buildPasswordField(),
                      SizedBox(height: size.height * 0.02),
                      // Checkbox "Recuérdame"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            activeColor: redApp, // Color del checkbox
                          ),
                          const Text(
                            'Recuérdame',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.02),
                      // Botón "Iniciar Sesión"
                      singInLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: () async {
                                final isValid =
                                    _formKey.currentState?.validate();
                                if (isValid != true) {
                                  return; // Detener si los campos son inválidos
                                }

                                setState(() {
                                  singInLoading = true;
                                });

                                try {
                                  await supabase.auth.signInWithPassword(
                                    email: userController.text,
                                    password: passwordController.text,
                                  );

                                  //  Si el inicio de sesión es exitoso, navegar al menú
                                  if (mounted) {
                                    // ignore: use_build_context_synchronously
                                    GoRouter.of(context).go('/menu');
                                    //  GoRouter navega a la pantalla de inicio
                                  }
                                } catch (e) {
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                          'Inicio de sesión fallido. Verifique sus credenciales.'),
                                      backgroundColor: redApp,
                                    ),
                                  );
                                } finally {
                                  setState(() {
                                    singInLoading = false;
                                  });
                                }
                              },
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
                      // Enlaces de Olvidó su contraseña y Registrarse
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

  // Campo de texto para el usuario
  Widget _buildUsernameField() {
    return TextFormField(
      controller: userController,
      decoration: InputDecoration(
        labelText: 'Usuario',
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(Icons.person, color: redApp),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese su usuario';
        }
        return null;
      },
    );
  }

  // Campo de texto para la contraseña
  Widget _buildPasswordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: _isObscure,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(Icons.lock, color: redApp),
        suffixIcon: IconButton(
          icon: Icon(
            _isObscure ? Icons.visibility : Icons.visibility_off,
            color: redApp,
          ),
          onPressed: () {
            setState(() {
              _isObscure = !_isObscure;
            });
          },
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingrese su contraseña';
        }
        return null;
      },
    );
  }

  // Enlaces de "Olvidó su contraseña" y "Registrarse"
  Widget _buildFooterLinks() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            // Acción para "Olvidó su contraseña"
          },
          child: const Text(
            '¿Olvidó su contraseña?',
            style: TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '¿Aún no tienes una cuenta?',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () {
                // Acción para "Registrarse"
              },
              child: const Text(
                'Regístrate',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
