import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:medisync_core/medisync_core.dart';

class TrendChartWidget extends StatelessWidget {
  final List<ExamResult> results;
  final String examTypeId;
  final String unit;
  final double normalMin;
  final double normalMax;
  final Color color;

  const TrendChartWidget({
    super.key,
    required this.results,
    required this.examTypeId,
    required this.unit,
    required this.normalMin,
    required this.normalMax,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Ordenar resultados por fecha ascendente para el gráfico
    final sorted = [...results]..sort((a, b) => a.takenAt.compareTo(b.takenAt));

    if (sorted.isEmpty) {
      return const Center(child: Text('Sin datos para graficar'));
    }

    // Construir puntos FlSpot con índice en X y valor en Y
    final spots = sorted.asMap().entries.map((entry) {
      final value = entry.value.values.values.firstOrNull ?? 0.0;
      return FlSpot(entry.key.toDouble(), value);
    }).toList();

    // Calcular rango del eje Y con margen superior e inferior
    final values = spots.map((s) => s.y).toList();
    final minY = (values.reduce((a, b) => a < b ? a : b) - 10)
        .clamp(0, double.infinity)
        .toDouble();
    final maxY = values.reduce((a, b) => a > b ? a : b) + 10;

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
          // Leyenda superior del gráfico
          Row(
            children: [
              Container(
                width: 12,
                height: 3,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Evolución ($unit)',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const Spacer(),
              // Indicador de zona normal
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'Rango normal',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Gráfico de línea principal
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                // Zona sombreada verde para el rango normal
                rangeAnnotations: RangeAnnotations(
                  horizontalRangeAnnotations: [
                    HorizontalRangeAnnotation(
                      y1: normalMin,
                      y2: normalMax,
                      color: Colors.green.withOpacity(0.1),
                    ),
                  ],
                ),
                // Líneas de cuadrícula horizontales suaves
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  // Eje Y con valores numéricos
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 10,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  // Eje X con mes abreviado de cada resultado
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= sorted.length) {
                          return const SizedBox();
                        }
                        final date = sorted[idx].takenAt;
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
                        return Text(
                          months[date.month - 1],
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  // Ocultar ejes derecho y superior
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    // Puntos rojos para valores fuera de rango normal
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, ___) {
                        final isOutOfRange =
                            spot.y < normalMin || spot.y > normalMax;
                        return FlDotCirclePainter(
                          radius: 5,
                          color: isOutOfRange ? Colors.red : Colors.white,
                          strokeWidth: 2,
                          strokeColor: isOutOfRange ? Colors.red : color,
                        );
                      },
                    ),
                    // Área sombreada bajo la línea
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.08),
                    ),
                  ),
                ],
                // Tooltip interactivo al tocar un punto
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final date = sorted[spot.x.toInt()].takenAt;
                        return LineTooltipItem(
                          '${spot.y.toStringAsFixed(1)} $unit\n'
                          '${date.day}/${date.month}/${date.year}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
