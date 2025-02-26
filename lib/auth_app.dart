import 'package:apptomaticos/presentation/screens/login/login_widget.dart';
import 'package:apptomaticos/presentation/screens/menu/menu.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
    super.initState();
    getAuth();
  }

  Future<void> getAuth() async {
    if (mounted) {
      setState(() {
        user = supabase.auth.currentUser;
      });
    }

    // 🔹 Se guarda el token al iniciar sesión
    supabase.auth.onAuthStateChange.listen((event) async {
      if (event.session?.user != null) {
        await FirebaseMessaging.instance.requestPermission();
        await saveFcmToken();
      }

      if (mounted) {
        setState(() {
          user = event.session?.user;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return user == null ? const LoginWidget() : const Menu();
  }
}

/// 🔹 Guarda el token de FCM en Supabase
Future<void> saveFcmToken() async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return;

  final fcmToken = await FirebaseMessaging.instance.getToken();
  if (fcmToken != null) {
    await Supabase.instance.client.from('usuarios').update({
      'fcm_token': fcmToken,
    }).eq('idUsuario', user.id);
  }
}
