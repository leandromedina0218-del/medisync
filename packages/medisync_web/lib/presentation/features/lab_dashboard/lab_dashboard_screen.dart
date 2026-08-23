import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../data/seed/exam_catalog_seed.dart';

class LabDashboardScreen extends StatefulWidget {
  const LabDashboardScreen({super.key});

  @override
  State<LabDashboardScreen> createState() => _LabDashboardScreenState();
}

class _LabDashboardScreenState extends State<LabDashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientIdCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _textResultCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingCatalog = true;
  String _qualitativeResult = 'Reactivo';

  // Catálogo completo y filtrado
  List<Map<String, dynamic>> _catalog = [];
  List<Map<String, dynamic>> _filtered = [];
  Map<String, dynamic>? _selectedExam;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
    _searchCtrl.addListener(_filterCatalog);
  }

  @override
  void dispose() {
    _patientIdCtrl.dispose();
    _valueCtrl.dispose();
    _textResultCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // Cargar catálogo completo desde Firestore
  Future<void> _loadCatalog() async {
    setState(() => _isLoadingCatalog = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('exam_catalog')
          .orderBy('nombre')
          .get();

      final list = snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();

      setState(() {
        _catalog = list;
        _filtered = list;
        _isLoadingCatalog = false;
      });
    } catch (e) {
      setState(() => _isLoadingCatalog = false);
    }
  }

  // Filtrar catálogo según búsqueda
  void _filterCatalog() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _catalog.where((exam) {
        final nombre = (exam['nombre'] as String).toLowerCase();
        final codigo = (exam['codigoPrueba'] as String).toLowerCase();
        final cat = (exam['categoria'] as String).toLowerCase();
        return nombre.contains(query) ||
            codigo.contains(query) ||
            cat.contains(query);
      }).toList();
    });
  }

  // Subir resultado a Firestore
  Future<void> _uploadResult() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedExam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un tipo de examen'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final patientId = _patientIdCtrl.text.trim();
      final techUid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final fieldType = _selectedExam!['fieldType'] as String;
      final examName = _selectedExam!['nombre'] as String;
      final examCode = _selectedExam!['codigoPrueba'] as String;
      final unit = _selectedExam!['unit'] as String;

      // Construir el valor según el tipo de campo
      dynamic resultValue;
      String aiSummary;

      if (fieldType == 'numeric') {
        final numVal = double.parse(_valueCtrl.text.trim());
        resultValue = {examCode: numVal};
        aiSummary =
            'Resultado de $examName: ${_valueCtrl.text.trim()} $unit. Consulte con su médico para interpretación.';
      } else if (fieldType == 'qualitative') {
        resultValue = {examCode: _qualitativeResult};
        aiSummary =
            'Resultado de $examName: $_qualitativeResult. Consulte con su médico para interpretación.';
      } else {
        resultValue = {examCode: _textResultCtrl.text.trim()};
        aiSummary =
            'Resultado de $examName disponible. Consulte con su médico para interpretación.';
      }

      // Guardar en Firestore
      await FirebaseFirestore.instance
          .collection('results')
          .doc(patientId)
          .collection('examenes')
          .add({
        'examTypeId': examCode,
        'examTypeName': examName,
        'categoria': _selectedExam!['categoria'],
        'values': resultValue,
        'unit': unit,
        'takenAt': Timestamp.now(),
        'status': 'published',
        'aiSummary': aiSummary,
        'uploadedByUid': techUid,
      });

      // Limpiar formulario
      _patientIdCtrl.clear();
      _valueCtrl.clear();
      _textResultCtrl.clear();
      setState(() => _selectedExam = null);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Resultado de $examName publicado'),
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
          // Botón para recargar catálogo desde Firestore
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar catálogo',
            onPressed: _loadCatalog,
          ),
          // Botón seed del catálogo — solo usarlo una vez
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            tooltip: 'Cargar catálogo completo',
            onPressed: () async {
              await ExamCatalogSeed.run();
              await _loadCatalog();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ 589 pruebas cargadas en Firestore'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
          // Cerrar sesión
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const _SessionClosed(),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: _isLoadingCatalog
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF1E3A8A)),
                  SizedBox(height: 16),
                  Text('Cargando catálogo de pruebas...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Panel izquierdo — buscador de pruebas
                      Expanded(
                        flex: 2,
                        child: _buildCatalogPanel(),
                      ),
                      const SizedBox(width: 20),
                      // Panel derecho — formulario de resultado
                      Expanded(
                        flex: 3,
                        child: _buildResultForm(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // Panel de búsqueda del catálogo
  Widget _buildCatalogPanel() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Catálogo (${_catalog.length} pruebas)',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            // Buscador
            TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre o código...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Lista filtrada de pruebas
            SizedBox(
              height: 500,
              child: ListView.builder(
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final exam = _filtered[index];
                  final isSelected =
                      _selectedExam?['codigoPrueba'] == exam['codigoPrueba'];
                  return ListTile(
                    dense: true,
                    selected: isSelected,
                    selectedTileColor: const Color(0xFF1E3A8A).withOpacity(0.1),
                    title: Text(
                      exam['nombre'] as String,
                      style: const TextStyle(fontSize: 13),
                    ),
                    subtitle: Text(
                      '${exam["codigoPrueba"]} · ${exam["categoria"]}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedExam = exam;
                        _valueCtrl.clear();
                        _textResultCtrl.clear();
                        _qualitativeResult = 'Reactivo';
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Formulario dinámico según el tipo de examen seleccionado
  Widget _buildResultForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header del examen seleccionado
              if (_selectedExam != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF0EA5E9)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedExam!['nombre'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_selectedExam!["codigoPrueba"]} · ${_selectedExam!["categoria"]}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ] else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.touch_app, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'Selecciona una prueba del catálogo',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // UID del paciente
              TextFormField(
                controller: _patientIdCtrl,
                decoration: const InputDecoration(
                  labelText: 'UID del paciente',
                  prefixIcon: Icon(Icons.person_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ingresa el UID' : null,
              ),
              const SizedBox(height: 16),

              // Campo dinámico según fieldType
              if (_selectedExam != null) ...[
                if (_selectedExam!['fieldType'] == 'numeric') ...[
                  TextFormField(
                    controller: _valueCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Valor del resultado',
                      suffixText: _selectedExam!['unit'] as String,
                      prefixIcon: const Icon(Icons.numbers),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Ingresa el valor';
                      if (double.tryParse(v) == null) {
                        return 'Número válido requerido';
                      }
                      return null;
                    },
                  ),
                ] else if (_selectedExam!['fieldType'] == 'qualitative') ...[
                  DropdownButtonFormField<String>(
                    value: _qualitativeResult,
                    decoration: const InputDecoration(
                      labelText: 'Resultado',
                      prefixIcon: Icon(Icons.science_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Reactivo',
                        child: Text('Reactivo'),
                      ),
                      DropdownMenuItem(
                        value: 'No Reactivo',
                        child: Text('No Reactivo'),
                      ),
                      DropdownMenuItem(
                        value: 'Indeterminado',
                        child: Text('Indeterminado'),
                      ),
                      DropdownMenuItem(
                        value: 'Positivo',
                        child: Text('Positivo'),
                      ),
                      DropdownMenuItem(
                        value: 'Negativo',
                        child: Text('Negativo'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _qualitativeResult = v);
                    },
                  ),
                ] else ...[
                  TextFormField(
                    controller: _textResultCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Resultado / Descripción',
                      prefixIcon: Icon(Icons.description_outlined),
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Ingresa el resultado' : null,
                  ),
                ],
                const SizedBox(height: 24),

                // Botón publicar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _uploadResult,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                      _isLoading ? 'Publicando...' : 'Publicar resultado',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionClosed extends StatelessWidget {
  const _SessionClosed();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Sesión cerrada — recarga la página'),
      ),
    );
  }
}
