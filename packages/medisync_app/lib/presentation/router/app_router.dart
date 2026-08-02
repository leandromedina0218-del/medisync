import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';

// Widget raíz que escucha el estado de autenticación
class AppRouter extends ConsumerWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchar cambios en el estado de sesión
    final authState = ref.watch(authStateProvider);

    return authState.when(
      // Mientras verifica la sesión, mostrar splash
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF0077B6),
          ),
        ),
      ),
      // Si hay error, mostrar login
      error: (_, __) => const LoginScreen(),
      // Si hay uid → Dashboard, si es null → Login
      data: (uid) =>
          uid != null ? const DashboardScreen() : const LoginScreen(),
    );
  }
}
