class Patient {
  final String id;
  final String fullName;
  final DateTime dateOfBirth;
  final String sex; // 'M' | 'F'
  final String? linkedDoctorId;
  final String? fcmToken; // para notificaciones push

  const Patient({
    required this.id,
    required this.fullName,
    required this.dateOfBirth,
    required this.sex,
    this.linkedDoctorId,
    this.fcmToken,
  });

  int get ageInYears {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }
}
