import 'package:flutter/material.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/widgets/menu.dart';
import 'presentation/pages/login_page.dart';

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
      home: const SplashPage(),
      routes: {
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
