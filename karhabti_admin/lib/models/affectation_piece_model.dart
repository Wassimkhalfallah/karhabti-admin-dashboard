import 'package:flutter/foundation.dart';

class AffectationPiece {
  final int id;
  final String fkImmatriculation;
  List<int> fkEmbrayage;
  List<int> fkPneus;
  List<int> fkBatterie;
  List<int> fkAmortisseurs;
  List<int> fkFreins;
  List<int> fkCourroie;
  List<int> fkHuileMoteur;
  List<String> fkRefroidissement;
  List<int> fkFiltres;

  AffectationPiece({
    required this.id,
    required this.fkImmatriculation,
    required this.fkEmbrayage,
    required this.fkPneus,
    required this.fkBatterie,
    required this.fkAmortisseurs,
    required this.fkFreins,
    required this.fkCourroie,
    required this.fkHuileMoteur,
    required List<dynamic> fkRefroidissement,
    required this.fkFiltres,
  }) : fkRefroidissement =
          fkRefroidissement.map((e) => e.toString()).toList();

  factory AffectationPiece.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      print(
      'DEBUG FROMJSON: Type de fk_refroidissement: ${json['fk_refroidissement']?.runtimeType}',
    );
    }
    if (kDebugMode) {
      print(
        'DEBUG FROMJSON: Valeur de fk_refroidissement: ${json['fk_refroidissement']}',
      );
    }

    try {
      return AffectationPiece(
        id: json['id'] as int,
        fkImmatriculation: json['fk_immatriculation'] as String,
        fkEmbrayage: _parseIntList(json['fk_embrayage']),
        fkPneus: _parseIntList(json['fk_pneus']),
        fkBatterie: _parseIntList(json['fk_batterie']),
        fkAmortisseurs: _parseIntList(json['fk_amourtisseurs']),
        fkFreins: _parseIntList(json['fk_freins']),
        fkCourroie: _parseIntList(json['fk_courroie']),
        fkHuileMoteur: _parseIntList(json['fk_huile_moteur']),
        fkRefroidissement: _parseRefroidissementList(
          json['fk_refroidissement'],
        ),
        fkFiltres: _parseIntList(json['fk_filtres']),
      );
    } catch (e) {
      if (kDebugMode) {
        print('ERREUR dans fromJson: $e');
      }
      // Créer une instance avec des valeurs par défaut en cas d'erreur
      return AffectationPiece(
        id: json['id'] as int,
        fkImmatriculation: json['fk_immatriculation'] as String,
        fkEmbrayage: [],
        fkPneus: [],
        fkBatterie: [],
        fkAmortisseurs: [],
        fkFreins: [],
        fkCourroie: [],
        fkHuileMoteur: [],
        fkRefroidissement:
            json['fk_refroidissement'] != null
                ? [json['fk_refroidissement'].toString()]
                : [],
        fkFiltres: [],
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fk_immatriculation': fkImmatriculation,
      // Les champs suivants sont gérés par les tables de jointure:
      // fk_embrayage, fk_pneus, fk_batterie, fk_amortisseurs,
      // fk_freins, fk_courroie, fk_huile_moteur, fk_refroidissement, fk_filtres
    };
  }

  // Méthodes d'aide pour parser les données JSON
  static List<int> _parseIntList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e as int).toList();
    if (value is int) return [value];
    return [];
  }


  static List<String> _parseRefroidissementList(dynamic value) {
    if (kDebugMode) {
      print(
        'DEBUG: Type reçu dans _parseRefroidissementList: ${value.runtimeType}',
      );
      print('DEBUG: Valeur reçue: $value');
    }

    if (value == null) return [];

    // Si c'est déjà une liste, convertir tous les éléments en String
    if (value is List) {
      final result = value.map((e) => e.toString()).toList();
      if (kDebugMode) {
        print('DEBUG: Converti liste en: $result');
      }
      return result;
    }

    // Si c'est une chaîne contenant des délimiteurs
    if (value is String && value.contains('//')) {
      final result = value.split('//');
      if (kDebugMode) {
        print('DEBUG: Divisé string en: $result');
      }
      return result;
    }

    // Cas d'un seul élément ou autre type
    final result = [value.toString()];
    if (kDebugMode) {
      print('DEBUG: Converti simple valeur en: $result');
    }
    return result;
  }
}
