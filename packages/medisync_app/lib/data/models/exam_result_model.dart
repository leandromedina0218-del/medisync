import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medisync_core/medisync_core.dart';

class ExamResultModel extends ExamResult {
  const ExamResultModel({
    required super.id,
    required super.patientId,
    required super.examTypeId,
    required super.examTypeName,
    required super.values,
    required super.takenAt,
    super.aiSummary,
    required super.status,
    required super.uploadedByUid,
  });

  // Convertir documento de Firestore a modelo
  factory ExamResultModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
    String patientId,
  ) {
    final data = doc.data()!;

    // Convertir valores numéricos a double
    final rawValues = data['values'] as Map<String, dynamic>;
    final values = rawValues.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );

    // Mapear status string al enum
    final statusStr = data['status'] as String? ?? 'pending';
    final status = ResultStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => ResultStatus.pending,
    );

    return ExamResultModel(
      id: doc.id,
      patientId: patientId,
      examTypeId: data['examTypeId'] as String,
      examTypeName: data['examTypeName'] as String,
      values: values,
      takenAt: (data['takenAt'] as Timestamp).toDate(),
      aiSummary: data['aiSummary'] as String?,
      status: status,
      uploadedByUid: data['uploadedByUid'] as String? ?? '',
    );
  }

  // Convertir modelo a mapa para guardar en Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'examTypeId': examTypeId,
      'examTypeName': examTypeName,
      'values': values,
      'takenAt': Timestamp.fromDate(takenAt),
      'aiSummary': aiSummary,
      'status': status.name,
      'uploadedByUid': uploadedByUid,
    };
  }
}
