import 'package:medisync_core/medisync_core.dart';

void main() {
  // Ejemplo de uso del UserRole value object
  final role = UserRole.fromClaim('lab_tech');
  print('Rol: $role');
  print('Puede subir resultados: ${role.canUploadResults}');
}
