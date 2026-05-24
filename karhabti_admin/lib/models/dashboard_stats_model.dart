// ═══════════════════════════════════════════════════════════════════════════════
// DASHBOARD STATS MODEL
// Agrège toutes les statistiques affichées dans le tableau de bord admin
// Sources : voiture, client, garages, rendez_vous, pieces_vehicule
// ═══════════════════════════════════════════════════════════════════════════════

class DashboardStats {
  // ── Véhicules (table: voiture) ────────────────────────────────────────────
  final int totalVehicles;

  // ── Clients (table: client) ───────────────────────────────────────────────
  final int totalClients;
  final int newClientsThisMonth;
  final int professionalClients;
  final int clientsWithVehicles;

  // ── Pièces (table: pieces_vehicule) ──────────────────────────────────────
  final int totalPiecesVehicule;
  final int piecesEnAlerte; // maintenance dans < 30 jours

  // ── Garages PRO (table: garages / vue: v_garages_stats_globales) ─────────
  final int totalGarages;
  final int garagesActifs;
  final int garagesVerifies;
  final double noteMoyenneGlobale;
  final int totalAvis;

  // ── Rendez-vous (table: rendez_vous) ──────────────────────────────────────
  final int rdvTotal;
  final int rdvEnAttente;
  final int rdvConfirme;
  final int rdvAnnule;
  final int rdvTermine;
  final int rdvNoShow;
  final int rdvAujourdhui;
  final int rdvCeMois;

  // ── Données graphiques ────────────────────────────────────────────────────
  /// Évolution des RDV sur les 7 derniers jours : [{date, count}]
  final List<RdvTrendPoint> rdvTrend7j;

  /// Top 5 garages par nombre de RDV : [{nom, nb_rdv, note}]
  final List<TopGarageItem> topGarages;

  const DashboardStats({
    this.totalVehicles      = 0,
    this.totalClients       = 0,
    this.newClientsThisMonth = 0,
    this.professionalClients = 0,
    this.clientsWithVehicles = 0,
    this.totalPiecesVehicule = 0,
    this.piecesEnAlerte     = 0,
    this.totalGarages       = 0,
    this.garagesActifs      = 0,
    this.garagesVerifies    = 0,
    this.noteMoyenneGlobale = 0,
    this.totalAvis          = 0,
    this.rdvTotal           = 0,
    this.rdvEnAttente       = 0,
    this.rdvConfirme        = 0,
    this.rdvAnnule          = 0,
    this.rdvTermine         = 0,
    this.rdvNoShow          = 0,
    this.rdvAujourdhui      = 0,
    this.rdvCeMois          = 0,
    this.rdvTrend7j         = const [],
    this.topGarages         = const [],
  });

  /// Retourne les KPI principaux sous forme de liste pour le grid
  List<KpiItem> get kpiItems => [
    KpiItem(
      label:         'Véhicules',
      value:         '$totalVehicles',
      delta:         'Total enregistrés',
      positive:      true,
      icon:          0xe1b7, // directions_car_rounded
      colorHex:      0xFF6366F1, // indigo
      bgColorHex:    0xFFEEF2FF,
    ),
    KpiItem(
      label:         'Clients actifs',
      value:         '$totalClients',
      delta:         '+$newClientsThisMonth ce mois',
      positive:      newClientsThisMonth >= 0,
      icon:          0xe7fb, // people_rounded
      colorHex:      0xFF10B981, // emerald
      bgColorHex:    0xFFECFDF5,
    ),
    KpiItem(
      label:         'Pièces suivies',
      value:         '$totalPiecesVehicule',
      delta:         piecesEnAlerte > 0
                       ? '$piecesEnAlerte en alerte maintenance'
                       : 'Tout est à jour',
      positive:      piecesEnAlerte == 0,
      icon:          0xe8b8, // settings_rounded
      colorHex:      0xFFF59E0B, // amber
      bgColorHex:    0xFFFFFBEB,
    ),
    KpiItem(
      label:         'RDV en attente',
      value:         '$rdvEnAttente',
      delta:         '$rdvAujourdhui aujourd\'hui',
      positive:      rdvEnAttente == 0,
      icon:          0xe916, // calendar_month_rounded
      colorHex:      0xFF0EA5E9, // sky
      bgColorHex:    0xFFE0F2FE,
    ),
    KpiItem(
      label:         'Garages actifs',
      value:         '$garagesActifs',
      delta:         '$garagesVerifies vérifiés',
      positive:      true,
      icon:          0xe539, // store_rounded
      colorHex:      0xFF8B5CF6, // violet
      bgColorHex:    0xFFF5F3FF,
    ),
    KpiItem(
      label:         'Note moyenne',
      value:         noteMoyenneGlobale.toStringAsFixed(1),
      delta:         '$totalAvis avis clients',
      positive:      noteMoyenneGlobale >= 3.5,
      icon:          0xe838, // star_rounded
      colorHex:      0xFFF97316, // orange
      bgColorHex:    0xFFFFF7ED,
    ),
  ];
}

// ─── Sous-modèles ─────────────────────────────────────────────────────────────

class KpiItem {
  final String label;
  final String value;
  final String delta;
  final bool   positive;
  final int    icon;      // codepoint
  final int    colorHex;
  final int    bgColorHex;

  const KpiItem({
    required this.label,
    required this.value,
    required this.delta,
    required this.positive,
    required this.icon,
    required this.colorHex,
    required this.bgColorHex,
  });
}

class RdvTrendPoint {
  final DateTime date;
  final int count;
  const RdvTrendPoint({required this.date, required this.count});
}

class TopGarageItem {
  final String  nom;
  final String  ville;
  final int     nbRdv;
  final double  note;
  final bool    estVerifie;
  const TopGarageItem({
    required this.nom,
    required this.ville,
    required this.nbRdv,
    required this.note,
    required this.estVerifie,
  });
}