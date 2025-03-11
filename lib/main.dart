import 'package:apptomaticos/presentation/router/app_router.dart';
import 'package:apptomaticos/presentation/themes/app_theme.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  await dotenv.load(fileName: ".env");

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {});
  // Inicializar Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_KEY'] ?? '',
  );
  // Fijar la orientación en solo vertical
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

final cloudinary =
    Cloudinary.fromCloudName(cloudName: dotenv.env['CLOUD_NAME'] ?? '');

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: temaApp,
      locale: const Locale('es'), // 🌎 Español sin variante regional
      supportedLocales: const [
        Locale('es'), // Español
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: AppRouter.router,
    );
  }
}
