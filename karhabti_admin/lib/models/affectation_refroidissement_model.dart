class AffectationRefroidissement {
  final int id;
  final int fkAffectationId;
  final String fkRefroidissementId;
  
  AffectationRefroidissement({
    required this.id,
    required this.fkAffectationId,
    required this.fkRefroidissementId,
  });
  
  factory AffectationRefroidissement.fromJson(Map<String, dynamic> json) {
    return AffectationRefroidissement(
      id: json['id'] as int,
      fkAffectationId: json['fk_affectation_id'] as int,
      fkRefroidissementId: json['fk_refroidissement_id'] as String,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fk_affectation_id': fkAffectationId,
      'fk_refroidissement_id': fkRefroidissementId,
    };
  }
} 