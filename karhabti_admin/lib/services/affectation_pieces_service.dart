import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/affectation_piece_model.dart';
import './affectation_jointure_service.dart';

class AffectationPiecesService {
  static const String tableName = 'affectation_pieces';

  // Tables de jointure
  static const Map<String, Map<String, String>> joinTables = {
    'pneus': {'table': 'affectation_pneus', 'field': 'fk_pneu_id'},
    'huileMoteur': {
      'table': 'affectation_huile_moteur',
      'field': 'fk_huile_moteur_id',
    },
    'filtres': {'table': 'affectation_filtres', 'field': 'fk_filtre_id'},
    'embrayage': {'table': 'affectation_embrayage', 'field': 'fk_embrayage_id'},
    'batterie': {'table': 'affectation_batterie', 'field': 'fk_batterie_id'},
    'amortisseurs': {
      'table': 'affectation_amortisseurs',
      'field': 'fk_amortisseur_id',
    },
    'freins': {'table': 'affectation_freins', 'field': 'fk_frein_id'},
    'courroie': {'table': 'affectation_courroie', 'field': 'fk_courroie_id'},
    'refroidissement': {
      'table': 'affectation_refroidissement',
      'field': 'fk_refroidissement_id',
    },
  };

  final SupabaseClient client;
  late final AffectationJointureService _jointureService;

  AffectationPiecesService(this.client) {
    _jointureService = AffectationJointureService(client);
  }

