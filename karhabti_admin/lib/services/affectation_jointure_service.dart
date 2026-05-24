import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/affectation_jointure_model.dart';

class AffectationJointureService {
  final SupabaseClient client;

  AffectationJointureService(this.client);

  Future<List<AffectationJointure>> getRelations(
    int affectationId, 
    String tableName, 
    String pieceIdField
  ) async {
    final List data = await client
        .from(tableName)
        .select()
        .eq('fk_affectation_id', affectationId)
        .order('id');
    return data.map((json) => AffectationJointure.fromJson(json, pieceIdField)).toList();
  }

  Future<void> addRelation(
    int affectationId, 
    dynamic pieceId, 
    String tableName, 
    String pieceIdField
  ) async {
    await client.from(tableName).insert({
      'fk_affectation_id': affectationId,
      pieceIdField: pieceId,
    });
  }

  Future<void> deleteRelations(
    int affectationId, 
    String tableName
  ) async {
    await client
        .from(tableName)
        .delete()
        .eq('fk_affectation_id', affectationId);
  }
} 