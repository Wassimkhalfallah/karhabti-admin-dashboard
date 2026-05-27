import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/piece_recommendation_model.dart';
import '../models/piece_validation_model.dart';
import '../models/responsable_technicien_model.dart';

class ResponsableTechnicienService {
  final SupabaseClient _client = SupabaseConfig.client;

  Future<ResponsableTechnicien?> getMyProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return getById(user.id);
  }

  Future<ResponsableTechnicien?> getById(String id) async {
    final response = await _client
        .from('responsables_techniciens')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return ResponsableTechnicien.fromJson(response);
  }

  Future<List<ResponsableTechnicien>> getAllByAdminView() async {
    final rows = await _client
        .from('responsables_techniciens')
        .select()
        .order('created_at', ascending: false);
    return rows.map<ResponsableTechnicien>(ResponsableTechnicien.fromJson).toList();
  }

  Future<bool> hasGarage(String userId) async {
    final profile = await getById(userId);
    return profile?.garageId != null;
  }

  Future<ResponsableTechnicien> createResponsable({
    required String userId,
    required String nomComplet,
    String? telephone,
  }) async {
    final currentUserId = _client.auth.currentUser?.id;
    final created = await _client
        .from('responsables_techniciens')
        .insert({
          'id': userId,
          'nom_complet': nomComplet,
          'telephone': telephone,
          'created_by': currentUserId,
        })
        .select()
        .single();
    return ResponsableTechnicien.fromJson(created);
  }

  Future<void> toggleActif(String id, bool estActif) async {
    await _client
        .from('responsables_techniciens')
        .update({'est_actif': estActif, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }

  Future<void> assignerGarage(String responsableId, String garageId) async {
    await _client
        .from('responsables_techniciens')
        .update({'garage_id': garageId, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', responsableId);
  }

  Future<List<Map<String, dynamic>>> getVehiculesDuGarage(String garageId) async {
    final rdv = await _client
        .from('rendez_vous')
        .select('immatriculation')
        .eq('garage_id', garageId)
        .neq('statut', 'annule');

    final immats = rdv
        .map((row) => row['immatriculation'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
    if (immats.isEmpty) return [];

    final voitures = await _client
        .from('voiture')
        .select('immatriculation, marque, modele, moteur, annee, total_km')
        .inFilter('immatriculation', immats);

    final predictions = await _client
        .from('predictions')
        .select(
          'fk_immatriculation, battery_health, brake_wear, tire_wear, oil_change, belt_risk, clutch_wear, "ShockAbsorber_Wear", next_replacement_date',
        )
        .inFilter('fk_immatriculation', immats);

    final uv = await _client
        .from('user_vehicles')
        .select('immatriculation, user_id')
        .inFilter('immatriculation', immats);
    final userIds = uv.map((e) => e['user_id'] as String?).whereType<String>().toSet().toList();

    final clients = userIds.isEmpty
        ? <Map<String, dynamic>>[]
        : await _client.from('client').select('id, nom_client, telephone').inFilter('id', userIds);

    final predByImmat = {for (final p in predictions) p['fk_immatriculation']: p};
    final userByImmat = {for (final u in uv) u['immatriculation']: u['user_id']};
    final clientById = {for (final c in clients) c['id']: c};

    return voitures.map((v) {
      final userId = userByImmat[v['immatriculation']];
      return {
        ...v,
        'prediction': predByImmat[v['immatriculation']],
        'client': userId != null ? clientById[userId] : null,
      };
    }).toList();
  }

  Future<PieceRecommendation?> getRecommendation(String immatriculation, String pieceType) async {
    final me = _client.auth.currentUser?.id;
    if (me == null) return null;
    final row = await _client
        .from('piece_recommendations')
        .select()
        .eq('responsable_id', me)
        .eq('immatriculation', immatriculation)
        .eq('piece_type', pieceType)
        .maybeSingle();
    return row == null ? null : PieceRecommendation.fromJson(row);
  }

  Future<List<PieceRecommendation>> getAllRecommendations(String immatriculation) async {
    final me = _client.auth.currentUser?.id;
    if (me == null) return [];
    final rows = await _client
        .from('piece_recommendations')
        .select()
        .eq('responsable_id', me)
        .eq('immatriculation', immatriculation)
        .order('updated_at', ascending: false);
    return rows.map<PieceRecommendation>(PieceRecommendation.fromJson).toList();
  }

  Future<void> upsertRecommendation(PieceRecommendation recommendation) async {
    await _client.from('piece_recommendations').upsert({
      'responsable_id': recommendation.responsableId,
      'immatriculation': recommendation.immatriculation,
      'piece_type': recommendation.pieceType,
      'piece_id': recommendation.pieceId,
      'recommendation': recommendation.recommendation,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'responsable_id,immatriculation,piece_type');
  }

  Future<void> deleteRecommendation(String id) async {
    await _client.from('piece_recommendations').delete().eq('id', id);
  }

  Future<void> validerRemplacement(PieceValidation validation) async {
    await _client.from('piece_validations').insert({
      'responsable_id': validation.responsableId,
      'immatriculation': validation.immatriculation,
      'piece_type': validation.pieceType,
      'piece_id': validation.pieceId,
      'rendez_vous_id': validation.rendezVousId,
      'date_remplacement': validation.dateRemplacement.toIso8601String(),
      'note': validation.note,
    });

    await _client.from('maintenance_history').insert({
      'fk_immatriculation': validation.immatriculation,
      'component': validation.pieceType,
      'date': validation.dateRemplacement.toIso8601String(),
      'note': validation.note ?? 'Validation remplacement par responsable technicien',
    });
  }

  Future<List<PieceValidation>> getHistoriqueValidations(String immatriculation) async {
    final me = _client.auth.currentUser?.id;
    if (me == null) return [];
    final rows = await _client
        .from('piece_validations')
        .select()
        .eq('responsable_id', me)
        .eq('immatriculation', immatriculation)
        .order('date_remplacement', ascending: false);
    return rows.map<PieceValidation>(PieceValidation.fromJson).toList();
  }
}
