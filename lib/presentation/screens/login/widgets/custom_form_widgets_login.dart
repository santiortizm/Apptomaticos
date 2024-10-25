import 'package:flutter/material.dart';

//TextField usuario login
class BuildUsernameField extends StatelessWidget {
  const BuildUsernameField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Usuario',
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.person, color: Colors.red),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
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
}

//TextField password login
class BuildPasswordField extends StatefulWidget {
  const BuildPasswordField({super.key});

  @override
  State<BuildPasswordField> createState() => _BuildPasswordFieldState();
}

class _BuildPasswordFieldState extends State<BuildPasswordField> {
  @override
  Widget build(BuildContext context) {
    bool isObscure = true; // Para controlar la visibilidad de la contraseña
    return TextFormField(
      obscureText: isObscure,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.lock, color: Colors.red),
        suffixIcon: IconButton(
          icon: Icon(
            // ignore: dead_code
            isObscure ? Icons.visibility : Icons.visibility_off,
            color: Colors.red,
          ),
          onPressed: () {
            setState(() {
              isObscure = !isObscure;
            });
          },
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.9),
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
}
