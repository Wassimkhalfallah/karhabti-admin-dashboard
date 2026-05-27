class ReviewPro {
  final String id;
  final String userId;
  final String garageId;
  final String? rendezVousId;
  final int note;
  final String? commentaire;
  final bool estVisible;
  final String? reponseGarage;
  final DateTime createdAt;

  // Joined fields
  final String? clientNom;
  final String? garageNom;

  ReviewPro({
    required this.id,
    required this.userId,
    required this.garageId,
    this.rendezVousId,
    required this.note,
    this.commentaire,
    this.estVisible = true,
    this.reponseGarage,
    required this.createdAt,
    this.clientNom,
    this.garageNom,
  });

  factory ReviewPro.fromMap(Map<String, dynamic> m) {
    return ReviewPro(
      id: m['id'] ?? '',
      userId: m['user_id'] ?? '',
      garageId: m['garage_id'] ?? '',
      rendezVousId: m['rendez_vous_id'],
      note: m['note'] ?? 0,
      commentaire: m['commentaire'],
      estVisible: m['est_visible'] ?? true,
      reponseGarage: m['reponse_garage'],
      createdAt: DateTime.parse(m['created_at'] ?? DateTime.now().toIso8601String()),
      clientNom: m['client_nom'],
      garageNom: m['garage_nom'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'note': note,
      'commentaire': commentaire,
      'est_visible': estVisible,
      'reponse_garage': reponseGarage,
    };
  }

  String get stars => '★' * note + '☆' * (5 - note);

  bool get aReponse => reponseGarage != null && reponseGarage!.isNotEmpty;
}
