enum UserRole {
  patient,
  labTechnician,
  doctor,
  admin;

  static UserRole fromClaim(String? claim) {
    return switch (claim) {
      'lab_tech' => UserRole.labTechnician,
      'doctor' => UserRole.doctor,
      'admin' => UserRole.admin,
      _ => UserRole.patient,
    };
  }

  bool get canUploadResults =>
      this == UserRole.labTechnician || this == UserRole.admin;

  bool get canViewAllPatients =>
      this == UserRole.doctor || this == UserRole.admin;

  bool get isPatient => this == UserRole.patient;
}
