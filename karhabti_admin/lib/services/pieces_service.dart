import 'package:flutter/foundation.dart';

import '../models/piece_models.dart';
import 'database_service.dart';

class PiecesService {
  final DatabaseService _databaseService = DatabaseService();

  // Table names for different piece types
  static const String _pneusTable = 'pneus';
  static const String _huileMoteurTable = 'huile_moteur';
  static const String _filtresTable = 'filtres';
  static const String _eauRefroidissementTable = 'eau_refroidissement';
  static const String _amortisseursTable = 'amortisseurs';
  static const String _batterieTable = 'batterie';
  static const String _embrayageTable = 'embrayage';
  static const String _freinsTable = 'freins';
  static const String _courroieTable = 'courroies';

  // Méthodes pour récupérer les IDs et références des pièces pour le formulaire d'affectation
  Future<List<Map<String, dynamic>>> getPneusIdRef() async {
    final data = await _databaseService.getAll(
      _pneusTable,
      columns: ['id', 'reference', 'marque'],
      orderBy: 'reference',
      ascending: true,
    );
    return data;
  }

  Future<List<Map<String, dynamic>>> getHuileMoteurIdRef() async {
    final data = await _databaseService.getAll(
      _huileMoteurTable,
      columns: ['id', 'reference', 'marque', 'type'],
      orderBy: 'reference',
      ascending: true,
    );
    return data;
  }

  Future<List<Map<String, dynamic>>> getFiltresIdRef() async {
    final data = await _databaseService.getAll(
      _filtresTable,
      columns: ['id', 'reference', 'marque', 'nom'],
      orderBy: 'reference',
      ascending: true,
    );
    return data;
  }

  Future<List<Map<String, dynamic>>> getEauRefroidissementIdRef() async {
    final data = await _databaseService.getAll(
      _eauRefroidissementTable,
      columns: ['id', 'reference', 'marque', 'nom'],
      orderBy: 'reference',
      ascending: true,
    );

    // Assurer que tous les IDs sont bien des chaînes
    for (var item in data) {
      item['id'] = item['id'].toString();
    }

    return data;
  }

  Future<List<Map<String, dynamic>>> getAmortisseursIdRef() async {
    final data = await _databaseService.getAll(
      _amortisseursTable,
      columns: ['id', 'reference', 'marque','type'],
      orderBy: 'reference',
      ascending: true,
    );
    return data;
  }

  Future<List<Map<String, dynamic>>> getBatteriesIdRef() async {
    final data = await _databaseService.getAll(
      _batterieTable,
      columns: ['id', 'reference', 'marque', 'capacite'],
      orderBy: 'reference',
      ascending: true,
    );
    return data;
  }

  Future<List<Map<String, dynamic>>> getEmbrayagesIdRef() async {
    final data = await _databaseService.getAll(
      _embrayageTable,
      columns: ['id', 'reference', 'marque'],
      orderBy: 'reference',
      ascending: true,
    );
    return data;
  }

  Future<List<Map<String, dynamic>>> getFreinsIdRef() async {
    final data = await _databaseService.getAll(
      _freinsTable,
      columns: ['id', 'reference', 'marque', 'type'],
      orderBy: 'reference',
      ascending: true,
    );
    return data;
  }

  Future<List<Map<String, dynamic>>> getCourroiesIdRef() async {
    final data = await _databaseService.getAll(
      _courroieTable,
      columns: ['id', 'reference', 'marque'],
      orderBy: 'reference',
      ascending: true,
    );
    return data;
  }

  // Get methods with improved filtering and sorting
  Future<List<Pneu>> getPneus({
    String orderBy = 'reference',
    bool ascending = true,
    int? limit,
    int? offset,
    Map<String, dynamic>? filters,
  }) async {
    final data = await _databaseService.getAll(
      _pneusTable,
      orderBy: orderBy,
      ascending: ascending,
      limit: limit,
      offset: offset,
      filters: filters,
    );

    return data.map((json) => Pneu.fromJson(json)).toList();
  }

