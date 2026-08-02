import 'package:firebase_auth/firebase_auth.dart';
import 'package:medisync_core/medisync_core.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<String?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user?.uid;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseError(e.code);
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Stream<String?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) => user?.uid);
  }

  @override
  Future<UserRole> getCurrentUserRole() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return UserRole.patient;
    final tokenResult = await user.getIdTokenResult();
    final claim = tokenResult.claims?['role'] as String?;
    return UserRole.fromClaim(claim);
  }

  @override
  Future<Patient?> getCurrentPatient() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return Patient(
      id: user.uid,
      fullName: user.displayName ?? 'Paciente',
      dateOfBirth: DateTime(1990),
      sex: 'M',
    );
  }

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
