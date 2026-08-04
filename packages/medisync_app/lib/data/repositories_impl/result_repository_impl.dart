import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisync_core/medisync_core.dart';
import '../models/exam_result_model.dart';

class ResultRepositoryImpl implements ResultRepository {
  final FirebaseFirestore _firestore;

  ResultRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Referencia consistente a la subcolección de exámenes
  CollectionReference<Map<String, dynamic>> _examenesRef(String patientId) {
    return _firestore
        .collection('results')
        .doc(patientId)
        .collection('examenes');
  }

  @override
  Stream<List<ExamResult>> watchPatientResults(String patientId) {
    // Stream en tiempo real — se actualiza cuando Firestore cambia
    return _examenesRef(patientId)
        .orderBy('takenAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExamResultModel.fromFirestore(
                  doc as DocumentSnapshot<Map<String, dynamic>>,
                  patientId,
                ))
            .toList());
  }

  @override
  Future<void> uploadResult(ExamResult result) async {
    final model = result as ExamResultModel;
    await _examenesRef(result.patientId).add(model.toFirestore());
  }

  @override
  Future<ExamResult?> getResultById(String resultId) async {
    return null;
  }

  @override
  Future<List<ExamResult>> getResultsByType({
    required String patientId,
    required String examTypeId,
  }) async {
    // Resultados filtrados por tipo para el gráfico de tendencia
    final snapshot = await _examenesRef(patientId)
        .where('examTypeId', isEqualTo: examTypeId)
        .orderBy('takenAt', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => ExamResultModel.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>,
              patientId,
            ))
        .toList();
  }
}
