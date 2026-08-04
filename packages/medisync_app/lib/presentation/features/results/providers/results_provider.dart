import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisync_core/medisync_core.dart';
import '../../../../data/repositories_impl/result_repository_impl.dart';
import '../../auth/providers/auth_provider.dart';

// Proveedor del repositorio de resultados
final resultRepositoryProvider = Provider<ResultRepository>((ref) {
  return ResultRepositoryImpl();
});

// Stream en tiempo real de todos los resultados del paciente
final patientResultsProvider = StreamProvider<List<ExamResult>>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    // Si hay uid, escuchar el stream de Firestore
    data: (uid) {
      if (uid == null) return const Stream.empty();
      return ref.watch(resultRepositoryProvider).watchPatientResults(uid);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

// Resultados filtrados por tipo — para el gráfico de tendencia
final resultsByTypeProvider =
    FutureProvider.family<List<ExamResult>, String>((ref, examTypeId) async {
  final uid = ref.read(authStateProvider).value;
  if (uid == null) return [];

  return ref.read(resultRepositoryProvider).getResultsByType(
        patientId: uid,
        examTypeId: examTypeId,
      );
});
