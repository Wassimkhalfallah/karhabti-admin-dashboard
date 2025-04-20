// Classe abstraite de base pour toutes les pièces
abstract class Piece {
  final String id;
  final String name;
  final double price;
  final String brand;
  final String description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  Piece({
    required this.id,
    required this.name,
    required this.price,
    required this.brand,
    required this.description,
    required this.createdAt,
    this.updatedAt,
  });
  
  Map<String, dynamic> toJson();
  
  static Piece fromJson(Map<String, dynamic> json, String type) {
    switch (type) {
      case 'pneu':
        return Pneu.fromJson(json);
      case 'vidange':
        return Vidange.fromJson(json);
      case 'amortisseur':
        return Amortisseur.fromJson(json);
      case 'batterie':
        return Batterie.fromJson(json);
      case 'embrayage':
        return Embrayage.fromJson(json);
      case 'frein':
        return Frein.fromJson(json);
      case 'courroie':
        return Courroie.fromJson(json);
      default:
        throw Exception('Type de pièce inconnu: $type');
    }
  }
}

// Modèle pour les pneus
class Pneu extends Piece {
  final String dimension;
  final String type; // été, hiver, 4 saisons
  final int indiceCharge;
  final String indiceVitesse;
  
  Pneu({
    required super.id,
    required super.name,
    required super.price,
    required super.brand,
    required super.description,
    required super.createdAt,
    super.updatedAt,
    required this.dimension,
    required this.type,
    required this.indiceCharge,
    required this.indiceVitesse,
  });
  
  factory Pneu.fromJson(Map<String, dynamic> json) {
    return Pneu(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      brand: json['brand'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      dimension: json['dimension'],
      type: json['type'],
      indiceCharge: json['indice_charge'],
      indiceVitesse: json['indice_vitesse'],
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'brand': brand,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'dimension': dimension,
      'type': type,
      'indice_charge': indiceCharge,
      'indice_vitesse': indiceVitesse,
      'piece_type': 'pneu',
    };
  }
}

// Modèle pour la vidange
class Vidange extends Piece {
  final String type; // synthétique, semi-synthétique, minérale
  final int viscositeW;
  final int viscositeN;
  final int capaciteLitres;
  
  Vidange({
    required super.id,
    required super.name,
    required super.price,
    required super.brand,
    required super.description,
    required super.createdAt,
    super.updatedAt,
    required this.type,
    required this.viscositeW,
    required this.viscositeN,
    required this.capaciteLitres,
  });
  
  factory Vidange.fromJson(Map<String, dynamic> json) {
    return Vidange(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      brand: json['brand'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      type: json['type'],
      viscositeW: json['viscosite_w'],
      viscositeN: json['viscosite_n'],
      capaciteLitres: json['capacite_litres'],
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'brand': brand,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'type': type,
      'viscosite_w': viscositeW,
      'viscosite_n': viscositeN,
      'capacite_litres': capaciteLitres,
      'piece_type': 'vidange',
    };
  }
}

// Modèle pour les amortisseurs
class Amortisseur extends Piece {
  final String type; // avant, arrière, etc.
  final String compatibilite; // modèles de voiture compatibles
  final bool gazSous; // amortisseur à gaz sous-pression
  
  Amortisseur({
    required super.id,
    required super.name,
    required super.price,
    required super.brand,
    required super.description,
    required super.createdAt,
    super.updatedAt,
    required this.type,
    required this.compatibilite,
    required this.gazSous,
  });
  
  factory Amortisseur.fromJson(Map<String, dynamic> json) {
    return Amortisseur(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      brand: json['brand'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      type: json['type'],
      compatibilite: json['compatibilite'],
      gazSous: json['gaz_sous'],
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'brand': brand,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'type': type,
      'compatibilite': compatibilite,
      'gaz_sous': gazSous,
      'piece_type': 'amortisseur',
    };
  }
}

// Modèle pour les batteries
class Batterie extends Piece {
  final int capaciteAh;
  final int courantDemarrage;
  final String tension; // 12V, 24V
  final String technologie; // plomb, AGM, EFB, lithium
  
  Batterie({
    required super.id,
    required super.name,
    required super.price,
    required super.brand,
    required super.description,
    required super.createdAt,
    super.updatedAt,
    required this.capaciteAh,
    required this.courantDemarrage,
    required this.tension,
    required this.technologie,
  });
  
  factory Batterie.fromJson(Map<String, dynamic> json) {
    return Batterie(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      brand: json['brand'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      capaciteAh: json['capacite_ah'],
      courantDemarrage: json['courant_demarrage'],
      tension: json['tension'],
      technologie: json['technologie'],
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'brand': brand,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'capacite_ah': capaciteAh,
      'courant_demarrage': courantDemarrage,
      'tension': tension,
      'technologie': technologie,
      'piece_type': 'batterie',
    };
  }
}

// Modèle pour les embrayages
class Embrayage extends Piece {
  final String typeVehicule; // diesel, essence
  final String diametre;
  final int nbDisques;
  
  Embrayage({
    required super.id,
    required super.name,
    required super.price,
    required super.brand,
    required super.description,
    required super.createdAt,
    super.updatedAt,
    required this.typeVehicule,
    required this.diametre,
    required this.nbDisques,
  });
  
  factory Embrayage.fromJson(Map<String, dynamic> json) {
    return Embrayage(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      brand: json['brand'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      typeVehicule: json['type_vehicule'],
      diametre: json['diametre'],
      nbDisques: json['nb_disques'],
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'brand': brand,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'type_vehicule': typeVehicule,
      'diametre': diametre,
      'nb_disques': nbDisques,
      'piece_type': 'embrayage',
    };
  }
}

// Modèle pour les freins
class Frein extends Piece {
  final String type; // disque, plaquette, tambour
  final String position; // avant, arrière
  final String diametre;
  final String epaisseur;
  
  Frein({
    required super.id,
    required super.name,
    required super.price,
    required super.brand,
    required super.description,
    required super.createdAt,
    super.updatedAt,
    required this.type,
    required this.position,
    required this.diametre,
    required this.epaisseur,
  });
  
  factory Frein.fromJson(Map<String, dynamic> json) {
    return Frein(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      brand: json['brand'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      type: json['type'],
      position: json['position'],
      diametre: json['diametre'],
      epaisseur: json['epaisseur'],
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'brand': brand,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'type': type,
      'position': position,
      'diametre': diametre,
      'epaisseur': epaisseur,
      'piece_type': 'frein',
    };
  }
}

// Modèle pour les courroies de distribution
class Courroie extends Piece {
  final int nbDents;
  final String largeur;
  final String longueur;
  final bool avecPompe; // kit avec pompe à eau
  
  Courroie({
    required super.id,
    required super.name,
    required super.price,
    required super.brand,
    required super.description,
    required super.createdAt,
    super.updatedAt,
    required this.nbDents,
    required this.largeur,
    required this.longueur,
    required this.avecPompe,
  });
  
  factory Courroie.fromJson(Map<String, dynamic> json) {
    return Courroie(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      brand: json['brand'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      nbDents: json['nb_dents'],
      largeur: json['largeur'],
      longueur: json['longueur'],
      avecPompe: json['avec_pompe'],
    );
  }
  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'brand': brand,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'nb_dents': nbDents,
      'largeur': largeur,
      'longueur': longueur,
      'avec_pompe': avecPompe,
      'piece_type': 'courroie',
    };
  }
}
