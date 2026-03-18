import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../widgets/citas/alertas_modernas.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      context.showModernToast(
        message: "Por favor, completa todos los campos para continuar.",
        type: AlertType.error,
        position: AlertPosition.top,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.login(email, password);

      if (result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        final user = result['user'] as User;
        final token = result['token'] as String;

        await prefs.setString('auth_token', token);
        await prefs.setString('current_user', user.toJsonString());
        await prefs.setString('refresh_token', result['refreshToken'] ?? '');

        if (mounted) {
          context.showModernSuccess(
            message: "¡Acceso concedido! Bienvenido al sistema.",
            onComplete: () {
              Navigator.of(context).pushReplacementNamed('/home');
            },
          );
        }
      } else {
        if (mounted) {
          context.showModernToast(
            message:
                "Las credenciales ingresadas no son válidas. Intenta de nuevo.",
            type: AlertType.error,
            position: AlertPosition.top,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        context.showModernToast(
          message:
              "No se pudo establecer conexión con el servidor. Verifica tu red.",
          type: AlertType.error,
          position: AlertPosition.top,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003366),
      body: Stack(
        children: [
          // Fondo con imagen y overlay dinámico
          Positioned.fill(
            child: Image.asset(
              "assets/images/casa2.jpg",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF003366).withOpacity(0.85),
                    const Color(0xFF003366).withOpacity(0.4),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),

          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 50),
                // Logo con animación elegante
                FadeInDown(
                  duration: const Duration(milliseconds: 1000),
                  child: Center(
                    child: Image.asset(
                      "assets/images/LogoSinFondo.png",
                      height: 90,
                    ),
                  ),
                ),
                const Spacer(),

                // Panel de login Premium
                FadeInUp(
                  duration: const Duration(milliseconds: 1000),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 45),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black45,
                          blurRadius: 25,
                          offset: Offset(0, -10),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              "MATRIZ INMOBILIARIA",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Center(
                            child: Text(
                              "Bienvenido de nuevo",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF003366),
                                height: 1.1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              "Ingresa tus credenciales para acceder al panel de gestión.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Campo Correo
                          _buildLabel("Correo electrónico"),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: _emailController,
                            hint: "Escribe tu correo aquí",
                            icon: Icons.alternate_email_outlined,
                          ),
                          const SizedBox(height: 25),

                          // Campo Contraseña
                          _buildLabel("Contraseña"),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: _passwordController,
                            hint: "Tu clave de acceso",
                            icon: Icons.lock_open_outlined,
                            isPassword: true,
                            obscureText: !_isPasswordVisible,
                            togglePassword: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          const SizedBox(height: 45),

                          // Botón de Acción Principal
                          SizedBox(
                            width: double.infinity,
                            height: 65,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF003366),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 10,
                                shadowColor:
                                    const Color(0xFF003366).withOpacity(0.4),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text(
                                      "Iniciar sesión ahora",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: Color(0xFF003366),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? togglePassword,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey[200]!, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 16, color: Colors.black),
        cursorColor: const Color(0xFF003366),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
          prefixIcon: Icon(icon, color: const Color(0xFF003366), size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey[500],
                    size: 20,
                  ),
                  onPressed: togglePassword,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFF003366), width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }
}
