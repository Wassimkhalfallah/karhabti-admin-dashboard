import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class DatabaseService {
  final SupabaseClient _client = SupabaseConfig.client;

  // Méthode pour tester la connectivité à la base de données
  Future<bool> testConnection() async {
    try {
      if (kDebugMode) {
        print('🔍 Test de connexion à la base de données...');
      }
      final response = await _client.from('client').select('count').limit(1);
      if (kDebugMode) {
        print('✅ Connexion à la base de données réussie: $response');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur de connexion à la base de données: $e');
        print(StackTrace.current);
      }
      return false;
    }
  }

  // Méthode générique pour obtenir des données d'une table
  Future<List<Map<String, dynamic>>> getAll(
    String table, {
    String? orderBy,
    bool ascending = false,
    int? limit,
    int? offset,
    List<String>? columns,
    Map<String, dynamic>? filters,
  }) async {
    try {
      if (kDebugMode) {
        print('🔍 Récupération des données de la table: $table');
      }
      // Utiliser dynamic pour éviter les problèmes de typage avec l'API Supabase
      dynamic query = _client
          .from(table)
          .select(columns != null ? columns.join(', ') : '*');

      // Appliquer les filtres à la requête
      if (filters != null && filters.isNotEmpty) {
        if (kDebugMode) {
          print('🔍 Application des filtres: $filters');
        }
        for (var entry in filters.entries) {
          query = query.eq(entry.key, entry.value);
        }
      }

      // Appliquer le tri si spécifié
      if (orderBy != null) {
        if (kDebugMode) {
          print('🔍 Application du tri: $orderBy, ascendant: $ascending');
        }
        query = query.order(orderBy, ascending: ascending);
      }

      // Appliquer la pagination
      if (limit != null) {
        if (kDebugMode) {
          print('🔍 Application de la limite: $limit');
        }
        query = query.limit(limit);
      }

      if (offset != null) {
        if (kDebugMode) {
          print('🔍 Application de l\'offset: $offset');
        }
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      // Exécuter la requête
      if (kDebugMode) {
        print('🔍 Exécution de la requête...');
      }
      final data = await query;
      if (kDebugMode) {
        print('✅ Requête exécutée avec succès, résultats: ${data.length}');
      }

      // Convertir les données en liste de maps
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Erreur lors de la récupération des données: $e');
        print('Table: $table, Ordre: $orderBy, Filtres: $filters');
        print(StackTrace.current);
      }
      rethrow;
    }
  }

  // Méthode pour obtenir un seul élément par ID
  Future<Map<String, dynamic>?> getById(String table, String id) async {
    try {
      dynamic query = _client.from(table).select().eq('id', id);
      final data = await query.single();
      return data;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la récupération de l\'élément: $e');
      }
      return null;
    }
  }

  // Méthode pour créer un nouvel élément
  Future<Map<String, dynamic>?> create(
    String table,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.from(table).insert(data).select().single();
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la création de l\'élément: $e');
      }
      rethrow;
    }
  }

  // Méthode pour mettre à jour un élément
  Future<Map<String, dynamic>?> update(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response =
          await _client.from(table).update(data).eq('id', id).select().single();
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la mise à jour de l\'élément: $e');
      }
      rethrow;
    }
  }

  // Méthode pour supprimer un élément
  Future<void> delete(String table, String id) async {
    try {
      await _client.from(table).delete().eq('id', id);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la suppression de l\'élément: $e');
      }
      rethrow;
    }
  }

  // Méthode pour compter les éléments
  Future<int> count(String table, {Map<String, dynamic>? filters}) async {
    try {
      // Utiliser getAll avec une limite élevée mais raisonnable pour le comptage
      // Dans un environnement de production réel, il serait préférable d'utiliser une requête COUNT nativee
      final data = await getAll(
        table,
        filters: filters,
        limit:
            10000, // Limite suffisamment grande pour la plupart des cas d'usage
      );
      return data.length;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du comptage des éléments: $e');
      }
      return 0;
    }
  }

  // Méthode pour exécuter une requête SQL personnalisée (à utiliser avec prudence)
  Future<List<Map<String, dynamic>>> rawQuery(
    String functionName, {
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await _client.rpc(functionName, params: params);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de l\'exécution de la requête: $e');
      }
      rethrow;
    }
  }

  // Méthode spécifique pour créer un eau de refroidissement
  // Cette méthode ajoute des paramètres spécifiques pour assurer que l'ID est géré correctement
  Future<Map<String, dynamic>?> createEauRefroidissement(
    Map<String, dynamic> data,
  ) async {
    try {
      // Always generate a new ID for eau_refroidissement records
      final Map<String, dynamic> cleanData = {...data};

      // Generate a unique ID if one isn't provided
      // We'll use the current timestamp plus a random suffix
      final String generatedId =
          DateTime.now().millisecondsSinceEpoch.toString() +
          (10000 + DateTime.now().microsecond % 90000).toString();

      // Always set the ID field explicitly
      cleanData['id'] = generatedId;

      if (kDebugMode) {
        print('Creating eau_refroidissement with generated ID: $generatedId');
        print('Creating eau_refroidissement with cleaned data: $cleanData');
      }

      // Insert the record with the explicit ID
      final response =
          await _client
              .from('eau_refroidissement')
              .insert(cleanData)
              .select()
              .single();

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors de la création de l\'eau de refroidissement: $e');
      }
      rethrow;
    }
  }
}
