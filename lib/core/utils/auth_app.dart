import 'package:apptomaticos/presentation/screens/login/login_widget.dart';
import 'package:apptomaticos/presentation/screens/menu/menu.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthApp extends StatefulWidget {
  const AuthApp({super.key});

  @override
  State<AuthApp> createState() => _AuthAppState();
}

class _AuthAppState extends State<AuthApp> {
  final SupabaseClient supabase = Supabase.instance.client;

  User? user;

  @override
  void initState() {
    getAuth();
    super.initState();
  }

  Future<void> getAuth() async {
    setState(
      () {
        user = supabase.auth.currentUser;
      },
    );
    supabase.auth.onAuthStateChange.listen(
      (event) {
        setState(
          () {
            user = event.session?.user;
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return user == null ? const LoginWidget() : const Menu();
  }
}