  Future<List<AffectationPiece>> getAllAffectations() async {
    try {
      final List data = await client
          .from(tableName)
          .select()
          .order('id')
          .limit(1000);

      final affectations = <AffectationPiece>[];

      // Convertir chaque élément manuellement pour gérer les erreurs
      for (var json in data) {
        try {
          final affectation = AffectationPiece.fromJson(json);
          await _loadAllRelations(affectation);
          affectations.add(affectation);
        } catch (e) {
          if (kDebugMode) {
            print(
            'Erreur lors de la conversion de l\'affectation ID=${json['id']}: $e',
          );
          }
          // Continuer avec les autres éléments
        }
      }

      return affectations;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur générale dans getAllAffectations: $e');
      }
      return [];
    }
  }

  Future<void> _loadAllRelations(AffectationPiece affectation) async {
    // Charger toutes les relations d'un coup en parallèle
    await Future.wait([
      _loadPiecesRelation(
        affectation,
        'pneus',
        (ids) => affectation.fkPneus = ids.cast<int>(),
      ),
      _loadPiecesRelation(
        affectation,
        'huileMoteur',
        (ids) => affectation.fkHuileMoteur = ids.cast<int>(),
      ),
      _loadPiecesRelation(
        affectation,
        'filtres',
        (ids) => affectation.fkFiltres = ids.cast<int>(),
      ),
      _loadPiecesRelation(
        affectation,
        'embrayage',
        (ids) => affectation.fkEmbrayage = ids.cast<int>(),
      ),
      _loadPiecesRelation(
        affectation,
        'batterie',
        (ids) => affectation.fkBatterie = ids.cast<int>(),
      ),
      _loadPiecesRelation(
        affectation,
        'amortisseurs',
        (ids) => affectation.fkAmortisseurs = ids.cast<int>(),
      ),
      _loadPiecesRelation(
        affectation,
        'freins',
        (ids) => affectation.fkFreins = ids.cast<int>(),
      ),
      _loadPiecesRelation(
        affectation,
        'courroie',
        (ids) => affectation.fkCourroie = ids.cast<int>(),
      ),
      _loadPiecesRelation(
        affectation,
        'refroidissement',
        (ids) => affectation.fkRefroidissement = ids.cast<String>(),
      ),
    ]);
  }

  Future<void> _loadPiecesRelation(
    AffectationPiece affectation,
    String pieceType,
    Function(List<dynamic>) setter,
  ) async {
    final tableInfo = joinTables[pieceType];
    if (tableInfo == null) {
      throw Exception('Unknown piece type: $pieceType');
    }

    try {
      final relations = await _jointureService.getRelations(
        affectation.id,
        tableInfo['table']!,
        tableInfo['field']!,
      );

      // Convertir IDs en String pour eau_refroidissement, ou laisser comme int pour autres types
      List<dynamic> ids;
      if (pieceType == 'refroidissement') {
        if (kDebugMode) {
          print(
            'DEBUG REF: Type de données brut: ${relations.map((r) => '${r.fkPieceId.runtimeType}:${r.fkPieceId}').join(', ')}',
          );
        }
        ids = relations.map((r) => r.fkPieceId.toString()).toList();
        if (kDebugMode) {
          print(
            'DEBUG REF: Types après conversion: ${ids.map((id) => '${id.runtimeType}:$id').join(', ')}',
          );
        }
      } else {
        ids = relations.map((r) => r.fkPieceId).toList();
      }

      setter(ids);
    } catch (e) {
      if (kDebugMode) {
        print('ERREUR dans _loadPiecesRelation pour $pieceType: $e');
      }
      // En cas d'erreur, on retourne une liste vide pour éviter de bloquer l'application
      setter([]);
    }
  }

  Future<void> addAffectation(AffectationPiece affectation) async {
    final data = affectation.toJson();
    // Supprimer l'ID pour laisser la base de données générer un nouvel ID
    data.remove('id');

    // Supprimer tous les champs de pièces car ils seront gérés par les tables de jointure
    joinTables.forEach((pieceType, _) {
      data.remove(
        'fk_${pieceType.toLowerCase().replaceAll('moteur', '_moteur')}',
      );
    });

    // Insérer l'affectation principale
    final response =
        await client.from(tableName).insert(data).select('id').single();
    final int newAffectationId = response['id'];

    // Ajouter toutes les relations dans les tables de jointure
    await _saveAllRelations(newAffectationId, affectation);
  }

  Future<void> _saveAllRelations(
    int affectationId,
    AffectationPiece affectation,
  ) async {
    final Map<String, List<dynamic>> pieceData = {
      'pneus': affectation.fkPneus,
      'huileMoteur': affectation.fkHuileMoteur,
      'filtres': affectation.fkFiltres,
      'embrayage': affectation.fkEmbrayage,
      'batterie': affectation.fkBatterie,
      'amortisseurs': affectation.fkAmortisseurs,
      'freins': affectation.fkFreins,
      'courroie': affectation.fkCourroie,
      'refroidissement': affectation.fkRefroidissement,
    };

    for (final entry in pieceData.entries) {
      await _savePiecesRelations(affectationId, entry.key, entry.value);
    }
  }

  Future<void> _savePiecesRelations(
    int affectationId,
    String pieceType,
    List<dynamic> pieceIds,
  ) async {
    final tableInfo = joinTables[pieceType];
    if (tableInfo == null) {
      throw Exception('Unknown piece type: $pieceType');
    }

    for (final pieceId in pieceIds) {
      // S'assurer que le pieceId est du bon type selon la catégorie
      final formattedId =
          pieceType == 'refroidissement' ? pieceId.toString() : pieceId;

      await _jointureService.addRelation(
        affectationId,
        formattedId,
        tableInfo['table']!,
        tableInfo['field']!,
      );
    }
  }

  Future<void> updateAffectation(AffectationPiece affectation) async {
    final data = affectation.toJson();

    // Supprimer tous les champs de pièces car ils seront gérés par les tables de jointure
    joinTables.forEach((pieceType, _) {
      data.remove(
        'fk_${pieceType.toLowerCase().replaceAll('moteur', '_moteur')}',
      );
    });

    // Mettre à jour l'affectation principale
    await client.from(tableName).update(data).eq('id', affectation.id);

    // Supprimer puis recréer toutes les relations
    await _deleteAllRelations(affectation.id);
    await _saveAllRelations(affectation.id, affectation);
  }

  Future<void> _deleteAllRelations(int affectationId) async {
    // Supprimer toutes les relations en parallèle
    await Future.wait(
      joinTables.values.map(
        (tableInfo) => _jointureService.deleteRelations(
          affectationId,
          tableInfo['table']!,
        ),
      ),
    );
  }

  Future<void> deleteAffectation(int id) async {
    // Supprimer d'abord les relations dans toutes les tables de jointure
    await _deleteAllRelations(id);

    // Puis supprimer l'affectation principale
    await client.from(tableName).delete().eq('id', id);
  }

  Future<AffectationPiece?> getAffectationById(int id) async {
    final data =
        await client
            .from(tableName)
            .select()
            .eq('id', id)
            .limit(1)
            .maybeSingle();

    if (data == null) return null;

    final affectation = AffectationPiece.fromJson(data);

    // Charger toutes les relations
    await _loadAllRelations(affectation);

    return affectation;
  }
}
