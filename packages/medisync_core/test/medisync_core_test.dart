import 'package:medisync_core/medisync_core.dart';
import 'package:test/test.dart';

void main() {
  group('UserRole', () {
    test('fromClaim retorna patient para claim desconocido', () {
      expect(UserRole.fromClaim(null), equals(UserRole.patient));
      expect(UserRole.fromClaim('unknown'), equals(UserRole.patient));
    });

    test('fromClaim mapea correctamente los roles conocidos', () {
      expect(UserRole.fromClaim('lab_tech'), equals(UserRole.labTechnician));
      expect(UserRole.fromClaim('doctor'), equals(UserRole.doctor));
      expect(UserRole.fromClaim('admin'), equals(UserRole.admin));
    });

    test('canUploadResults es true solo para lab_tech y admin', () {
      expect(UserRole.labTechnician.canUploadResults, isTrue);
      expect(UserRole.admin.canUploadResults, isTrue);
      expect(UserRole.patient.canUploadResults, isFalse);
      expect(UserRole.doctor.canUploadResults, isFalse);
    });
  });

  group('Patient', () {
    test('calcula la edad correctamente', () {
      final patient = Patient(
        id: '1',
        fullName: 'Carlos Ramos',
        dateOfBirth: DateTime(1990, 1, 1),
        sex: 'M',
      );
      expect(patient.ageInYears, greaterThan(30));
    });
  });
}
