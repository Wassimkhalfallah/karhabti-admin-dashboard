class AffectationJointure {
  final int id;
  final int fkAffectationId;
  final dynamic fkPieceId;
  
  AffectationJointure({
    required this.id,
    required this.fkAffectationId,
    required this.fkPieceId,
  });
  
  factory AffectationJointure.fromJson(Map<String, dynamic> json, String pieceIdField) {
    return AffectationJointure(
      id: json['id'] as int,
      fkAffectationId: json['fk_affectation_id'] as int,
      fkPieceId: json[pieceIdField],
    );
  }
  
  Map<String, dynamic> toJson(String pieceIdField) {
    return {
      'id': id,
      'fk_affectation_id': fkAffectationId,
      pieceIdField: fkPieceId,
    };
  }
} 