class GaragePro {
  final String id;
  final String nom;
  final String slug;
  final String adresse;
  final String ville;
  final String? codePostal;
  final String? telephone;
  final String? telephoneSecondaire;
  final String? email;
  final String? siteWeb;
  final String? description;
  final String? googlePlaceId;
  final double latitude;
  final double longitude;
  final String? photoCouverture;
  final List<String> photos;
  final List<String> specialites;
  final Map<String, dynamic> horaires;
  final bool estVerifie;
  final bool estActif;
  final double noteMoyenne;
  final int nombreAvis;
  final int delaiConfirmation;
  final bool accepteRdvEnLigne;
  final DateTime createdAt;
  final DateTime updatedAt;

  GaragePro({
    required this.id,
    required this.nom,
    required this.slug,
    required this.adresse,
    required this.ville,
    this.codePostal,
    this.telephone,
    this.telephoneSecondaire,
    this.email,
    this.siteWeb,
    this.description,
    this.googlePlaceId,
    required this.latitude,
    required this.longitude,
    this.photoCouverture,
    this.photos = const [],
    this.specialites = const [],
    this.horaires = const {},
    this.estVerifie = false,
    this.estActif = true,
    this.noteMoyenne = 0,
    this.nombreAvis = 0,
    this.delaiConfirmation = 24,
    this.accepteRdvEnLigne = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GaragePro.fromMap(Map<String, dynamic> m) {
    return GaragePro(
      id: m['id'] ?? '',
      nom: m['nom'] ?? '',
      slug: m['slug'] ?? '',
      adresse: m['adresse'] ?? '',
      ville: m['ville'] ?? '',
      codePostal: m['code_postal'],
      telephone: m['telephone'],
      telephoneSecondaire: m['telephone_secondaire'],
      email: m['email'],
      siteWeb: m['site_web'],
      description: m['description'],
      latitude: (m['latitude'] ?? 0).toDouble(),
      longitude: (m['longitude'] ?? 0).toDouble(),
      photoCouverture: m['photo_couverture'],
      photos: m['photos'] != null ? List<String>.from(m['photos']) : [],
      specialites:
          m['specialites'] != null ? List<String>.from(m['specialites']) : [],
      horaires: m['horaires'] ?? {},
      estVerifie: m['est_verifie'] ?? false,
      estActif: m['est_actif'] ?? true,
      noteMoyenne: (m['note_moyenne'] ?? 0).toDouble(),
      nombreAvis: m['nombre_avis'] ?? 0,
      delaiConfirmation: m['delai_confirmation'] ?? 24,
      accepteRdvEnLigne: m['accepte_en_ligne'] ?? true,
      googlePlaceId: m['google_place_id'],
      createdAt: DateTime.parse(
        m['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        m['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nom': nom,
      'slug': slug,
      'adresse': adresse,
      'ville': ville,
      'code_postal': codePostal,
      'telephone': telephone,
      'telephone_secondaire': telephoneSecondaire,
      'email': email,
      'site_web': siteWeb,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'photo_couverture': photoCouverture,
      'photos': photos,
      'specialites': specialites,
      'horaires': horaires,
      'est_verifie': estVerifie,
      'est_actif': estActif,
      'delai_confirmation': delaiConfirmation,
      'accepte_en_ligne': accepteRdvEnLigne,
      'google_place_id': googlePlaceId,
    };
  }

  String getHoraireJour(String jour) {
    final h = horaires[jour.toLowerCase()];
    if (h == null) return 'Fermé';
    if (h is Map && h.containsKey('ouvert') && h['ouvert'] == false) {
      return 'Fermé';
    }
    if (h is Map && h.containsKey('debut') && h.containsKey('fin')) {
      return '${h['debut']} - ${h['fin']}';
    }
    return h.toString();
  }

  GaragePro copyWith({
    String? nom,
    String? slug,
    String? adresse,
    String? ville,
    String? codePostal,
    String? telephone,
    String? telephoneSecondaire,
    String? email,
    String? siteWeb,
    String? description,
    String? googlePlaceId,
    double? latitude,
    double? longitude,
    String? photoCouverture,
    List<String>? photos,
    List<String>? specialites,
    Map<String, dynamic>? horaires,
    bool? estVerifie,
    bool? estActif,
    double? noteMoyenne,
    int? nombreAvis,
    int? delaiConfirmation,
    bool? accepteRdvEnLigne,
  }) {
    return GaragePro(
      id: id,
      nom: nom ?? this.nom,
      slug: slug ?? this.slug,
      adresse: adresse ?? this.adresse,
      ville: ville ?? this.ville,
      codePostal: codePostal ?? this.codePostal,
      telephone: telephone ?? this.telephone,
      telephoneSecondaire: telephoneSecondaire ?? this.telephoneSecondaire,
      email: email ?? this.email,
      siteWeb: siteWeb ?? this.siteWeb,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      photoCouverture: photoCouverture ?? this.photoCouverture,
      photos: photos ?? this.photos,
      specialites: specialites ?? this.specialites,
      horaires: horaires ?? this.horaires,
      estVerifie: estVerifie ?? this.estVerifie,
      estActif: estActif ?? this.estActif,
      noteMoyenne: noteMoyenne ?? this.noteMoyenne,
      nombreAvis: nombreAvis ?? this.nombreAvis,
      delaiConfirmation: delaiConfirmation ?? this.delaiConfirmation,
      accepteRdvEnLigne: accepteRdvEnLigne ?? this.accepteRdvEnLigne,
      googlePlaceId: googlePlaceId ?? this.googlePlaceId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
