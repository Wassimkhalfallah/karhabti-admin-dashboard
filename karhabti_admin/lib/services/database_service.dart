import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class DatabaseService {
  final SupabaseClient _client = SupabaseConfig.client;
  
  // Méthode générique pour obtenir des données d'une table
  Future<List<Map<String, dynamic>>> getAll(String table, {
    String? orderBy,
    bool ascending = false,
    int? limit,
    int? offset,
    List<String>? columns,
    Map<String, dynamic>? filters,
  }) async {
    try {
      // Construire la requête de base
      var query = _client.from(table).select(columns != null ? columns.join(', ') : '*');
      
      // Appliquer les filtres si disponibles
      if (filters != null && filters.isNotEmpty) {
        // Utiliser une approche différente pour appliquer les filtres
        PostgrestFilterBuilder<PostgrestList> filterQuery = query as PostgrestFilterBuilder<PostgrestList>;
        filters.forEach((key, value) {
          filterQuery = filterQuery.eq(key, value);
        });
        query = filterQuery;
      }
      
      // Appliquer le tri
      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending) as PostgrestFilterBuilder<PostgrestList>;
      }
      
      // Appliquer la pagination
      if (limit != null) {
        query = query.limit(limit) as PostgrestFilterBuilder<PostgrestList>;
      }
      
      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1) as PostgrestFilterBuilder<PostgrestList>;
      }
      
      final data = await query;
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Erreur lors de la récupération des données: $e');
      throw e;
    }
  }
  
  // Méthode pour obtenir un seul élément par ID
  Future<Map<String, dynamic>?> getById(String table, String id) async {
    try {
      final data = await _client
        .from(table)
        .select()
        .eq('id', id)
        .single();
      return data;
    } catch (e) {
      print('Erreur lors de la récupération de l\'élément: $e');
      return null;
    }
  }
  
  // Méthode pour créer un nouvel élément
  Future<Map<String, dynamic>?> create(String table, Map<String, dynamic> data) async {
    try {
      final response = await _client
        .from(table)
        .insert(data)
        .select()
        .single();
      return response;
    } catch (e) {
      print('Erreur lors de la création de l\'élément: $e');
      throw e;
    }
  }
  
  // Méthode pour mettre à jour un élément
  Future<Map<String, dynamic>?> update(String table, String id, Map<String, dynamic> data) async {
    try {
      final response = await _client
        .from(table)
        .update(data)
        .eq('id', id)
        .select()
        .single();
      return response;
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'élément: $e');
      throw e;
    }
  }
  
  // Méthode pour supprimer un élément
  Future<void> delete(String table, String id) async {
    try {
      await _client
        .from(table)
        .delete()
        .eq('id', id);
    } catch (e) {
      print('Erreur lors de la suppression de l\'élément: $e');
      throw e;
    }
  }
  
  // Méthode pour compter les éléments
  Future<int> count(String table, {Map<String, dynamic>? filters}) async {
    try {
      // Utiliser getAll() pour obtenir tous les éléments filtrés et compter leur nombre
      final data = await getAll(table, filters: filters);
      return data.length;
    } catch (e) {
      print('Erreur lors du comptage des éléments: $e');
      return 0;
    }
  }
  
  // Méthode pour exécuter une requête SQL personnalisée (à utiliser avec prudence)
  Future<List<Map<String, dynamic>>> rawQuery(String functionName, {Map<String, dynamic>? params}) async {
    try {
      final response = await _client.rpc(functionName, params: params);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erreur lors de l\'exécution de la requête: $e');
      throw e;
    }
  }
}
