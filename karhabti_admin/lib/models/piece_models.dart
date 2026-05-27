// Modèles pour toutes les pièces basés sur les tables Supabase

// Classe abstraite de base pour toutes les pièces
abstract class Piece {
  final String id;
  final String imageUrl;
  final String reference;
  final String marque;
  final double prix;
  final String? paysConstructeur;
  final String? type;

  Piece({
    required this.id,
    required this.imageUrl,
    required this.reference,
    required this.marque,
    required this.prix,
    this.paysConstructeur,
    this.type,
  });

  Map<String, dynamic> toJson();
}

// Modèle pour les pneus
class Pneu extends Piece {
  final String? dimension;
  @override
  final String? type;
  final String? qualite;
  final String? position;

  Pneu({
    required super.id,
    required super.imageUrl,
    required super.reference,
    required super.marque,
    required super.prix,
    super.paysConstructeur,
    this.dimension,
    this.type,
    this.qualite,
    this.position,
  });

  factory Pneu.fromJson(Map<String, dynamic> json) {
    return Pneu(
      id: json['id']?.toString() ?? '',
      imageUrl: json['image_url'] ?? '',
      reference: json['reference'] ?? '',
      marque: json['marque'] ?? '',
      prix: (json['prix'] is num) ? (json['prix'] as num).toDouble() : 0.0,
      paysConstructeur: json['pays_constructeur'],
      dimension: json['dimension'],
      type: json['type'],
      qualite: json['qualite'],
      position: json['position'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
      'reference': reference,
      'marque': marque,
      'prix': prix,
      'pays_constructeur': paysConstructeur,
      'dimension': dimension,
      'type': type,
      'qualite': qualite,
      'position': position,
    };
  }
}

// Modèle pour l'huile moteur
class HuileMoteur extends Piece {
  @override
  final String? type;
  final String? viscosite;
  final double? poids;

  HuileMoteur({
    required super.id,
    required super.imageUrl,
    required super.reference,
    required super.marque,
    required super.prix,
    super.paysConstructeur,
    this.type,
    this.viscosite,
    this.poids,
  });

  factory HuileMoteur.fromJson(Map<String, dynamic> json) {
    return HuileMoteur(
      id: json['id']?.toString() ?? '',
      imageUrl: json['image_url'] ?? '',
      reference: json['reference'] ?? '',
      marque: json['marque'] ?? '',
      prix: (json['prix'] is num) ? (json['prix'] as num).toDouble() : 0.0,
      paysConstructeur: json['pays_constructeur'],
      type: json['type'],
      viscosite: json['viscosite'],
      poids: (json['poids'] is num) ? (json['poids'] as num).toDouble() : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
      'reference': reference,
      'marque': marque,
      'prix': prix,
      'pays_constructeur': paysConstructeur,
      'type': type,
      'viscosite': viscosite,
      'poids': poids,
    };
  }
}

// Modèle pour les filtres
class Filtre extends Piece {
  final String nom;

  Filtre({
    required super.id,
    required super.imageUrl,
    required super.reference,
    required super.marque,
    required super.prix,
    super.paysConstructeur,
    required this.nom,
  });

  factory Filtre.fromJson(Map<String, dynamic> json) {
    return Filtre(
      id: json['id']?.toString() ?? '',
      imageUrl: json['image_url'] ?? '',
      reference: json['reference'] ?? '',
      marque: json['marque'] ?? '',
      prix: (json['prix'] is num) ? (json['prix'] as num).toDouble() : 0.0,
      paysConstructeur: json['pays_constructeur'],
      nom: json['nom'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
      'reference': reference,
      'marque': marque,
      'prix': prix,
      'pays_constructeur': paysConstructeur,
      'nom': nom,
    };
  }
}

// Modèle pour l'eau de refroidissement
class EauRefroidissement extends Piece {
  final String nom;
  @override
  final String? type;
  final double? poids;

  EauRefroidissement({
    required super.id,
    required super.imageUrl,
    required super.reference,
    required super.marque,
    required super.prix,
    super.paysConstructeur,
    required this.nom,
    this.type,
    this.poids,
  });

  factory EauRefroidissement.fromJson(Map<String, dynamic> json) {
    // Récupérer l'ID en priorité depuis 'id'
    String id = '';
    if (json.containsKey('id')) {
      id = json['id']?.toString() ?? '';
    }

    // Ensure reference is properly converted to string
    String reference = '';
    if (json.containsKey('reference')) {
      reference = json['reference']?.toString() ?? '';
    }

    // Ensure all numeric fields are properly converted
    double prix = 0.0;
    if (json.containsKey('prix') && json['prix'] != null) {
      prix = (json['prix'] is num) ? (json['prix'] as num).toDouble() : 0.0;
    }

    double? poids;
    if (json.containsKey('poids') && json['poids'] != null) {
      poids = (json['poids'] is num) ? (json['poids'] as num).toDouble() : null;
    }

    return EauRefroidissement(
      id: id,
      imageUrl: json['image_url'] ?? '',
      reference: reference,
      marque: json['marque'] ?? '',
      prix: prix,
      paysConstructeur: json['pays_constructeur'],
      nom: json['nom'] ?? '',
      type: json['type'],
      poids: poids,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'image_url': imageUrl,
      'reference': reference,
      'marque': marque,
      'prix': prix,
      'nom': nom,
    };

    // Include ID only when updating existing records
    if (id.isNotEmpty) {
      json['id'] = id;
    }

    // Add optional fields only if they exist
    if (paysConstructeur != null) json['pays_constructeur'] = paysConstructeur;
    if (type != null) json['type'] = type;
    if (poids != null) json['poids'] = poids;

    return json;
  }
}

// Modèle pour les amortisseurs
class Amortisseur extends Piece {
  final String? position;

