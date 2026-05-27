import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/affectation_refroidissement_model.dart';

class AffectationRefroidissementService {
  static const String tableName = 'affectation_refroidissement';
  final SupabaseClient client;

  AffectationRefroidissementService(this.client);

  Future<List<AffectationRefroidissement>> getByAffectationId(int affectationId) async {
    final List data = await client
        .from(tableName)
        .select()
        .eq('fk_affectation_id', affectationId)
        .order('id');
    return data.map((json) => AffectationRefroidissement.fromJson(json)).toList();
  }

  Future<void> addRelation(int affectationId, String refroidissementId) async {
    await client.from(tableName).insert({
      'fk_affectation_id': affectationId,
      'fk_refroidissement_id': refroidissementId,
    });
  }

  Future<void> deleteRelationsByAffectationId(int affectationId) async {
    await client
        .from(tableName)
        .delete()
        .eq('fk_affectation_id', affectationId);
  }
} 