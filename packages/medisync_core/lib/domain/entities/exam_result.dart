class ExamResult {
  final String id;
  final String patientId;
  final String examTypeId;
  final String examTypeName;
  final Map<String, double> values;
  final DateTime takenAt;
  final String? aiSummary;
  final ResultStatus status;
  final String uploadedByUid;

  const ExamResult({
    required this.id,
    required this.patientId,
    required this.examTypeId,
    required this.examTypeName,
    required this.values,
    required this.takenAt,
    this.aiSummary,
    required this.status,
    required this.uploadedByUid,
  });
}

enum ResultStatus { pending, published, reviewed }
