class PieceRecommendation {
  final String id;
  final String responsableId;
  final String immatriculation;
  final String pieceType;
  final int? pieceId;
  final String recommendation;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PieceRecommendation({
    required this.id,
    required this.responsableId,
    required this.immatriculation,
    required this.pieceType,
    this.pieceId,
    required this.recommendation,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PieceRecommendation.fromJson(Map<String, dynamic> json) {
    return PieceRecommendation(
      id: json['id'] as String,
      responsableId: json['responsable_id'] as String? ?? '',
      immatriculation: json['immatriculation'] as String? ?? '',
      pieceType: json['piece_type'] as String? ?? '',
      pieceId: json['piece_id'] as int?,
      recommendation: json['recommendation'] as String? ?? '',
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'responsable_id': responsableId,
      'immatriculation': immatriculation,
      'piece_type': pieceType,
      'piece_id': pieceId,
      'recommendation': recommendation,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PieceRecommendation copyWith({
    String? id,
    String? responsableId,
    String? immatriculation,
    String? pieceType,
    int? pieceId,
    String? recommendation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PieceRecommendation(
      id: id ?? this.id,
      responsableId: responsableId ?? this.responsableId,
      immatriculation: immatriculation ?? this.immatriculation,
      pieceType: pieceType ?? this.pieceType,
      pieceId: pieceId ?? this.pieceId,
      recommendation: recommendation ?? this.recommendation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
