import 'package:equatable/equatable.dart';

class ExamResult extends Equatable {
  final String id;
  final String patientId;
  final String examType;
  final DateTime date;
  final Map<String, dynamic> parameters;
  final String status;
  final String? observations;

  const ExamResult({
    required this.id,
    required this.patientId,
    required this.examType,
    required this.date,
    required this.parameters,
    this.status = 'Pendiente',
    this.observations,
  });

  @override
  List<Object?> get props => [
        id,
        patientId,
        examType,
        date,
        parameters,
        status,
        observations,
      ];
}
