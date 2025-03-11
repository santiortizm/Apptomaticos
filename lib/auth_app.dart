import 'dart:async';

import 'package:apptomaticos/presentation/screens/login/login_widget.dart';
import 'package:apptomaticos/presentation/screens/menu/menu.dart';
import 'package:apptomaticos/presentation/screens/menu_trucker/menu_trucker.dart';
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
  String? userRole;
  bool isLoading = true;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    user = supabase.auth.currentUser;

    if (user != null) {
      await _fetchUserRole();
    } else {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }

    _authSubscription = supabase.auth.onAuthStateChange.listen((event) async {
      if (!mounted) return;

      final newUser = event.session?.user;

      if (newUser == null) {
        if (mounted) {
          setState(() {
            user = null;
            userRole = null;
            isLoading = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() => isLoading = true);
      }

      user = newUser;
      await FirebaseMessaging.instance.requestPermission();
      await saveFcmToken();
      await _fetchUserRole();
    });
  }

  /// ✅ Obtiene el rol del usuario desde la base de datos
  Future<void> _fetchUserRole() async {
    if (user == null) return;

    final response = await supabase
        .from('usuarios')
        .select('rol')
        .eq('idUsuario', user!.id)
        .maybeSingle();

    if (mounted) {
      setState(() {
        userRole = response?['rol'];
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _authSubscription
        ?.cancel(); // ✅ Cancela la suscripción cuando el widget es eliminado
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) return const LoginWidget();

    if (userRole == 'Transportador') {
      return const MenuTrucker();
    } else {
      return const Menu();
    }
  }
}

/// ✅ Guarda el token de FCM en Supabase
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