  Future<List<HuileMoteur>> getHuileMoteurs({
    String orderBy = 'reference',
    bool ascending = true,
    int? limit,
    int? offset,
    Map<String, dynamic>? filters,
  }) async {
    final data = await _databaseService.getAll(
      _huileMoteurTable,
      orderBy: orderBy,
      ascending: ascending,
      limit: limit,
      offset: offset,
      filters: filters,
    );

    return data.map((json) => HuileMoteur.fromJson(json)).toList();
  }

  Future<List<Filtre>> getFiltres({
    String orderBy = 'reference',
    bool ascending = true,
    int? limit,
    int? offset,
    Map<String, dynamic>? filters,
  }) async {
    final data = await _databaseService.getAll(
      _filtresTable,
      orderBy: orderBy,
      ascending: ascending,
      limit: limit,
      offset: offset,
      filters: filters,
    );

    return data.map((json) => Filtre.fromJson(json)).toList();
  }

  Future<List<EauRefroidissement>> getEauRefroidissements({
    String orderBy = 'nom',
    bool ascending = true,
    int? limit,
    int? offset,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final data = await _databaseService.getAll(
        _eauRefroidissementTable,
        orderBy: orderBy,
        ascending: ascending,
        limit: limit,
        offset: offset,
        filters: filters,
      );

      // Log pour diagnostic
      if (kDebugMode) {
        print('DEBUG REFROIDISSEMENT: Données brutes récupérées:');
      }
      for (var item in data) {
        if (kDebugMode) {
          print(
            '- ID: ${item['id']}, Type: ${item['id']?.runtimeType}, Reference: ${item['reference']}',
          );
        }
      }

      // Validation et conversion des données
      final List<EauRefroidissement> result = [];
      for (var json in data) {
        try {
          // Ensure all critical fields are properly formatted
          if (json.containsKey('id')) {
            json['id'] = json['id']?.toString() ?? '';
          }

          if (json.containsKey('reference')) {
            json['reference'] = json['reference']?.toString() ?? '';
          }

          // Convert numerical values
          if (json.containsKey('prix') && json['prix'] != null) {
            if (json['prix'] is! double) {
              json['prix'] =
                  (json['prix'] is num)
                      ? (json['prix'] as num).toDouble()
                      : 0.0;
            }
          }

          if (json.containsKey('poids') && json['poids'] != null) {
            if (json['poids'] is! double) {
              json['poids'] =
                  (json['poids'] is num)
                      ? (json['poids'] as num).toDouble()
                      : null;
            }
          }

          // Create the object and add it to the result list
          result.add(EauRefroidissement.fromJson(json));
        } catch (e) {
          if (kDebugMode) {
            print('Erreur conversion EauRefroidissement: $e pour le JSON: $json');
          }
          // Skip this item but continue processing others
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur générale getEauRefroidissements: $e');
      }
      return [];
    }
  }

  Future<List<Amortisseur>> getAmortisseurs({
    String orderBy = 'reference',
    bool ascending = true,
    int? limit,
    int? offset,
    Map<String, dynamic>? filters,
  }) async {
    final data = await _databaseService.getAll(
      _amortisseursTable,
      orderBy: orderBy,
      ascending: ascending,
      limit: limit,
      offset: offset,
      filters: filters,
    );

    return data.map((json) => Amortisseur.fromJson(json)).toList();
  }

  Future<List<Batterie>> getBatteries({
    String orderBy = 'reference',
    bool ascending = true,
    int? limit,
    int? offset,
    Map<String, dynamic>? filters,
  }) async {
    final data = await _databaseService.getAll(
      _batterieTable,
      orderBy: orderBy,
      ascending: ascending,
      limit: limit,
      offset: offset,
      filters: filters,
    );

    return data.map((json) => Batterie.fromJson(json)).toList();
  }

  Future<List<Embrayage>> getEmbrayages({
    String orderBy = 'reference',
    bool ascending = true,
    int? limit,
    int? offset,
    Map<String, dynamic>? filters,
  }) async {
    final data = await _databaseService.getAll(
      _embrayageTable,
      orderBy: orderBy,
      ascending: ascending,
      limit: limit,
      offset: offset,
      filters: filters,
    );

    return data.map((json) => Embrayage.fromJson(json)).toList();
  }

  Future<List<Frein>> getFreins({
    String orderBy = 'reference',
    bool ascending = true,
    int? limit,
    int? offset,
    Map<String, dynamic>? filters,
  }) async {
    final data = await _databaseService.getAll(
      _freinsTable,
      orderBy: orderBy,
      ascending: ascending,
      limit: limit,
      offset: offset,
      filters: filters,
    );

    return data.map((json) => Frein.fromJson(json)).toList();
  }

  Future<List<Courroie>> getCourroies({
    String orderBy = 'reference',
    bool ascending = true,
    int? limit,
    int? offset,
    Map<String, dynamic>? filters,
  }) async {
    final data = await _databaseService.getAll(
      _courroieTable,
      orderBy: orderBy,
      ascending: ascending,
      limit: limit,
      offset: offset,
      filters: filters,
    );

    return data.map((json) => Courroie.fromJson(json)).toList();
  }

  // CRUD operations for Pneu
  Future<Pneu?> createPneu(Pneu pneu) async {
    final data = await _databaseService.create(_pneusTable, pneu.toJson());
    if (data == null) return null;
    return Pneu.fromJson(data);
  }

  Future<Pneu?> updatePneu(Pneu pneu) async {
    final data = await _databaseService.update(
      _pneusTable,
      pneu.id,
      pneu.toJson(),
    );
    if (data == null) return null;
    return Pneu.fromJson(data);
  }

  Future<bool> deletePneu(String id) async {
    try {
      await _databaseService.delete(_pneusTable, id);
      return true;
    } catch (e) {
      return false;
    }
  }

  // CRUD operations for HuileMoteur
  Future<HuileMoteur?> createHuileMoteur(HuileMoteur huileMoteur) async {
    final data = await _databaseService.create(
      _huileMoteurTable,
      huileMoteur.toJson(),
    );
    if (data == null) return null;
    return HuileMoteur.fromJson(data);
  }

  Future<HuileMoteur?> updateHuileMoteur(HuileMoteur huileMoteur) async {
    final data = await _databaseService.update(
      _huileMoteurTable,
      huileMoteur.id,
      huileMoteur.toJson(),
    );
    if (data == null) return null;
    return HuileMoteur.fromJson(data);
  }

  Future<bool> deleteHuileMoteur(String id) async {
    try {
      await _databaseService.delete(_huileMoteurTable, id);
      return true;
    } catch (e) {
      return false;
    }
  }

  // CRUD operations for Filtre
  Future<Filtre?> createFiltre(Filtre filtre) async {
    final data = await _databaseService.create(_filtresTable, filtre.toJson());
    if (data == null) return null;
    return Filtre.fromJson(data);
  }

  Future<Filtre?> updateFiltre(Filtre filtre) async {
    final data = await _databaseService.update(
      _filtresTable,
      filtre.id,
      filtre.toJson(),
    );
    if (data == null) return null;
    return Filtre.fromJson(data);
  }

  Future<bool> deleteFiltre(String id) async {
    try {
      await _databaseService.delete(_filtresTable, id);
      return true;
    } catch (e) {
      return false;
    }
  }

  // CRUD operations for EauRefroidissement
  Future<EauRefroidissement?> createEauRefroidissement(
    EauRefroidissement eauRefroidissement,
  ) async {
    try {
      // Log for debugging
      if (kDebugMode) {
        print(
          'Creating EauRefroidissement with data: ${eauRefroidissement.toJson()}',
        );
      }

      // Use the specialized method for eau_refroidissement
      final data = await _databaseService.createEauRefroidissement(
        eauRefroidissement.toJson(),
      );

      if (data == null) return null;

      // Ensure the ID is properly converted to string
      if (data.containsKey('id')) {
        data['id'] = data['id'].toString();
      }

      return EauRefroidissement.fromJson(data);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la création de l\'eau de refroidissement: $e');
      }
      return null;
    }
  }

  Future<EauRefroidissement?> updateEauRefroidissement(
    EauRefroidissement eauRefroidissement,
  ) async {
    try {
      // Log for debugging
      if (kDebugMode) {
        print(
        'Updating EauRefroidissement with ID: ${eauRefroidissement.id}, Data: ${eauRefroidissement.toJson()}',
      );
      }

      final data = await _databaseService.update(
        _eauRefroidissementTable,
        eauRefroidissement.id,
        eauRefroidissement.toJson(),
      );

      if (data == null) return null;

      // Ensure the ID is properly converted to string
      if (data.containsKey('id')) {
        data['id'] = data['id'].toString();
      }

      return EauRefroidissement.fromJson(data);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la mise à jour de l\'eau de refroidissement: $e');
      }
      return null;
    }
  }

  Future<bool> deleteEauRefroidissement(String id) async {
    try {
      await _databaseService.delete(_eauRefroidissementTable, id);
      return true;
    } catch (e) {
      return false;
    }
  }

  // CRUD operations for Amortisseur
  Future<Amortisseur?> createAmortisseur(Amortisseur amortisseur) async {
    final data = await _databaseService.create(
      _amortisseursTable,
      amortisseur.toJson(),
    );
    if (data == null) return null;
    return Amortisseur.fromJson(data);
  }

  Future<Amortisseur?> updateAmortisseur(Amortisseur amortisseur) async {
    final data = await _databaseService.update(
      _amortisseursTable,
      amortisseur.id,
      amortisseur.toJson(),
    );
    if (data == null) return null;
    return Amortisseur.fromJson(data);
  }

  Future<bool> deleteAmortisseur(String id) async {
    try {
      await _databaseService.delete(_amortisseursTable, id);
      return true;
    } catch (e) {
      return false;
    }
  }

  // CRUD operations for Batterie
  Future<Batterie?> createBatterie(Batterie batterie) async {
    final data = await _databaseService.create(
      _batterieTable,
      batterie.toJson(),
    );
    if (data == null) return null;
    return Batterie.fromJson(data);
  }

  Future<Batterie?> updateBatterie(Batterie batterie) async {
    final data = await _databaseService.update(
      _batterieTable,
      batterie.id,
      batterie.toJson(),
    );
    if (data == null) return null;
    return Batterie.fromJson(data);
  }

  Future<bool> deleteBatterie(String id) async {
    try {
      await _databaseService.delete(_batterieTable, id);
      return true;
    } catch (e) {
      return false;
    }
  }

  // CRUD operations for Embrayage
  Future<Embrayage?> createEmbrayage(Embrayage embrayage) async {
    final data = await _databaseService.create(
      _embrayageTable,
      embrayage.toJson(),
    );
    if (data == null) return null;
    return Embrayage.fromJson(data);
  }

  Future<Embrayage?> updateEmbrayage(Embrayage embrayage) async {
    final data = await _databaseService.update(
      _embrayageTable,
      embrayage.id,
      embrayage.toJson(),
    );
    if (data == null) return null;
    return Embrayage.fromJson(data);
  }

  Future<bool> deleteEmbrayage(String id) async {
    try {
      await _databaseService.delete(_embrayageTable, id);
      return true;
    } catch (e) {
      return false;
    }
  }

  // CRUD operations for Frein
  Future<Frein?> createFrein(Frein frein) async {
    final data = await _databaseService.create(_freinsTable, frein.toJson());
    if (data == null) return null;
    return Frein.fromJson(data);
  }

  Future<Frein?> updateFrein(Frein frein) async {
    final data = await _databaseService.update(
      _freinsTable,
      frein.id,
      frein.toJson(),
    );
    if (data == null) return null;
    return Frein.fromJson(data);
  }

  Future<bool> deleteFrein(String id) async {
    try {
      await _databaseService.delete(_freinsTable, id);
      return true;
    } catch (e) {
      return false;
    }
  }

  // CRUD operations for Courroie
  Future<Courroie?> createCourroie(Courroie courroie) async {
    final data = await _databaseService.create(
      _courroieTable,
      courroie.toJson(),
    );
    if (data == null) return null;
    return Courroie.fromJson(data);
  }

  Future<Courroie?> updateCourroie(Courroie courroie) async {
    final data = await _databaseService.update(
      _courroieTable,
      courroie.id,
      courroie.toJson(),
    );
    if (data == null) return null;
    return Courroie.fromJson(data);
  }

  Future<bool> deleteCourroie(String id) async {
    try {
      await _databaseService.delete(_courroieTable, id);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Méthodes pour récupérer les informations d'une pièce par ID
  Future<Map<String, dynamic>?> getPneuById(int id) async {
    return await _databaseService.getById(_pneusTable, id.toString());
  }

  Future<Map<String, dynamic>?> getHuileMoteurById(int id) async {
    return await _databaseService.getById(_huileMoteurTable, id.toString());
  }

  Future<Map<String, dynamic>?> getFiltreById(int id) async {
    return await _databaseService.getById(_filtresTable, id.toString());
  }

  Future<Map<String, dynamic>?> getEauRefroidissementById(String id) async {
    return await _databaseService.getById(_eauRefroidissementTable, id);
  }

  Future<Map<String, dynamic>?> getAmortisseurById(int id) async {
    return await _databaseService.getById(_amortisseursTable, id.toString());
  }

  Future<Map<String, dynamic>?> getBatterieById(int id) async {
    return await _databaseService.getById(_batterieTable, id.toString());
  }

  Future<Map<String, dynamic>?> getEmbrayageById(int id) async {
    return await _databaseService.getById(_embrayageTable, id.toString());
  }

  Future<Map<String, dynamic>?> getFreinById(int id) async {
    return await _databaseService.getById(_freinsTable, id.toString());
  }

  Future<Map<String, dynamic>?> getCourroieById(int id) async {
    return await _databaseService.getById(_courroieTable, id.toString());
  }

  // Méthodes pour récupérer les détails des pièces pour plusieurs IDs
  Future<List<Map<String, dynamic>>> getPneusByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final List<Map<String, dynamic>> results = [];
    for (final id in ids) {
      final piece = await getPneuById(id);
      if (piece != null) results.add(piece);
    }
    return results;
  }

  Future<List<Map<String, dynamic>>> getHuileMoteursByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final List<Map<String, dynamic>> results = [];
    for (final id in ids) {
      final piece = await getHuileMoteurById(id);
      if (piece != null) results.add(piece);
    }
    return results;
  }

  Future<List<Map<String, dynamic>>> getFiltresByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final List<Map<String, dynamic>> results = [];
    for (final id in ids) {
      final piece = await getFiltreById(id);
      if (piece != null) results.add(piece);
    }
    return results;
  }

  Future<List<Map<String, dynamic>>> getEauRefroidissementsByIds(
    List<String> ids,
  ) async {
    if (ids.isEmpty) return [];
    final List<Map<String, dynamic>> results = [];
    for (final id in ids) {
      final piece = await getEauRefroidissementById(id);
      if (piece != null) results.add(piece);
    }
    return results;
  }

  Future<List<Map<String, dynamic>>> getAmortisseursByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final List<Map<String, dynamic>> results = [];
    for (final id in ids) {
      final piece = await getAmortisseurById(id);
      if (piece != null) results.add(piece);
    }
    return results;
  }

  Future<List<Map<String, dynamic>>> getBatteriesByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final List<Map<String, dynamic>> results = [];
    for (final id in ids) {
      final piece = await getBatterieById(id);
      if (piece != null) results.add(piece);
    }
    return results;
  }

  Future<List<Map<String, dynamic>>> getEmbrayagesByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final List<Map<String, dynamic>> results = [];
    for (final id in ids) {
      final piece = await getEmbrayageById(id);
      if (piece != null) results.add(piece);
    }
    return results;
  }

  Future<List<Map<String, dynamic>>> getFreinsByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final List<Map<String, dynamic>> results = [];
    for (final id in ids) {
      final piece = await getFreinById(id);
      if (piece != null) results.add(piece);
    }
    return results;
  }

  Future<List<Map<String, dynamic>>> getCourroiesByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final List<Map<String, dynamic>> results = [];
    for (final id in ids) {
      final piece = await getCourroieById(id);
      if (piece != null) results.add(piece);
    }
    return results;
  }
}
