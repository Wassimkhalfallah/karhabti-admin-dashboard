import 'package:flutter/foundation.dart';
import 'package:karhabti_admin/models/dashboard_stats_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// DASHBOARD SERVICE
// Toutes les requêtes Supabase nécessaires au tableau de bord, exécutées
// en parallèle avec Future.wait pour minimiser le temps de chargement.
//
// Tables consultées :
//   voiture               → totalVehicles
//   client                → totalClients, newClientsThisMonth, professionalClients
//   user_vehicles         → clientsWithVehicles
//   pieces_vehicule       → totalPiecesVehicule, piecesEnAlerte
//   garages               → totalGarages, garagesActifs, garagesVerifies, note/avis
//   rendez_vous           → tous les compteurs RDV
//   v_garages_stats_globales → vue SQL (optionnel, fallback si indisponible)
//   v_garages_performance   → topGarages
// ═══════════════════════════════════════════════════════════════════════════════

class DashboardService {
  final SupabaseClient _db = SupabaseConfig.client;

  /// Charge toutes les statistiques en parallèle.
  /// Retourne un [DashboardStats] complet ou des valeurs par défaut en cas d'erreur.
  Future<DashboardStats> loadAllStats() async {
    final now      = DateTime.now();
    final today    = DateTime(now.year, now.month, now.day);
    final monthStart = DateTime(now.year, now.month, 1);
    final alert30d = now.add(const Duration(days: 30));

    try {
      final results = await Future.wait([
        _countVehicles(),                        // 0
        _countClients(monthStart),               // 1 → {total, new_month, professional}
        _countClientsWithVehicles(),             // 2
        _countPiecesVehicule(alert30d),          // 3 → {total, alerte}
        _fetchGaragesStats(),                    // 4 → {total, actifs, verifies, note, avis}
        _fetchRdvStats(today, monthStart),       // 5 → {total, en_attente, ...}
        _fetchRdvTrend7j(today),                 // 6 → List<RdvTrendPoint>
        _fetchTopGarages(),                      // 7 → List<TopGarageItem>
      ]);

      final vehicleCount  = results[0] as int;
      final clientStats   = results[1] as Map<String, int>;
      final withVehicles  = results[2] as int;
      final piecesStats   = results[3] as Map<String, int>;
      final garageStats   = results[4] as Map<String, dynamic>;
      final rdvStats      = results[5] as Map<String, int>;
      final trend         = results[6] as List<RdvTrendPoint>;
      final topGarages    = results[7] as List<TopGarageItem>;

      return DashboardStats(
        totalVehicles:         vehicleCount,
        totalClients:          clientStats['total']        ?? 0,
        newClientsThisMonth:   clientStats['new_month']    ?? 0,
        professionalClients:   clientStats['professional'] ?? 0,
        clientsWithVehicles:   withVehicles,
        totalPiecesVehicule:   piecesStats['total']  ?? 0,
        piecesEnAlerte:        piecesStats['alerte'] ?? 0,
        totalGarages:          garageStats['total']    as int?    ?? 0,
        garagesActifs:         garageStats['actifs']   as int?    ?? 0,
        garagesVerifies:       garageStats['verifies'] as int?    ?? 0,
        noteMoyenneGlobale:    garageStats['note']     as double? ?? 0,
        totalAvis:             garageStats['avis']     as int?    ?? 0,
        rdvTotal:              rdvStats['total']      ?? 0,
        rdvEnAttente:          rdvStats['en_attente'] ?? 0,
        rdvConfirme:           rdvStats['confirme']   ?? 0,
        rdvAnnule:             rdvStats['annule']     ?? 0,
        rdvTermine:            rdvStats['termine']    ?? 0,
        rdvNoShow:             rdvStats['no_show']    ?? 0,
        rdvAujourdhui:         rdvStats['aujourdhui'] ?? 0,
        rdvCeMois:             rdvStats['ce_mois']    ?? 0,
        rdvTrend7j:            trend,
        topGarages:            topGarages,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ DashboardService.loadAllStats: $e');
      }
      return const DashboardStats();
    }
  }

  // ─── Véhicules ────────────────────────────────────────────────────────────

