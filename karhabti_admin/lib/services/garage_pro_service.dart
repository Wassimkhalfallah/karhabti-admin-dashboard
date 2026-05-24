import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/garage_pro_model.dart';
import '../models/appointment_pro_model.dart';
import '../models/review_pro_model.dart';
import '../models/prestation_pro_model.dart';

class GarageProService {
  final SupabaseClient _client = SupabaseConfig.client;

  // ─── DASHBOARD STATS ──────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final result = await _client.rpc('stats_mensuelles_rdv');
      final List<Map<String, dynamic>> monthlyStats =
          List<Map<String, dynamic>>.from(result);

      // Get global stats from view
      final globalStats = await _client
          .from('v_garages_stats_globales')
          .select()
          .maybeSingle();

      // Get status distribution
      final statusData = await _client
          .from('rendez_vous')
          .select('statut');
      final Map<String, int> statusDist = {};
      for (final row in statusData) {
        final s = row['statut'] as String? ?? 'en_attente';
        statusDist[s] = (statusDist[s] ?? 0) + 1;
      }

      // Get top garages
      final topGarages = await _client
          .from('v_garages_performance')
          .select()
          .order('nb_total_rdv', ascending: false)
          .limit(10);

      return {
        'global': globalStats ?? {},
        'monthly': monthlyStats,
        'status_distribution': statusDist,
        'top_garages': List<Map<String, dynamic>>.from(topGarages),
      };
    } catch (e) {
      if (kDebugMode) {
        print('Erreur getDashboardStats: $e');
      }
      return {};
    }
  }

  // ─── ALERTS ───────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getUnconfirmedAlerts() async {
    try {
      final now = DateTime.now();
      final threshold = now.subtract(const Duration(hours: 24)).toIso8601String();
      final data = await _client
          .from('rendez_vous')
          .select('*, garages(nom)')
          .eq('statut', 'en_attente')
          .lt('created_at', threshold);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur getUnconfirmedAlerts: $e');
      }
      return [];
    }
  }

  Future<List<ReviewPro>> getFlaggedReviews() async {
    try {
      final data = await _client
          .from('avis_garages')
          .select('*, garages(nom)')
          .eq('est_visible', false)
          .order('created_at', ascending: false)
          .limit(20);
      return data.map<ReviewPro>((m) {
        m['garage_nom'] = (m['garages'] ?? {})['nom'];
        return ReviewPro.fromMap(m);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur getFlaggedReviews: $e');
      }
      return [];
    }
  }

  Future<List<GaragePro>> getNewUnverifiedGarages() async {
    try {
      final threshold = DateTime.now()
          .subtract(const Duration(hours: 48))
          .toIso8601String();
      final data = await _client
          .from('garages')
          .select()
          .eq('est_verifie', false)
          .gt('created_at', threshold);
      return data.map<GaragePro>((m) => GaragePro.fromMap(m)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur getNewUnverifiedGarages: $e');
      }
      return [];
    }
  }

  // ─── GARAGES CRUD ─────────────────────────────────────────────────────────

  Future<List<GaragePro>> getGarages({
    String? search,
    String? ville,
    bool? estVerifie,
    bool? estActif,
    double? noteMin,
    double? noteMax,
    List<String>? specialites,
    String? orderBy,
    bool ascending = false,
  }) async {
    try {
      dynamic query = _client.from('garages').select();

      if (search != null && search.isNotEmpty) {
        query = query.or(
            'nom.ilike.%$search%,ville.ilike.%$search%,adresse.ilike.%$search%');
      }
      if (ville != null) query = query.eq('ville', ville);
      if (estVerifie != null) query = query.eq('est_verifie', estVerifie);
      if (estActif != null) query = query.eq('est_actif', estActif);
      if (noteMin != null) query = query.gte('note_moyenne', noteMin);
      if (noteMax != null) query = query.lte('note_moyenne', noteMax);

      query = query.order(orderBy ?? 'created_at', ascending: ascending);

      final data = await query;
      var garages = data.map<GaragePro>((m) => GaragePro.fromMap(m)).toList();

      // Client-side filter for specialites (array overlap)
      if (specialites != null && specialites.isNotEmpty) {
        garages = garages
            .where((g) =>
                g.specialites.any((s) => specialites.contains(s)))
            .toList();
      }

      return garages;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur getGarages: $e');
      }
      return [];
    }
  }

  Future<GaragePro?> getGarageById(String id) async {
    try {
      final data = await _client
          .from('garages')
          .select()
          .eq('id', id)
          .single();
      return GaragePro.fromMap(data);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur getGarageById: $e');
      }
      return null;
    }
  }

  Future<GaragePro?> createGarage(Map<String, dynamic> data) async {
    try {
      final result = await _client
          .from('garages')
          .insert(data)
          .select()
          .single();
      return GaragePro.fromMap(result);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur createGarage: $e');
      }
      rethrow;
    }
  }

  Future<GaragePro?> updateGarage(String id, Map<String, dynamic> data) async {
    try {
      final result = await _client
          .from('garages')
          .update(data)
          .eq('id', id)
          .select()
          .single();
      return GaragePro.fromMap(result);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur updateGarage: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteGarage(String id) async {
    // Soft-delete
    await updateGarage(id, {'est_actif': false});
  }

  Future<void> verifyGarage(String id, bool verified) async {
    await updateGarage(id, {'est_verifie': verified});
  }

  Future<List<String>> getDistinctVilles() async {
    try {
      final data = await _client
          .from('garages')
          .select('ville')
          .order('ville');
      final villes = data
          .map<String>((m) => m['ville'] as String)
          .toSet()
          .toList();
      return villes..sort();
    } catch (e) {
      return [];
    }
  }

  // ─── APPOINTMENTS ──────────────────────────────────────────────────────────

  Future<List<AppointmentPro>> getAppointments({
    AppointmentStatus? statut,
    String? garageId,
    DateTime? dateDebut,
    DateTime? dateFin,
    String? search,
  }) async {
    try {
      dynamic query = _client
          .from('rendez_vous')
          .select('*, garages(nom)');

      if (statut != null) query = query.eq('statut', statut.value);
      if (garageId != null) query = query.eq('garage_id', garageId);
      if (dateDebut != null) {
        query = query.gte('date_rendez_vous', dateDebut.toIso8601String());
      }
      if (dateFin != null) {
        query = query.lte('date_rendez_vous', dateFin.toIso8601String());
      }

      query = query.order('date_rendez_vous', ascending: false);

      final data = await query;
      return data.map<AppointmentPro>((m) {
        m['garage_nom'] = (m['garages'] ?? {})['nom'];
        return AppointmentPro.fromMap(m);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur getAppointments: $e');
      }
      return [];
    }
  }

  Future<List<AppointmentPro>> getTodayAppointments() async {
    try {
      final data = await _client
          .from('v_rdv_aujourdhui')
          .select()
          .order('heure_rendez_vous', ascending: true);
      return data.map<AppointmentPro>((m) => AppointmentPro.fromMap(m)).toList();
    } catch (e) {
      // Fallback if view doesn't exist
      final today = DateTime.now();
      final start = DateTime(today.year, today.month, today.day)
          .toIso8601String();
      final end = DateTime(today.year, today.month, today.day, 23, 59, 59)
          .toIso8601String();
      return getAppointments(dateDebut: DateTime.parse(start), dateFin: DateTime.parse(end));
    }
  }

  Future<bool> confirmAppointment(String id) async {
    try {
      await _client
          .from('rendez_vous')
          .update({'statut': 'confirme'})
          .eq('id', id);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur confirmAppointment: $e');
      }
      return false;
    }
  }

  Future<bool> cancelAppointment(String id, String motif, String annulePar) async {
    try {
      await _client.from('rendez_vous').update({
        'statut': 'annule',
        'motif_annulation': motif,
        'annule_par': annulePar,
      }).eq('id', id);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur cancelAppointment: $e');
      }
      return false;
    }
  }

  Future<bool> completeAppointment(String id) async {
    try {
      await _client
          .from('rendez_vous')
          .update({'statut': 'termine'})
          .eq('id', id);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur completeAppointment: $e');
      }
      return false;
    }
  }

  Future<bool> markNoShow(String id) async {
    try {
      await _client
          .from('rendez_vous')
          .update({'statut': 'no_show'})
          .eq('id', id);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur markNoShow: $e');
      }
      return false;
    }
  }

  Future<bool> confirmAllPending(DateTime date) async {
    try {
      await _client
          .from('rendez_vous')
          .update({'statut': 'confirme'})
          .eq('statut', 'en_attente')
          .gte('date_rendez_vous', date.toIso8601String())
          .lt('date_rendez_vous',
              date.add(const Duration(days: 1)).toIso8601String());
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur confirmAllPending: $e');
      }
      return false;
    }
  }

  // ─── REVIEWS ──────────────────────────────────────────────────────────────

  Future<List<ReviewPro>> getReviews({
    String? garageId,
    bool? estVisible,
    int? noteMin,
    String? search,
  }) async {
    try {
      dynamic query = _client
          .from('avis_garages')
          .select('*, garages(nom)');

      if (garageId != null) query = query.eq('garage_id', garageId);
      if (estVisible != null) query = query.eq('est_visible', estVisible);
      if (noteMin != null) query = query.gte('note', noteMin);

      query = query.order('created_at', ascending: false);

      final data = await query;
      return data.map<ReviewPro>((m) {
        m['garage_nom'] = (m['garages'] ?? {})['nom'];
        return ReviewPro.fromMap(m);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur getReviews: $e');
      }
      return [];
    }
  }

  Future<bool> toggleReviewVisibility(String id, bool visible) async {
    try {
      await _client
          .from('avis_garages')
          .update({'est_visible': visible})
          .eq('id', id);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur toggleReviewVisibility: $e');
      }
      return false;
    }
  }

  Future<bool> replyToReview(String id, String reponse) async {
    try {
      await _client
          .from('avis_garages')
          .update({'reponse_garage': reponse})
          .eq('id', id);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur replyToReview: $e');
      }
      return false;
    }
  }

  Future<bool> deleteReview(String id) async {
    try {
      await _client
          .from('avis_garages')
          .update({'est_visible': false})
          .eq('id', id);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur deleteReview: $e');
      }
      return false;
    }
  }

  // ─── PRESTATIONS ───────────────────────────────────────────────────────────

  Future<List<PrestationPro>> getPrestations({
    String? categorie,
    bool? actif,
  }) async {
    try {
      dynamic query = _client.from('garages_prestations').select();

      if (categorie != null) query = query.eq('categorie', categorie);
      if (actif != null) query = query.eq('actif', actif);

      query = query.order('tri', ascending: true);

      final data = await query;
      return data.map<PrestationPro>((m) => PrestationPro.fromMap(m)).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Erreur getPrestations: $e');
      }
      return [];
    }
  }

  Future<PrestationPro?> createPrestation(Map<String, dynamic> data) async {
    try {
      final result = await _client
          .from('garages_prestations')
          .insert(data)
          .select()
          .single();
      return PrestationPro.fromMap(result);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur createPrestation: $e');
      }
      rethrow;
    }
  }

  Future<PrestationPro?> updatePrestation(
      String id, Map<String, dynamic> data) async {
    try {
      final result = await _client
          .from('garages_prestations')
          .update(data)
          .eq('id', id)
          .select()
          .single();
      return PrestationPro.fromMap(result);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur updatePrestation: $e');
      }
      rethrow;
    }
  }

  Future<void> disablePrestation(String id) async {
    await updatePrestation(id, {'actif': false});
  }

  // ─── NOTIFICATIONS ────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getNotifications({
    String? type,
    String? canal,
    String? statut,
    int limit = 50,
  }) async {
    try {
      dynamic query = _client
          .from('notifications_rdv')
          .select()
          .order('envoye_le', ascending: false)
          .limit(limit);

      if (type != null) query = query.eq('type', type);
      if (canal != null) query = query.eq('canal', canal);
      if (statut != null) query = query.eq('statut', statut);

      final data = await query;
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      if (kDebugMode) {
        print('Erreur getNotifications: $e');
      }
      return [];
    }
  }

  // ─── SETTINGS ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getSettings() async {
    try {
      final data = await _client
          .from('garages_pro_settings')
          .select()
          .maybeSingle();
      return data;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur getSettings: $e');
      }
      return null;
    }
  }

  Future<bool> updateSettings(Map<String, dynamic> data) async {
    try {
      await _client.from('garages_pro_settings').upsert(data);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Erreur updateSettings: $e');
      }
      return false;
    }
  }

  // ─── GARAGE DETAIL TABS ───────────────────────────────────────────────────

  Future<List<AppointmentPro>> getGarageAppointments(String garageId, {
    AppointmentStatus? statut,
  }) async {
    return getAppointments(garageId: garageId, statut: statut);
  }

  Future<List<ReviewPro>> getGarageReviews(String garageId) async {
    return getReviews(garageId: garageId);
  }
}
