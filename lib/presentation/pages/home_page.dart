import 'package:flutter/material.dart';
import '../widgets/menu.dart';   // Importa el widget del menú inferior
import '../widgets/header.dart'; // Importa el widget del header personalizado

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No usamos AppBar ni Drawer porque tenemos un header personalizado
      body: SafeArea(
        child: Column(
          children: [
            // Header personalizado en la parte superior
            const CustomHeader(),

            // Contenido principal que ocupa el espacio restante
            Expanded(
              child: Center(
                child: Text(
                  'Bienvenido a la app',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),
          ],
        ),
      ),

      // Menú de navegación en la parte inferior
      bottomNavigationBar: const MainScreen(),
    );
  }
}