  Future<int> _countVehicles() async {
    try {
      final r = await _db.from('voiture').select('immatriculation');
      return (r as List).length;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ _countVehicles: $e');
      }
      return 0;
    }
  }

  // ─── Clients ──────────────────────────────────────────────────────────────

  Future<Map<String, int>> _countClients(DateTime monthStart) async {
    try {
      final all = await _db
          .from('client')
          .select('created_at, type_client');

      final list = all as List;
      int total        = list.length;
      int newMonth     = 0;
      int professional = 0;

      for (final row in list) {
        // Comptage nouveaux clients ce mois
        final createdRaw = row['created_at'];
        if (createdRaw != null) {
          final created = DateTime.tryParse(createdRaw.toString());
          if (created != null && created.isAfter(monthStart)) newMonth++;
        }
        // Comptage clients professionnels
        final type = (row['type_client'] as String? ?? '').toLowerCase();
        if (type == 'professionnel') professional++;
      }

      return {
        'total':        total,
        'new_month':    newMonth,
        'professional': professional,
      };
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ _countClients: $e');
      }
      return {'total': 0, 'new_month': 0, 'professional': 0};
    }
  }

  // ─── Clients avec véhicule ────────────────────────────────────────────────

  Future<int> _countClientsWithVehicles() async {
    try {
      final r = await _db
          .from('user_vehicles')
          .select('user_id');
      final uniqueUsers = <String>{};
      for (final row in (r as List)) {
        final uid = row['user_id']?.toString();
        if (uid != null) uniqueUsers.add(uid);
      }
      return uniqueUsers.length;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ _countClientsWithVehicles: $e');
      }
      return 0;
    }
  }

  // ─── Pièces véhicule ──────────────────────────────────────────────────────

  Future<Map<String, int>> _countPiecesVehicule(DateTime alert30d) async {
    try {
      final all = await _db
          .from('pieces_vehicule')
          .select('id, prochaine_maintenance');

      final list = all as List;
      int alerte = 0;

      for (final row in list) {
        final raw = row['prochaine_maintenance'];
        if (raw != null) {
          final dt = DateTime.tryParse(raw.toString());
          if (dt != null && dt.isBefore(alert30d)) alerte++;
        }
      }

      return {'total': list.length, 'alerte': alerte};
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ _countPiecesVehicule: $e');
      }
      return {'total': 0, 'alerte': 0};
    }
  }

  // ─── Garages ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _fetchGaragesStats() async {
    try {
      // Essai via la vue SQL d'abord (plus rapide)
      try {
        final view = await _db
            .from('v_garages_stats_globales')
            .select()
            .maybeSingle();
        if (view != null) {
          return {
            'total':    (view['nb_garages_actifs'] ?? 0) +
                        (view['nb_garages_inactifs'] ?? 0),
            'actifs':   view['nb_garages_actifs']   ?? 0,
            'verifies': view['nb_garages_verifies'] ?? 0,
            'note':     (view['note_moyenne_globale'] ?? 0.0).toDouble(),
            'avis':     view['nb_avis_visibles']     ?? 0,
          };
        }
      } catch (_) {}

      // Fallback : requête directe
      final all = await _db
          .from('garages')
          .select('est_actif, est_verifie, note_moyenne, nombre_avis');

      int total    = 0, actifs = 0, verifies = 0, totalAvis = 0;
      double sumNote = 0;
      int withNote = 0;

      for (final g in (all as List)) {
        total++;
        if (g['est_actif'] == true)    actifs++;
        if (g['est_verifie'] == true)  verifies++;
        final avis = (g['nombre_avis'] as int?) ?? 0;
        totalAvis += avis;
        if (avis > 0) {
          sumNote += (g['note_moyenne'] as num?)?.toDouble() ?? 0;
          withNote++;
        }
      }

      return {
        'total':    total,
        'actifs':   actifs,
        'verifies': verifies,
        'note':     withNote > 0 ? sumNote / withNote : 0.0,
        'avis':     totalAvis,
      };
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ _fetchGaragesStats: $e');
      }
      return {'total': 0, 'actifs': 0, 'verifies': 0, 'note': 0.0, 'avis': 0};
    }
  }

  // ─── Rendez-vous ──────────────────────────────────────────────────────────

  Future<Map<String, int>> _fetchRdvStats(
      DateTime today, DateTime monthStart) async {
    try {
      final all = await _db
          .from('rendez_vous')
          .select('statut, date_rendez_vous');

      int total = 0, enAttente = 0, confirme = 0, annule = 0,
          termine = 0, noShow = 0, aujourdhui = 0, ceMois = 0;

      for (final row in (all as List)) {
        total++;
        final statut = row['statut'] as String? ?? '';
        switch (statut) {
          case 'en_attente': enAttente++; break;
          case 'confirme':   confirme++;  break;
          case 'annule':     annule++;    break;
          case 'termine':    termine++;   break;
          case 'no_show':    noShow++;    break;
        }
        final raw = row['date_rendez_vous'];
        if (raw != null) {
          final dt = DateTime.tryParse(raw.toString());
          if (dt != null) {
            final d = DateTime(dt.year, dt.month, dt.day);
            if (d == today) aujourdhui++;
            if (d.isAfter(monthStart) || d == monthStart) ceMois++;
          }
        }
      }

      return {
        'total':      total,
        'en_attente': enAttente,
        'confirme':   confirme,
        'annule':     annule,
        'termine':    termine,
        'no_show':    noShow,
        'aujourdhui': aujourdhui,
        'ce_mois':    ceMois,
      };
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ _fetchRdvStats: $e');
      }
      return {
        'total': 0, 'en_attente': 0, 'confirme': 0, 'annule': 0,
        'termine': 0, 'no_show': 0, 'aujourdhui': 0, 'ce_mois': 0,
      };
    }
  }

  // ─── Tendance RDV 7 jours ─────────────────────────────────────────────────

  Future<List<RdvTrendPoint>> _fetchRdvTrend7j(DateTime today) async {
    try {
      final from7 = today.subtract(const Duration(days: 6));
      final data  = await _db
          .from('rendez_vous')
          .select('date_rendez_vous')
          .gte('date_rendez_vous', from7.toIso8601String().substring(0, 10))
          .lte('date_rendez_vous', today.toIso8601String().substring(0, 10));

      // Compter par jour
      final Map<String, int> byDay = {};
      for (final row in (data as List)) {
        final raw = row['date_rendez_vous']?.toString() ?? '';
        final day = raw.length >= 10 ? raw.substring(0, 10) : '';
        if (day.isNotEmpty) byDay[day] = (byDay[day] ?? 0) + 1;
      }

      // Générer les 7 points (0 si aucun RDV ce jour-là)
      return List.generate(7, (i) {
        final d    = from7.add(Duration(days: i));
        final key  = '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
        return RdvTrendPoint(date: d, count: byDay[key] ?? 0);
      });
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ _fetchRdvTrend7j: $e');
      }
      return List.generate(7, (i) =>
          RdvTrendPoint(date: today.subtract(Duration(days: 6 - i)), count: 0));
    }
  }

  // ─── Top garages ──────────────────────────────────────────────────────────

  Future<List<TopGarageItem>> _fetchTopGarages() async {
    try {
      // Essai via la vue SQL de performance
      try {
        final rows = await _db
            .from('v_garages_performance')
            .select('garage_nom, ville, nb_total_rdv, note_moyenne, est_verifie')
            .order('nb_total_rdv', ascending: false)
            .limit(5);
        return (rows as List).map((r) => TopGarageItem(
          nom:        r['garage_nom'] ?? '',
          ville:      r['ville']      ?? '',
          nbRdv:      (r['nb_total_rdv'] as int?) ?? 0,
          note:       (r['note_moyenne'] as num?)?.toDouble() ?? 0,
          estVerifie: r['est_verifie'] == true,
        )).toList();
      } catch (_) {}

      // Fallback : garages directs sans join RDV
      final rows = await _db
          .from('garages')
          .select('nom, ville, nombre_avis, note_moyenne, est_verifie')
          .eq('est_actif', true)
          .order('note_moyenne', ascending: false)
          .limit(5);
      return (rows as List).map((r) => TopGarageItem(
        nom:        r['nom']          ?? '',
        ville:      r['ville']        ?? '',
        nbRdv:      (r['nombre_avis'] as int?) ?? 0,
        note:       (r['note_moyenne'] as num?)?.toDouble() ?? 0,
        estVerifie: r['est_verifie'] == true,
      )).toList();
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ _fetchTopGarages: $e');
      }
      return [];
    }
  }
}