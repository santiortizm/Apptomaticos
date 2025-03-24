import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  late SupabaseClient supabaseClient;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await dotenv.load(fileName: ".env");

    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_KEY'];

    if (url == null || anonKey == null) {
      throw Exception(
          'Las credenciales de Supabase no están definidas en .env');
    }

    await Supabase.initialize(url: url, anonKey: anonKey);
    supabaseClient = Supabase.instance.client;
  });

  test('✅ Inicio de sesión exitoso con credenciales correctas', () async {
    final response = await supabaseClient.auth.signInWithPassword(
      email: 'productor@gmail.com',
      password: '1234',
    );

    expect(response.user, isNotNull, reason: "El usuario debería existir");
    expect(response.session, isNotNull,
        reason: "Debe existir una sesión activa");
    expect(response.session?.accessToken, isNotEmpty,
        reason: "Debe haber un token activo");
    print('🟢 Inicio de sesion exitoso.');
  });

  test('❌ No permite iniciar sesión con email vacío', () async {
    try {
      await supabaseClient.auth.signInWithPassword(email: '', password: '1234');
      fail('No debería permitir iniciar sesión sin email');
    } catch (e) {
      expect(e, isA<AuthException>());
    }
  });

  test('❌ No permite iniciar sesión con contraseña vacía', () async {
    try {
      await supabaseClient.auth
          .signInWithPassword(email: 'productor@gmail.com', password: '');
      fail('No debería permitir iniciar sesión sin contraseña');
    } catch (e) {
      expect(e, isA<AuthException>());
    }
  });

  test('❌ No permite iniciar sesión con email mal formateado', () async {
    try {
      await supabaseClient.auth
          .signInWithPassword(email: 'correo-malformateado', password: '1234');
      fail('No debería permitir iniciar sesión con un email mal formateado');
    } catch (e) {
      expect(e, isA<AuthException>());
    }
  });

  test('❌ No permite iniciar sesión con credenciales incorrectas', () async {
    try {
      await supabaseClient.auth.signInWithPassword(
          email: 'productor@gmail.com', password: 'wrong_password');
      fail('No debería permitir iniciar sesión con credenciales incorrectas');
    } catch (e) {
      expect(e, isA<AuthException>());
    }
  });
}
