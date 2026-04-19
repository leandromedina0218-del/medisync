import '../entities/patient.dart';
import '../value_objects/user_role.dart';

abstract interface class AuthRepository {
  Future<String?> signInWithEmail(String email, String password);
  Future<void> signOut();
  Stream<String?> get authStateChanges; // emite uid o null
  Future<UserRole> getCurrentUserRole();
  Future<Patient?> getCurrentPatient();
}
