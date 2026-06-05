import 'package:flutter/material.dart' show IconData, Icons;

class VehiculeComplet {
  final Map<String, dynamic> voiture;
  final Map<String, dynamic>? client;
  final Map<String, dynamic>? facteur;
  final Map<String, dynamic>? prediction;
  final Map<String, dynamic>? maintenanceDates;

  const VehiculeComplet({
    required this.voiture,
    this.client,
    this.facteur,
    this.prediction,
    this.maintenanceDates,
  });

  String get immatriculation => voiture['immatriculation'] as String? ?? '';
}

/// Libellés français pour les champs `voiture`.
const voitureFieldLabels = <String, String>{
  'immatriculation': 'Immatriculation',
  'marque': 'Marque',
  'modele': 'Modèle',
  'moteur': 'Type de moteur',
  'annee': 'Année',
  'total_km': 'Kilométrage total',
  'daily_km': 'Kilométrage journalier',
  'poids': 'Poids (kg)',
};

/// Groupes pour la synthèse `facteur`.
class FacteurSection {
  final String title;
  final IconData icon;
  final List<FacteurField> fields;

  const FacteurSection({
    required this.title,
    required this.icon,
    required this.fields,
  });
}

class FacteurField {
  final String key;
  final String label;

  const FacteurField(this.key, this.label);
}

const facteurSections = <FacteurSection>[
  FacteurSection(
    title: 'Profil véhicule & usage',
    icon: Icons.speed_rounded,
    fields: [
      FacteurField('age_de_vehicule', 'Âge du véhicule (ans)'),
      FacteurField('total_km', 'Kilométrage total'),
      FacteurField('daily_km', 'Kilométrage journalier'),
      FacteurField('vehicle_weight', 'Poids véhicule (kg)'),
      FacteurField('type_de_moteur', 'Type de moteur'),
      FacteurField('time_conduite', 'Temps de conduite'),
    ],
  ),
  FacteurSection(
    title: 'Conditions de conduite',
    icon: Icons.cloud_rounded,
    fields: [
      FacteurField('temperature', 'Température'),
      FacteurField('meteo', 'Météo'),
      FacteurField('type_de_route', 'Type de route'),
      FacteurField('style_de_conduite', 'Style de conduite'),
      FacteurField('place_de_conduite', 'Lieu de conduite'),
      FacteurField('condition_de_utilisation', 'Condition d\'utilisation'),
    ],
  ),
  FacteurSection(
    title: 'Dates d\'installation / dernier entretien',
    icon: Icons.event_rounded,
    fields: [
      FacteurField('date_dernier_vidange', 'Dernier vidange'),
      FacteurField('date_installation_pneus', 'Installation pneus'),
      FacteurField('date_installation_frein', 'Installation freins'),
      FacteurField('date_installation_batterie', 'Installation batterie'),
      FacteurField('date_Installation_embrayage', 'Installation embrayage'),
      FacteurField('date_installation_courroie', 'Installation courroie'),
      FacteurField('date_installation_amortisseur', 'Installation amortisseurs'),
    ],
  ),
  FacteurSection(
    title: 'Qualité des pièces & fluides',
    icon: Icons.build_circle_outlined,
    fields: [
      FacteurField('marque_pneus', 'Marque pneus'),
      FacteurField('huile_power', 'Huile moteur'),
      FacteurField('qualite_de_la_piece_frein', 'Qualité freins'),
      FacteurField('qualite_de_piece_embrayage', 'Qualité embrayage'),
      FacteurField('qualite_piece_courroie', 'Qualité courroie'),
      FacteurField('qualite_de_la_piece_Amortisseur', 'Qualité amortisseurs'),
    ],
  ),
];

/// Métriques prédictives (table `predictions`).
class PredictionMetric {
  final String key;
  final String label;
  final double value;

  const PredictionMetric({
    required this.key,
    required this.label,
    required this.value,
  });
}

List<PredictionMetric> predictionMetricsFromMap(Map<String, dynamic>? p) {
  if (p == null) return [];
  return [
    PredictionMetric(key: 'tire_wear', label: 'Usure pneus', value: _num(p['tire_wear'])),
    PredictionMetric(key: 'battery_health', label: 'Santé batterie', value: _num(p['battery_health'])),
    PredictionMetric(key: 'brake_wear', label: 'Usure freins', value: _num(p['brake_wear'])),
    PredictionMetric(key: 'oil_change', label: 'Vidange huile', value: _num(p['oil_change'])),
    PredictionMetric(key: 'belt_risk', label: 'Risque courroie', value: _num(p['belt_risk'])),
    PredictionMetric(key: 'clutch_wear', label: 'Usure embrayage', value: _num(p['clutch_wear'])),
    PredictionMetric(
      key: 'ShockAbsorber_Wear',
      label: 'Usure amortisseurs',
      value: _num(p['ShockAbsorber_Wear']),
    ),
  ];
}

double _num(dynamic v) => (v as num?)?.toDouble() ?? 0;

/// Entrées `maintenance_dates` pour affichage chronologique.
class MaintenanceEvent {
  final String label;
  final String fieldKey;
  final DateTime? date;

  const MaintenanceEvent({
    required this.label,
    required this.fieldKey,
    this.date,
  });
}

List<MaintenanceEvent> maintenanceEventsFromMap(Map<String, dynamic>? m) {
  if (m == null) return [];
  const mapping = <String, String>{
    'changement_vidange': 'Vidange',
    'changement_pneus': 'Pneus',
    'changement_freins': 'Freins',
    'changement_batterie': 'Batterie',
    'changement_embrayage': 'Embrayage',
    'changement_courroie': 'Courroie',
    'changement_amortisseurs': 'Amortisseurs',
  };
  return mapping.entries.map((e) {
    return MaintenanceEvent(
      label: e.value,
      fieldKey: e.key,
      date: _parseDate(m[e.key]),
    );
  }).toList()
    ..sort((a, b) {
      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return b.date!.compareTo(a.date!);
    });
}

DateTime? _parseDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  try {
    return DateTime.parse(v.toString());
  } catch (_) {
    return null;
  }
}
