class PieceValidation {
  final String id;
  final String responsableId;
  final String immatriculation;
  final String pieceType;
  final int? pieceId;
  final String? rendezVousId;
  final DateTime dateRemplacement;
  final String? note;
  final DateTime? createdAt;

  const PieceValidation({
    required this.id,
    required this.responsableId,
    required this.immatriculation,
    required this.pieceType,
    this.pieceId,
    this.rendezVousId,
    required this.dateRemplacement,
    this.note,
    this.createdAt,
  });

  factory PieceValidation.fromJson(Map<String, dynamic> json) {
    return PieceValidation(
      id: json['id'] as String,
      responsableId: json['responsable_id'] as String? ?? '',
      immatriculation: json['immatriculation'] as String? ?? '',
      pieceType: json['piece_type'] as String? ?? '',
      pieceId: json['piece_id'] as int?,
      rendezVousId: json['rendez_vous_id'] as String?,
      dateRemplacement: DateTime.parse(
        json['date_remplacement'] as String? ?? DateTime.now().toIso8601String(),
      ),
      note: json['note'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'responsable_id': responsableId,
      'immatriculation': immatriculation,
      'piece_type': pieceType,
      'piece_id': pieceId,
      'rendez_vous_id': rendezVousId,
      'date_remplacement': dateRemplacement.toIso8601String(),
      'note': note,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
