import '../entities/exam_result.dart';

abstract interface class ResultRepository {
  Future<void> uploadResult(ExamResult result);
  Stream<List<ExamResult>> watchPatientResults(String patientId);
  Future<ExamResult?> getResultById(String resultId);
  Future<List<ExamResult>> getResultsByType({
    required String patientId,
    required String examTypeId,
  });
}
