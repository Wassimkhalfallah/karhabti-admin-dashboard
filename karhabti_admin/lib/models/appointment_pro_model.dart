import 'package:flutter/material.dart';

enum AppointmentStatus {
  enAttente('en_attente', 'En attente', Color(0xFFFFC107)),
  confirme('confirme', 'Confirmé', Color(0xFF4CAF50)),
  annule('annule', 'Annulé', Color(0xFFE53935)),
  termine('termine', 'Terminé', Color(0xFF2196F3)),
  noShow('no_show', 'No show', Color(0xFF9E9E9E));

  final String value;
  final String label;
  final Color color;
  const AppointmentStatus(this.value, this.label, this.color);

  static AppointmentStatus fromString(String s) {
    return AppointmentStatus.values.firstWhere(
      (e) => e.value == s,
      orElse: () => AppointmentStatus.enAttente,
    );
  }
}

class AppointmentPro {
  final String id;
  final String userId;
  final String garageId;
  final String immatriculation;
  final String typePrestation;
  final String? prestationAutre;
  final DateTime dateRendezVous;
  final TimeOfDay heureRendezVous;
  final String? commentaire;
  final AppointmentStatus statut;
  final String? motifAnnulation;
  final String? annulePar;
  final bool rappelEnvoye;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined fields (populated by service)
  final String? clientNom;
  final String? garageNom;

  AppointmentPro({
    required this.id,
    required this.userId,
    required this.garageId,
    required this.immatriculation,
    required this.typePrestation,
    this.prestationAutre,
    required this.dateRendezVous,
    required this.heureRendezVous,
    this.commentaire,
    required this.statut,
    this.motifAnnulation,
    this.annulePar,
    this.rappelEnvoye = false,
    required this.createdAt,
    required this.updatedAt,
    this.clientNom,
    this.garageNom,
  });

  factory AppointmentPro.fromMap(Map<String, dynamic> m) {
    return AppointmentPro(
      id: m['id'] ?? '',
      userId: m['user_id'] ?? '',
      garageId: m['garage_id'] ?? '',
      immatriculation: m['immatriculation'] ?? '',
      typePrestation: m['type_prestation'] ?? '',
      prestationAutre: m['prestation_autre'],
      dateRendezVous: DateTime.parse(
        m['date_rendez_vous'] ?? DateTime.now().toIso8601String(),
      ),
      heureRendezVous: _parseTime(m['heure_rendez_vous']),
      commentaire: m['commentaire'],
      statut: AppointmentStatus.fromString(m['statut'] ?? 'en_attente'),
      motifAnnulation: m['motif_annulation'],
      annulePar: m['annule_par'],
      rappelEnvoye: m['rappel_envoye'] ?? false,
      createdAt: DateTime.parse(
        m['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        m['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      clientNom: m['client_nom'],
      garageNom: m['garage_nom'],
    );
  }

  static TimeOfDay _parseTime(dynamic t) {
    if (t is String) {
      final parts = t.split(':');
      return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 0,
        minute: int.tryParse(parts[1]) ?? 0,
      );
    }
    return const TimeOfDay(hour: 8, minute: 0);
  }

  String get heureStr =>
      '${heureRendezVous.hour.toString().padLeft(2, '0')}:${heureRendezVous.minute.toString().padLeft(2, '0')}';
}
