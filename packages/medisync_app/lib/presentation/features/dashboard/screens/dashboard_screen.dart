import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medisync_core/medisync_core.dart';
import '../../../../data/seed/firestore_seed.dart';
import '../../auth/providers/auth_provider.dart';
import '../../results/providers/results_provider.dart';
import '../../results/screens/result_detail_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchar resultados en tiempo real desde Firestore
    final resultsAsync = ref.watch(patientResultsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text(
          'MediSync',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0077B6),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Botón temporal de seed — se elimina en producción
          IconButton(
            icon: const Icon(Icons.upload_rounded),
            tooltip: 'Cargar datos de prueba',
            onPressed: () async {
              await FirestoreSeed.run();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Datos de prueba cargados'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: resultsAsync.when(
        // Spinner mientras carga Firestore
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF0077B6)),
        ),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (results) => _DashboardContent(results: results),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final List<ExamResult> results;

  const _DashboardContent({required this.results});

  @override
  Widget build(BuildContext context) {
    // Filtrar resultados por tipo para las cards de resumen
    final glucoseResults =
        results.where((r) => r.examTypeId == 'glucose').toList();
    final hemoglobinResults =
        results.where((r) => r.examTypeId == 'hemoglobin').toList();

    return RefreshIndicator(
      color: const Color(0xFF0077B6),
      onRefresh: () async {},
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner de bienvenida con saludo según hora
            _buildGreeting(),
            const SizedBox(height: 20),

            // Título sección de resumen
            const Text(
              'Último resultado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),

            // Cards de resumen lado a lado
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: 'Glucosa',
                    unit: 'mg/dL',
                    results: glucoseResults,
                    normalMin: 70,
                    normalMax: 100,
                    color: const Color(0xFF0077B6),
                    icon: Icons.water_drop_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: 'Hemoglobina',
                    unit: 'g/dL',
                    results: hemoglobinResults,
                    normalMin: 12,
                    normalMax: 17.5,
                    color: const Color(0xFFE63946),
                    icon: Icons.favorite_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Título historial completo
            const Text(
              'Historial de exámenes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),

            // Lista vacía o lista de resultados
            if (results.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No hay resultados aún',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: results.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final result = results[index];
                  // Filtrar todos los del mismo tipo para el gráfico
                  final allOfType = results
                      .where((r) => r.examTypeId == result.examTypeId)
                      .toList();
                  return _ResultCard(
                    result: result,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResultDetailScreen(
                          result: result,
                          allResultsOfType: allOfType,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // Banner de saludo con gradiente y hora del día
  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Buenos días'
        : hour < 18
            ? 'Buenas tardes'
            : 'Buenas noches';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0077B6), Color(0xFF00B4D8)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const Text(
                'Paciente',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Card de resumen con último valor e indicador de rango
class _SummaryCard extends StatelessWidget {
  final String title;
  final String unit;
  final List<ExamResult> results;
  final double normalMin;
  final double normalMax;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.unit,
    required this.results,
    required this.normalMin,
    required this.normalMax,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Primer resultado = el más reciente (lista viene ordenada desc)
    final latest = results.isNotEmpty ? results.first : null;
    final value = latest?.values.values.firstOrNull;

    // Verificar si el valor está en rango normal
    final isNormal = value != null && value >= normalMin && value <= normalMax;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Valor numérico grande
          Text(
            value != null ? value.toStringAsFixed(1) : '--',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(unit, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          // Etiqueta de estado del valor
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: value == null
                  ? Colors.grey.shade100
                  : isNormal
                      ? Colors.green.shade50
                      : Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value == null
                  ? 'Sin datos'
                  : isNormal
                      ? 'Normal'
                      : 'Fuera de rango',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: value == null
                    ? Colors.grey
                    : isNormal
                        ? Colors.green.shade700
                        : Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Card individual de resultado en el historial
class _ResultCard extends StatelessWidget {
  final ExamResult result;
  final VoidCallback onTap;

  const _ResultCard({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final value = result.values.values.firstOrNull;
    final isGlucose = result.examTypeId == 'glucose';

    // Color e ícono según tipo de examen
    final color = isGlucose ? const Color(0xFF0077B6) : const Color(0xFFE63946);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ícono circular con color del tipo de examen
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isGlucose ? Icons.water_drop_outlined : Icons.favorite_outline,
                color: color,
              ),
            ),
            const SizedBox(width: 16),
            // Nombre y fecha del examen
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.examTypeName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(result.takenAt),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            // Valor numérico a la derecha
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value != null ? value.toStringAsFixed(1) : '--',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: color,
                  ),
                ),
                Text(
                  isGlucose ? 'mg/dL' : 'g/dL',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // Formatear fecha abreviada en español
  String _formatDate(DateTime date) {
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
