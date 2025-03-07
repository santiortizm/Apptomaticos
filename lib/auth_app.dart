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
  bool isLoading = true; //  Nuevo: Indica que estamos cargando el rol

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

    if (user != null) {
      await _fetchUserRole(); //  Esperamos el rol antes de continuar
    }

    supabase.auth.onAuthStateChange.listen((event) async {
      if (event.session?.user != null) {
        await FirebaseMessaging.instance.requestPermission();
        await saveFcmToken();
        await _fetchUserRole();
      }

      if (mounted) {
        setState(() {
          user = event.session?.user;
        });
      }
    });
  }

  ///  Obtiene el rol del usuario desde la base de datos
  Future<void> _fetchUserRole() async {
    final userId = user?.id;
    if (userId == null) return;

    final response = await supabase
        .from('usuarios')
        .select('rol')
        .eq('idUsuario', userId)
        .maybeSingle();

    if (mounted) {
      setState(() {
        userRole = response?['rol'];
        isLoading = false; //  Ya cargamos el rol, podemos mostrar la pantalla
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const LoginWidget();

    //  Muestra un loader hasta obtener el rol
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    //  Ahora sí, mostramos el menú correcto de inmediato
    return userRole == 'Transportador' ? const MenuTrucker() : const Menu();
  }
}

///  Guarda el token de FCM en Supabase
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
