import json
import openpyxl

# Tipos de campo por categoría — define cómo se ingresa cada resultado
FIELD_TYPES = {
    'HEMATOLOGÍA':              'numeric',
    'BIOQUÍMICA':               'numeric',
    'HORMONAS':                 'numeric',
    'MARCADORES TUMORALES':     'numeric',
    'INMUNOLOGÍA':              'qualitative',  # reactivo/no reactivo
    'HEPATITIS':                'qualitative',
    'MICROBIOLOGÍA':            'text',         # descripción libre
    'ESPECIALES / MOLECULARES': 'qualitative',
    'GENÉTICA':                 'text',
    'PERFIL ENA':               'qualitative',
    'SÍFILIS / VIH / INFECCIONES': 'qualitative',
    'ORINA':                    'numeric',
    'HECES':                    'text',
    'MEDICAMENTOS Y DROGAS':    'numeric',
    'VITAMINAS Y MINERALES':    'numeric',
    'PERFIL GENÉTICO PRENATAL': 'numeric',
    'PERFILES':                 'numeric',
    'OTROS':                    'numeric',
}

# Unidades por categoría
UNITS = {
    'HEMATOLOGÍA':              'varios',
    'BIOQUÍMICA':               'mg/dL',
    'HORMONAS':                 'mUI/mL',
    'MARCADORES TUMORALES':     'U/mL',
    'INMUNOLOGÍA':              'reactivo/no reactivo',
    'HEPATITIS':                'reactivo/no reactivo',
    'MICROBIOLOGÍA':            'texto libre',
    'ESPECIALES / MOLECULARES': 'reactivo/no reactivo',
    'GENÉTICA':                 'texto libre',
    'PERFIL ENA':               'reactivo/no reactivo',
    'SÍFILIS / VIH / INFECCIONES': 'reactivo/no reactivo',
    'ORINA':                    'mg/dL',
    'HECES':                    'texto libre',
    'MEDICAMENTOS Y DROGAS':    'µg/mL',
    'VITAMINAS Y MINERALES':    'ng/mL',
    'PERFIL GENÉTICO PRENATAL': 'MoM',
    'PERFILES':                 'varios',
    'OTROS':                    'varios',
}

wb = openpyxl.load_workbook('/mnt/user-data/uploads/AngloLab_Dashboard.xlsx', read_only=True)
ws = wb.active

catalog = []
current_category = 'OTROS'

for row in ws.iter_rows(min_row=5, values_only=True):
    code, name, category, notes, available = row[0], row[1], row[2], row[3], row[4]
    
    if code is None or name is None:
        continue
    if str(name).startswith('▸') or str(name).startswith('  ▸'):
        continue
    if category:
        current_category = str(category).strip()

    catalog.append({
        'codigoStella': str(code).strip(),
        'nombre': str(name).strip(),
        'categoria': current_category,
        'fieldType': FIELD_TYPES.get(current_category, 'numeric'),
        'unit': UNITS.get(current_category, 'varios'),
        'notas': str(notes).strip() if notes else '',
        'disponible': True,
    })

print(f'Total pruebas procesadas: {len(catalog)}')
print(json.dumps(catalog[:3], ensure_ascii=False, indent=2))

# Guardar como JSON
with open('scripts/exam_catalog.json', 'w', encoding='utf-8') as f:
    json.dump(catalog, f, ensure_ascii=False, indent=2)
    
print(f'Archivo guardado: scripts/exam_catalog.json')