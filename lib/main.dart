import 'package:flutter/material.dart';
import 'package:movil_matrizinmobiliaria/presentation/pages/home_page.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/login_page.dart';
// 💡 Importamos MainScreen, que contiene el Header y el Menú.
import 'presentation/widgets/menu.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Matriz Inmobiliaria',
      theme: ThemeData(primarySwatch: Colors.teal),
      
      // ⚠️ Iniciamos en la pantalla de bienvenida
      home: const SplashPage(), 
      
      // 💡 Definición de rutas:
      routes: {
        '/login': (context) => const LoginPage(),
        
        // ✅ AÑADIMOS la ruta principal que carga el MainScreen (el contenedor con el menú).
        '/home': (context) => const TusInmueblesScreen(),
      },
    );
  }
}