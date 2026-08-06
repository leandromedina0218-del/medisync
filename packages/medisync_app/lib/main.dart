import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'presentation/core/app_theme.dart';
import 'presentation/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase antes de arrancar la app
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: MediSyncApp(),
    ),
  );
}

class MediSyncApp extends StatelessWidget {
  const MediSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediSync',
      debugShowCheckedModeBanner: false,
      // Aplicar tema con colores y tipografía del manual de marca
      theme: AppTheme.lightTheme,
      // AppRouter maneja navegación según estado de sesión
      home: const AppRouter(),
    );
  }
}
