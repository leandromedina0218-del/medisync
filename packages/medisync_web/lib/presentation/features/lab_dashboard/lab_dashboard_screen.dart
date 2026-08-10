import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LabDashboardScreen extends StatefulWidget {
  const LabDashboardScreen({super.key});

  @override
  State<LabDashboardScreen> createState() => _LabDashboardScreenState();
}

class _LabDashboardScreenState extends State<LabDashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientIdCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  bool _isLoading = false;

  // Tipo de examen seleccionado
  String _selectedExamType = 'glucose';

  // Catálogo de exámenes disponibles
  final _examTypes = {
    'glucose': 'Glucosa en ayunas',
    'hemoglobin': 'Hemoglobina',
  };

  @override
  void dispose() {
    _patientIdCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  Future<void> _uploadResult() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final patientId = _patientIdCtrl.text.trim();
      final value = double.parse(_valueCtrl.text.trim());
      final examName = _examTypes[_selectedExamType]!;
      final techUid = FirebaseAuth.instance.currentUser?.uid ?? '';

      // Subir resultado a Firestore en tiempo real
      await FirebaseFirestore.instance
          .collection('results')
          .doc(patientId)
          .collection('examenes')
          .add({
        'examTypeId': _selectedExamType,
        'examTypeName': examName,
        'values': {_selectedExamType: value},
        'takenAt': Timestamp.now(),
        'status': 'published',
        'aiSummary': _generateSummary(_selectedExamType, value),
        'uploadedByUid': techUid,
      });

      // Limpiar formulario tras subir exitosamente
      _patientIdCtrl.clear();
      _valueCtrl.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Resultado subido correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Generar resumen automático según el valor ingresado
  String _generateSummary(String examType, double value) {
    if (examType == 'glucose') {
      if (value < 70)
        return 'Glucosa baja (hipoglucemia). Consulte a su médico.';
      if (value <= 100)
        return 'Glucosa en rango normal. Continúe con sus buenos hábitos.';
      if (value <= 125)
        return 'Glucosa ligeramente elevada. Reduzca consumo de azúcares.';
      return 'Glucosa en rango de diabetes. Consulte a su médico de inmediato.';
    } else {
      if (value < 12)
        return 'Hemoglobina baja. Se recomienda aumentar consumo de hierro.';
      if (value <= 17.5) return 'Hemoglobina en rango normal.';
      return 'Hemoglobina elevada. Consulte a su médico.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text(
          'Panel del Laboratorio',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          // Botón de cerrar sesión
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const _LoginPlaceholder(),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado de bienvenida
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF0EA5E9)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subir resultado de examen',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'El paciente verá el resultado en tiempo real',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Formulario de carga de resultados
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Datos del resultado',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // UID del paciente
                          TextFormField(
                            controller: _patientIdCtrl,
                            decoration: const InputDecoration(
                              labelText: 'UID del paciente',
                              hintText: 'Ej: ElEan1ssrRg0xRMjzfJpO48Juw72',
                              prefixIcon: Icon(Icons.person_outlined),
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Ingresa el UID del paciente'
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Selector de tipo de examen
                          DropdownButtonFormField<String>(
                            value: _selectedExamType,
                            decoration: const InputDecoration(
                              labelText: 'Tipo de examen',
                              prefixIcon: Icon(Icons.science_outlined),
                              border: OutlineInputBorder(),
                            ),
                            items: _examTypes.entries.map((e) {
                              return DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value),
                              );
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _selectedExamType = v);
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Valor del resultado
                          TextFormField(
                            controller: _valueCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Valor del resultado',
                              hintText: _selectedExamType == 'glucose'
                                  ? 'Ej: 95.0 mg/dL'
                                  : 'Ej: 14.2 g/dL',
                              prefixIcon: const Icon(Icons.numbers_outlined),
                              suffixText: _selectedExamType == 'glucose'
                                  ? 'mg/dL'
                                  : 'g/dL',
                              border: const OutlineInputBorder(),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Ingresa el valor';
                              }
                              if (double.tryParse(v) == null) {
                                return 'Ingresa un número válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Botón de subir resultado
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoading ? null : _uploadResult,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3A8A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.upload_rounded),
                              label: Text(
                                _isLoading
                                    ? 'Subiendo...'
                                    : 'Publicar resultado',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Información del rango de referencia
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rangos de referencia',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_selectedExamType == 'glucose') ...[
                          _RangeRow('Normal', '70 – 100 mg/dL', Colors.green),
                          _RangeRow(
                              'Elevado', '101 – 125 mg/dL', Colors.orange),
                          _RangeRow('Diabetes', '≥ 126 mg/dL', Colors.red),
                          _RangeRow(
                              'Hipoglucemia', '< 70 mg/dL', Colors.purple),
                        ] else ...[
                          _RangeRow(
                              'Normal (H)', '13.5 – 17.5 g/dL', Colors.green),
                          _RangeRow(
                              'Normal (M)', '12.0 – 15.5 g/dL', Colors.green),
                          _RangeRow('Bajo', '< 12.0 g/dL', Colors.red),
                          _RangeRow('Alto', '> 17.5 g/dL', Colors.orange),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget de fila de rango de referencia
Widget _RangeRow(String label, String range, Color color) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(range,
            style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

// Placeholder temporal para volver al login
class _LoginPlaceholder extends StatelessWidget {
  const _LoginPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Sesión cerrada — recarga la página')),
    );
  }
}
