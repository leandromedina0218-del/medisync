import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirestoreSeed {
  static final _db = FirebaseFirestore.instance;

  static Future<void> run() async {
    // Verificar que hay usuario autenticado
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      debugPrint('❌ No hay usuario autenticado');
      return;
    }

    debugPrint('👤 Cargando datos para uid: $uid');

    // Referencia a la subcolección de exámenes del paciente
    final resultsRef =
        _db.collection('results').doc(uid).collection('examenes');

    // Limpiar resultados anteriores para evitar duplicados
    final existing = await resultsRef.get();
    for (final doc in existing.docs) {
      await doc.reference.delete();
    }

    // Datos seed de glucosa — evolución a lo largo del año
    final glucoseResults = [
      {
        'glucose': 98.0,
        'date': DateTime(2025, 8, 1),
        'summary': 'Glucosa en rango normal. Buenos hábitos alimenticios.',
      },
      {
        'glucose': 105.0,
        'date': DateTime(2025, 10, 1),
        'summary': 'Glucosa ligeramente elevada. Reduce consumo de azúcares.',
      },
      {
        'glucose': 112.0,
        'date': DateTime(2025, 12, 1),
        'summary': 'Rango de prediabetes. Consulta con tu médico.',
      },
      {
        'glucose': 108.0,
        'date': DateTime(2026, 2, 1),
        'summary': 'Leve mejoría. Sigue las indicaciones médicas.',
      },
      {
        'glucose': 95.0,
        'date': DateTime(2026, 4, 1),
        'summary': 'Excelente mejoría. Glucosa en rango normal.',
      },
      {
        'glucose': 91.0,
        'date': DateTime(2026, 7, 1),
        'summary': 'Glucosa perfectamente controlada. Continúa así.',
      },
    ];

    // Datos seed de hemoglobina
    final hemoglobinResults = [
      {
        'hemoglobin': 14.2,
        'date': DateTime(2025, 8, 1),
        'summary': 'Hemoglobina normal.',
      },
      {
        'hemoglobin': 13.8,
        'date': DateTime(2025, 12, 1),
        'summary': 'Hemoglobina ligeramente baja. Aumenta consumo de hierro.',
      },
      {
        'hemoglobin': 14.5,
        'date': DateTime(2026, 4, 1),
        'summary': 'Hemoglobina en rango normal.',
      },
    ];

    // Insertar resultados de glucosa
    for (final r in glucoseResults) {
      await resultsRef.add({
        'examTypeId': 'glucose',
        'examTypeName': 'Glucosa en ayunas',
        'values': {'glucose': r['glucose']},
        'takenAt': Timestamp.fromDate(r['date'] as DateTime),
        'status': 'published',
        'aiSummary': r['summary'],
        'uploadedByUid': 'lab_tech_seed',
      });
    }

    // Insertar resultados de hemoglobina
    for (final r in hemoglobinResults) {
      await resultsRef.add({
        'examTypeId': 'hemoglobin',
        'examTypeName': 'Hemoglobina',
        'values': {'hemoglobin': r['hemoglobin']},
        'takenAt': Timestamp.fromDate(r['date'] as DateTime),
        'status': 'published',
        'aiSummary': r['summary'],
        'uploadedByUid': 'lab_tech_seed',
      });
    }

    // Insertar catálogo de exámenes
    await _db.collection('exam_catalog').doc('glucose').set({
      'name': 'Glucosa en ayunas',
      'unit': 'mg/dL',
      'preparation': 'Ayuno mínimo de 8 horas',
      'ranges': {
        'adult_male': {
          'min': 70,
          'max': 100,
          'critical_low': 50,
          'critical_high': 126,
        },
        'adult_female': {
          'min': 70,
          'max': 100,
          'critical_low': 50,
          'critical_high': 126,
        },
      },
    });

    await _db.collection('exam_catalog').doc('hemoglobin').set({
      'name': 'Hemoglobina',
      'unit': 'g/dL',
      'preparation': 'No requiere ayuno',
      'ranges': {
        'adult_male': {
          'min': 13.5,
          'max': 17.5,
          'critical_low': 7.0,
          'critical_high': 20.0,
        },
        'adult_female': {
          'min': 12.0,
          'max': 15.5,
          'critical_low': 7.0,
          'critical_high': 20.0,
        },
      },
    });

    debugPrint('✅ Seed completado: ${glucoseResults.length} glucosa + '
        '${hemoglobinResults.length} hemoglobina');
  }
}
