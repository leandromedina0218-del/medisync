import 'package:flutter/material.dart';
import 'package:medisync_core/medisync_core.dart';
import '../widgets/trend_chart_widget.dart';

class ResultDetailScreen extends StatelessWidget {
  final ExamResult result;
  // Lista de todos los resultados del mismo tipo para el gráfico
  final List<ExamResult> allResultsOfType;

  const ResultDetailScreen({
    super.key,
    required this.result,
    required this.allResultsOfType,
  });

  @override
  Widget build(BuildContext context) {
    final value = result.values.values.firstOrNull;
    final isGlucose = result.examTypeId == 'glucose';

    // Color según tipo de examen
    final color = isGlucose ? const Color(0xFF0077B6) : const Color(0xFFE63946);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text(result.examTypeName),
        backgroundColor: const Color(0xFF0077B6),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card principal con el valor grande
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    value != null ? value.toStringAsFixed(1) : '--',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    isGlucose ? 'mg/dL' : 'g/dL',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(result.takenAt),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Resumen generado por IA
            if (result.aiSummary != null) ...[
              const Text(
                'Interpretación',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.psychology_outlined, color: color, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        result.aiSummary!,
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Gráfico de tendencia histórica
            const Text(
              'Tendencia histórica',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TrendChartWidget(
              results: allResultsOfType,
              examTypeId: result.examTypeId,
              unit: isGlucose ? 'mg/dL' : 'g/dL',
              normalMin: isGlucose ? 70 : 12.0,
              normalMax: isGlucose ? 100 : 17.5,
              color: color,
            ),
            const SizedBox(height: 20),

            // Tabla de rangos de referencia
            const Text(
              'Rangos de referencia',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _RangeRow(
                    label: 'Normal',
                    range: isGlucose ? '70 – 100' : '12.0 – 17.5',
                    color: Colors.green,
                  ),
                  const Divider(),
                  _RangeRow(
                    label: 'Elevado',
                    range: isGlucose ? '101 – 125' : '> 17.5',
                    color: Colors.orange,
                  ),
                  const Divider(),
                  _RangeRow(
                    label: 'Crítico',
                    range: isGlucose ? '≥ 126' : '< 7.0',
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Formatear fecha completa en español
  String _formatDate(DateTime date) {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }
}

// Fila de rango de referencia con indicador de color
class _RangeRow extends StatelessWidget {
  final String label;
  final String range;
  final Color color;

  const _RangeRow({
    required this.label,
    required this.range,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(
            range,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
