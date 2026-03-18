import 'package:flutter/material.dart';
import 'package:flutter_citas_app/presentation/pages/citas_page.dart';
import 'package:flutter_citas_app/presentation/pages/reportes_page.dart';
import 'package:flutter_citas_app/presentation/pages/splash_page.dart';
import 'package:flutter_citas_app/presentation/pages/login_page.dart';
import 'package:flutter_citas_app/presentation/pages/main_layout_page.dart'; // <-- Nuevo Layout Global

import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar datos de localización para fechas en español
  await initializeDateFormatting('es');

  // Configurar orientación vertical
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Matriz Inmobiliaria',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor:
            const Color(0xFFF4F6FA), // Unifica el fondo base de la app
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android:
                FadeUpwardsPageTransitionsBuilder(), // Transición suave con leve slide fade
            TargetPlatform.iOS:
                CupertinoPageTransitionsBuilder(), // Deslizamiento lateral premium
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),

      // ⚠️ Iniciamos en la pantalla de bienvenida
      home: const SplashPage(),

      // 💡 Definición de rutas:
      routes: {
        '/login': (context) => const LoginPage(),

        // ✅ AÑADIMOS la ruta principal que carga el MainLayoutPage global
        '/home': (context) => const MainLayoutPage(),

        '/reports': (context) => const ReportesPage(),

        '/citas': (context) => const CitasPage(),
      },
    );
  }
}
