class PrestationPro {
  final String id;
  final String code;
  final String libelle;
  final String categorie;
  final String? icone;
  final double? prixDefaut;
  final int? dureeDefaut;
  final int tri;
  final bool actif;
  final DateTime createdAt;

  PrestationPro({
    required this.id,
    required this.code,
    required this.libelle,
    required this.categorie,
    this.icone,
    this.prixDefaut,
    this.dureeDefaut,
    this.tri = 0,
    this.actif = true,
    required this.createdAt,
  });

  factory PrestationPro.fromMap(Map<String, dynamic> m) {
    return PrestationPro(
      id: m['id'] ?? '',
      code: m['code'] ?? '',
      libelle: m['libelle'] ?? '',
      categorie: m['categorie'] ?? '',
      icone: m['icone'],
      prixDefaut:
          m['prix_defaut'] != null ? (m['prix_defaut']).toDouble() : null,
      dureeDefaut: m['duree_defaut'],
      tri: m['tri'] ?? 0,
      actif: m['actif'] ?? true,
      createdAt: DateTime.parse(
        m['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'libelle': libelle,
      'categorie': categorie,
      'icone': icone,
      'prix_defaut': prixDefaut,
      'duree_defaut': dureeDefaut,
      'tri': tri,
      'actif': actif,
    };
  }

  static const List<Map<String, dynamic>> defaultCatalog = [
    {
      'categorie': 'Mécanique',
      'prestations': [
        'Vidange',
        'Révision',
        'Freins',
        'Pneus',
        'Batterie',
        'Courroie',
        'Amortisseurs',
        'Embrayage',
      ],
    },
    {
      'categorie': 'Électronique',
      'prestations': ['Diagnostic', 'Climatisation', 'Boîte de vitesse'],
    },
    {
      'categorie': 'Carrosserie',
      'prestations': ['Carrosserie', 'Peinture'],
    },
    {
      'categorie': 'Divers',
      'prestations': ['Contrôle technique', 'Lavage', 'Dépannage', 'Autre'],
    },
  ];
}
