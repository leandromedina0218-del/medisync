import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/patient.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/value_objects/user_role.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<String?> signInWithEmail(String email, String password) async {
    try {
      // Intentar login con email y contraseña
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Retornar el uid del usuario autenticado
      return credential.user?.uid;
    } on FirebaseAuthException catch (e) {
      // Lanzar mensaje legible para el usuario
      throw _mapFirebaseError(e.code);
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Stream<String?> get authStateChanges {
    // Emite el uid cuando el usuario inicia/cierra sesión
    return _firebaseAuth.authStateChanges().map((user) => user?.uid);
  }

  @override
  Future<UserRole> getCurrentUserRole() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return UserRole.patient;

    // Leer el custom claim del JWT de Firebase
    final tokenResult = await user.getIdTokenResult();
    final claim = tokenResult.claims?['role'] as String?;
    return UserRole.fromClaim(claim);
  }

  @override
  Future<Patient?> getCurrentPatient() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    // Datos básicos del paciente desde Firebase Auth
    return Patient(
      id: user.uid,
      fullName: user.displayName ?? 'Paciente',
      dateOfBirth: DateTime(1990), // se actualiza desde Firestore
      sex: 'M',
    );
  }

  // Mapear códigos de error de Firebase a mensajes en español
  String _mapFirebaseError(String code) {
    return switch (code) {
      'user-not-found' => 'No existe una cuenta con ese correo.',
      'wrong-password' => 'Contraseña incorrecta.',
      'invalid-email' => 'El correo no tiene un formato válido.',
      'user-disabled' => 'Esta cuenta ha sido deshabilitada.',
      'too-many-requests' => 'Demasiados intentos. Intenta más tarde.',
      _ => 'Error de autenticación. Intenta de nuevo.',
    };
  }
}
