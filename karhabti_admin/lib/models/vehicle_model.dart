// Modèle pour les véhicules (table voiture)
class Vehicle {
  // Champs de la table voiture
  final String brand; // marque
  final String model; // modele
  final int year; // annee
  final String registrationNumber; // immatriculation (clé primaire)
  final double? totalKm; // total_km (peut être null)
  final double? dailyKm; // daily_km (peut être null)
  final String fuelType; // moteur dans la base de données (essence, diesel, électrique...)
  final double? poids; // champ présent dans la base mais absent du modèle précédent
  
  // Champs virtuels (non stockés directement dans la table voiture)
  final String userId; // user_id dans la table de liaison user_vehicules
  final String type; // particulier ou professionnel (champ visuel uniquement, non stocké en BDD)
  final String? imageUrl; // non stocké en BDD actuellement
  final DateTime createdAt; // peut être ajouté manuellement si non présent
  final DateTime? updatedAt; // peut être ajouté manuellement si non présent
  final List<String>? maintenanceHistory; // non stocké en BDD actuellement
  final String? clientName; // Nom du client provenant de la table client
  
  Vehicle({
    required this.brand,
    required this.model,
    required this.year,
    required this.registrationNumber,
    this.totalKm,
    this.dailyKm,
    required this.fuelType,
    this.poids,
    this.userId = '',
    this.type = 'particulier',
    this.imageUrl,
    DateTime? createdAt,
    this.updatedAt,
    this.maintenanceHistory,
    this.clientName,
  }) : createdAt = createdAt ?? DateTime.now();
  
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      brand: json['marque'] ?? '',
      model: json['modele'] ?? '',
      year: json['annee'] ?? 2000,
      registrationNumber: json['immatriculation'] ?? '',
      totalKm: json['total_km'] != null ? (json['total_km'] as num).toDouble() : null,
      dailyKm: json['daily_km'] != null ? (json['daily_km'] as num).toDouble() : null,
      fuelType: json['moteur'] ?? 'essence',  // Champ 'moteur' dans la BDD
      poids: json['poids'] != null ? (json['poids'] as num).toDouble() : null,
      userId: json['user_id'] ?? '',  // Provient de la table de liaison
      type: 'particulier',  // Valeur par défaut, non stockée en BDD
      imageUrl: null,  // Non disponible en BDD
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      maintenanceHistory: null,  // Non disponible en BDD
      clientName: json['client_name'],  // Ajouté manuellement après récupération du client
    );
  }
  
  Map<String, dynamic> toJson() {
    // Conversion en format compatible avec la table 'voiture'
    final Map<String, dynamic> data = {
      'marque': brand,
      'modele': model,
      'annee': year,
      'immatriculation': registrationNumber,
      'moteur': fuelType,  // 'moteur' dans la BDD, pas 'fuel_type'
    };
    
    // Ajout des champs optionnels s'ils ne sont pas null
    if (totalKm != null) data['total_km'] = totalKm;
    if (dailyKm != null) data['daily_km'] = dailyKm;
    if (poids != null) data['poids'] = poids;
    
    return data;
  }
  
  Vehicle copyWith({
    String? brand,
    String? model,
    int? year,
    String? registrationNumber,
    double? totalKm,
    double? dailyKm,
    String? fuelType,
    double? poids,
    String? userId,
    String? type,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? maintenanceHistory,
    String? clientName,
  }) {
    return Vehicle(
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      totalKm: totalKm ?? this.totalKm,
      dailyKm: dailyKm ?? this.dailyKm,
      fuelType: fuelType ?? this.fuelType,
      poids: poids ?? this.poids,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      maintenanceHistory: maintenanceHistory ?? this.maintenanceHistory,
      clientName: clientName ?? this.clientName,
    );
  }
}