  Amortisseur({
    required super.id,
    required super.imageUrl,
    required super.reference,
    required super.marque,
    required super.prix,
    required super.type,
    super.paysConstructeur,
    this.position,
  });

  factory Amortisseur.fromJson(Map<String, dynamic> json) {
    return Amortisseur(
      id: json['id']?.toString() ?? '',
      imageUrl: json['image_url'] ?? '',
      reference: json['reference'] ?? '',
      marque: json['marque'] ?? '',
      type: json['type'] ?? '',
      prix: (json['prix'] is num) ? (json['prix'] as num).toDouble() : 0.0,
      paysConstructeur: json['pays_constructeur'],
      position: json['position'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
      'reference': reference,
      'marque': marque,
      'prix': prix,
      'type': type,
      'pays_constructeur': paysConstructeur,
      'position': position,
    };
  }
}

// Modèle pour les batteries
class Batterie extends Piece {
  final String? capacite;
  final String? demarrage;

  Batterie({
    required super.id,
    required super.imageUrl,
    required super.reference,
    required super.marque,
    required super.prix,
    super.paysConstructeur,
    this.capacite,
    this.demarrage,
  });

  factory Batterie.fromJson(Map<String, dynamic> json) {
    return Batterie(
      id: json['id']?.toString() ?? '',
      imageUrl: json['image_url'] ?? '',
      reference: json['reference'] ?? '',
      marque: json['marque'] ?? '',
      prix: (json['prix'] is num) ? (json['prix'] as num).toDouble() : 0.0,
      paysConstructeur: json['pays_constructeur'],
      capacite: json['capacite'],
      demarrage: json['demarrage'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
      'reference': reference,
      'marque': marque,
      'prix': prix,
      'pays_constructeur': paysConstructeur,
      'capacite': capacite,
      'demarrage': demarrage,
    };
  }
}

// Modèle pour les embrayages
class Embrayage extends Piece {
  final double? diametre;

  Embrayage({
    required super.id,
    required super.imageUrl,
    required super.reference,
    required super.marque,
    required super.prix,
    super.paysConstructeur,
    this.diametre,
  });

  factory Embrayage.fromJson(Map<String, dynamic> json) {
    return Embrayage(
      id: json['id']?.toString() ?? '',
      imageUrl: json['image_url'] ?? '',
      reference: json['reference'] ?? '',
      marque: json['marque'] ?? '',
      prix: (json['prix'] is num) ? (json['prix'] as num).toDouble() : 0.0,
      paysConstructeur: json['pays_constructeur'],
      diametre:
          (json['diametre'] is num)
              ? (json['diametre'] as num).toDouble()
              : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
      'reference': reference,
      'marque': marque,
      'prix': prix,
      'pays_constructeur': paysConstructeur,
      'diametre': diametre,
    };
  }
}

// Modèle pour les freins
class Frein extends Piece {
  @override
  final String? type;
  final String? position;

  Frein({
    required super.id,
    required super.imageUrl,
    required super.reference,
    required super.marque,
    required super.prix,
    super.paysConstructeur,
    this.type,
    this.position,
  });

  factory Frein.fromJson(Map<String, dynamic> json) {
    return Frein(
      id: json['id']?.toString() ?? '',
      imageUrl: json['image_url'] ?? '',
      reference: json['reference'] ?? '',
      marque: json['marque'] ?? '',
      prix: (json['prix'] is num) ? (json['prix'] as num).toDouble() : 0.0,
      paysConstructeur: json['pays_constructeur'],
      type: json['type'],
      position: json['position'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
      'reference': reference,
      'marque': marque,
      'prix': prix,
      'pays_constructeur': paysConstructeur,
      'type': type,
      'position': position,
    };
  }
}

// Modèle pour les courroies
class Courroie extends Piece {
  final int? nombreDents;
  final String? pompe;

  Courroie({
    required super.id,
    required super.imageUrl,
    required super.reference,
    required super.marque,
    required super.prix,
    super.paysConstructeur,
    this.nombreDents,
    this.pompe,
  });

  factory Courroie.fromJson(Map<String, dynamic> json) {
    return Courroie(
      id: json['id']?.toString() ?? '',
      imageUrl: json['image_url'] ?? '',
      reference: json['reference'] ?? '',
      marque: json['marque'] ?? '',
      prix: (json['prix'] is num) ? (json['prix'] as num).toDouble() : 0.0,
      paysConstructeur: json['pays_constructeur'],
      nombreDents:
          json['nombre_dents'] is num
              ? (json['nombre_dents'] as num).toInt()
              : null,
      pompe: json['pompe'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
      'reference': reference,
      'marque': marque,
      'prix': prix,
      'pays_constructeur': paysConstructeur,
      'nombre_dents': nombreDents,
      'pompe': pompe,
    };
  }
}
