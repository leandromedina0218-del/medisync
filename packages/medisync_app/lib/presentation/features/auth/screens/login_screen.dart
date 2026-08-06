import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Controladores para los campos de texto
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisible = false;

  @override
  void dispose() {
    // Liberar memoria al salir de la pantalla
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Validar formulario antes de intentar login
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authNotifierProvider.notifier).signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

    // Mostrar error si el login falló
    if (mounted) {
      final authState = ref.read(authNotifierProvider);
      authState.whenOrNull(
        error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Colors.red.shade700,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuchar estado del login para mostrar spinner
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo del manual de marca
                  Image.asset(
                    'assets/images/logo_medisync.png',
                    width: 280,
                    filterQuality: FilterQuality.high,
                  ),
                  const SizedBox(height: 8),

                  // Subtítulo
                  const Text(
                    'Tu salud, siempre contigo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Campo de correo electrónico
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa tu correo';
                      }
                      if (!value.contains('@')) {
                        return 'Correo no válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campo de contraseña con toggle de visibilidad
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () => setState(
                          () => _passwordVisible = !_passwordVisible,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa tu contraseña';
                      }
                      if (value.length < 6) {
                        return 'Mínimo 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Botón de login con estado de carga
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleLogin,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Iniciar sesión',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
