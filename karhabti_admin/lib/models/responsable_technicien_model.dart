class ResponsableTechnicien {
  final String id;
  final String? garageId;
  final String nomComplet;
  final String? telephone;
  final bool estActif;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ResponsableTechnicien({
    required this.id,
    this.garageId,
    required this.nomComplet,
    this.telephone,
    this.estActif = true,
    this.createdBy,
    required this.createdAt,
    this.updatedAt,
  });

  factory ResponsableTechnicien.fromJson(Map<String, dynamic> json) {
    return ResponsableTechnicien(
      id: json['id'] as String,
      garageId: json['garage_id'] as String?,
      nomComplet: json['nom_complet'] as String? ?? '',
      telephone: json['telephone'] as String?,
      estActif: json['est_actif'] as bool? ?? true,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'garage_id': garageId,
      'nom_complet': nomComplet,
      'telephone': telephone,
      'est_actif': estActif,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ResponsableTechnicien copyWith({
    String? id,
    String? garageId,
    String? nomComplet,
    String? telephone,
    bool? estActif,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ResponsableTechnicien(
      id: id ?? this.id,
      garageId: garageId ?? this.garageId,
      nomComplet: nomComplet ?? this.nomComplet,
      telephone: telephone ?? this.telephone,
      estActif: estActif ?? this.estActif,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  void operator [](String other) {}
}
