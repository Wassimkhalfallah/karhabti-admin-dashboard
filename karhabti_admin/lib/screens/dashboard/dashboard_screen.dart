// ignore_for_file: deprecated_member_use, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:karhabti_admin/models/dashboard_stats_model.dart';
import '../../services/dashboard_service.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// DESIGN TOKENS — Light Pro (cohérent avec le reste de l'admin)
// ═══════════════════════════════════════════════════════════════════════════════

class _D {
  static const bg       = Color(0xFFF8FAFC);
  static const surface  = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFF1F5F9);
  static const border   = Color(0xFFE2E8F0);
  static const indigo   = Color(0xFF6366F1);
  static const indigoL  = Color(0xFFEEF2FF);
  static const emerald  = Color(0xFF10B981);
  static const emeraldL = Color(0xFFECFDF5);
  static const amber    = Color(0xFFF59E0B);
  static const amberL   = Color(0xFFFFFBEB);
  static const sky      = Color(0xFF0EA5E9);
  static const skyL     = Color(0xFFE0F2FE);
  static const violet   = Color(0xFF8B5CF6);
  static const violetL  = Color(0xFFF5F3FF);
  static const orange   = Color(0xFFF97316);
  static const orangeL  = Color(0xFFFFF7ED);
  static const rose     = Color(0xFFEF4444);
  static const roseL    = Color(0xFFFEF2F2);
  static const textPri  = Color(0xFF1E293B);
  static const textSec  = Color(0xFF64748B);
  static const textHint = Color(0xFF94A3B8);
}

// ─── Quick Actions (indices de navigation depuis main.dart) ───────────────────
class _QuickAction {
  final String  label;
  final String  sub;
  final IconData icon;
  final Color   color;
  final Color   bgColor;
  final int     navIndex;
  const _QuickAction({
    required this.label,
    required this.sub,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.navIndex,
  });
}

const _quickActions = [
  _QuickAction(
    label:    'Véhicules',
    sub:      'Gérer le parc',
    icon:     Icons.directions_car_rounded,
    color:    _D.indigo,
    bgColor:  _D.indigoL,
    navIndex: 3,
  ),
  _QuickAction(
    label:    'Clients',
    sub:      'Base utilisateurs',
    icon:     Icons.people_rounded,
    color:    _D.emerald,
    bgColor:  _D.emeraldL,
    navIndex: 4,
  ),
  _QuickAction(
    label:    'Pièces',
    sub:      'Inventaire',
    icon:     Icons.settings_rounded,
    color:    _D.amber,
    bgColor:  _D.amberL,
    navIndex: 1,
  ),
  _QuickAction(
    label:    'Affectation',
    sub:      'Pièces ↔ Véhicules',
    icon:     Icons.assignment_turned_in_rounded,
    color:    _D.sky,
    bgColor:  _D.skyL,
    navIndex: 2,
  ),
  _QuickAction(
    label:    'Garages PRO',
    sub:      'Dashboard partenaires',
    icon:     Icons.store_rounded,
    color:    _D.violet,
    bgColor:  _D.violetL,
    navIndex: 9,
  ),
  _QuickAction(
    label:    'Rendez-vous',
    sub:      'Planning & suivi',
    icon:     Icons.calendar_month_rounded,
    color:    _D.orange,
    bgColor:  _D.orangeL,
    navIndex: 11,
  ),
  _QuickAction(
    label:    'Avis clients',
    sub:      'Modération',
    icon:     Icons.star_rounded,
    color:    _D.rose,
    bgColor:  _D.roseL,
    navIndex: 12,
  ),
  _QuickAction(
    label:    'Analytiques',
    sub:      'Rapports & charts',
    icon:     Icons.analytics_rounded,
    color:    _D.textSec,
    bgColor:  _D.surface2,
    navIndex: 6,
  ),
];

// ═══════════════════════════════════════════════════════════════════════════════
// DASHBOARD SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class DashboardScreen extends StatefulWidget {
  /// Callback vers le shell principal pour changer d'onglet.
  /// Fourni par main.dart via le getter _pages.
  final void Function(int index)? onNavigate;

  const DashboardScreen({super.key, this.onNavigate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {

  final _service = DashboardService();

  late Future<DashboardStats> _statsFuture;
  int _touchedPieIndex = -1;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _statsFuture = _service.loadAllStats();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _navigate(int index) => widget.onNavigate?.call(index);

  void _refresh() => setState(() => _statsFuture = _service.loadAllStats());

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _D.bg,
      body: FutureBuilder<DashboardStats>(
        future: _statsFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return _buildSkeleton();
          }
          final stats = snap.data ?? const DashboardStats();
          return _buildContent(stats);
        },
      ),
    );
  }

  // ─── Skeleton loading ─────────────────────────────────────────────────────

  Widget _buildSkeleton() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _D.indigo, strokeWidth: 2.5),
          SizedBox(height: 16),
          Text('Chargement du tableau de bord…',
              style: TextStyle(color: _D.textSec, fontSize: 13)),
        ],
      ),
    );
  }

  // ─── Main content ─────────────────────────────────────────────────────────

  Widget _buildContent(DashboardStats stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(stats),
          const SizedBox(height: 28),
          _buildKpiGrid(stats),
          const SizedBox(height: 28),
          _buildGarageProSection(stats),
          const SizedBox(height: 28),
          _buildChartsRow(stats),
          const SizedBox(height: 28),
          _buildBottomRow(stats),
        ],
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(DashboardStats stats) {
    final now = DateTime.now();
    final h   = now.hour;
    final greeting = h < 12 ? 'Bonjour' : h < 18 ? 'Bon après-midi' : 'Bonsoir';
    final months  = ['Jan','Fév','Mar','Avr','Mai','Jui','Jul','Aoû','Sep','Oct','Nov','Déc'];
    final days    = ['Lun','Mar','Mer','Jeu','Ven','Sam','Dim'];
    final dateStr = '${days[now.weekday-1]} ${now.day} ${months[now.month-1]} ${now.year}';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A7C6F), Color(0xFF6BA89A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: const Color(0xFF4A7C6F).withOpacity(0.28),
          blurRadius: 24, offset: const Offset(0, 8),
        )],
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Date badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.wb_sunny_rounded,
                    color: Color(0xFFFDE68A), size: 13),
                const SizedBox(width: 6),
                Text(dateStr,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11, fontWeight: FontWeight.w600)),
              ]),
            ),
            const SizedBox(height: 12),
            Text('$greeting, Administrateur 👋',
                style: const TextStyle(
                  color: Colors.white, fontSize: 22,
                  fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            const SizedBox(height: 6),
            Text(
              'Bienvenue dans KARHABTI Admin — '
              '${stats.totalVehicles} véhicules · '
              '${stats.totalClients} clients · '
              '${stats.garagesActifs} garages actifs',
              style: TextStyle(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.72),
                  fontSize: 13, height: 1.5)),
            const SizedBox(height: 16),
            // Quick strip
            Row(children: [
              _hStat('${stats.totalVehicles}',   'Véhicules'),
              _hDiv(),
              _hStat('${stats.totalClients}',    'Clients'),
              _hDiv(),
              _hStat('${stats.garagesActifs}',   'Garages actifs'),
              _hDiv(),
              _hStat('${stats.rdvAujourdhui}',   'RDV aujourd\'hui'),
            ]),
          ]),
        ),
        const SizedBox(width: 24),
        // Avatar animé
        Stack(alignment: Alignment.center, children: [
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) => Container(
              width: 88, height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.2 + 0.15 * _pulseCtrl.value),
                  width: 2 + 2 * _pulseCtrl.value,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: _refresh,
            child: Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
              ),
              child: const Icon(Icons.admin_panel_settings_rounded,
                  color: Colors.white, size: 30),
            ),
          ),
        ]),
      ]),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.06, end: 0, duration: 350.ms);
  }

  Widget _hStat(String val, String lbl) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(val, style: const TextStyle(
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
      Text(lbl, style: TextStyle(
          color: Colors.white.withOpacity(0.7), fontSize: 11)),
    ],
  );

  Widget _hDiv() => Container(
    width: 1, height: 32, margin: const EdgeInsets.symmetric(horizontal: 14),
    color: Colors.white.withOpacity(0.25),
  );

  // ─── KPI Grid ─────────────────────────────────────────────────────────────

  Widget _buildKpiGrid(DashboardStats stats) {
    final kpis = stats.kpiItems;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Vue d\'ensemble', Icons.bar_chart_rounded),
        const SizedBox(height: 14),
        // Row 1 — 3 KPIs
        Row(children: List.generate(3, (i) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 2 ? 14 : 0),
            child: _kpiCard(kpis[i], i),
          ),
        ))),
        const SizedBox(height: 14),
        // Row 2 — 3 KPIs
        Row(children: List.generate(3, (i) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 2 ? 14 : 0),
            child: _kpiCard(kpis[i + 3], i + 3),
          ),
        ))),
      ],
    );
  }

  Widget _kpiCard(KpiItem k, int index) {
    final color  = Color(k.colorHex);
    final bgColor = Color(k.bgColorHex);
    return GestureDetector(
      onTap: () {
        // Navigation contextuelle selon le KPI
        if (k.label.contains('Véhicule')) {
          _navigate(3);
        } else if (k.label.contains('Client')) {
          _navigate(4);
        } else if (k.label.contains('Pièce')) {
          _navigate(1);
        } else if (k.label.contains('RDV')) {
          _navigate(11);
        } else if (k.label.contains('Garage')) {
          _navigate(9);
        } else if (k.label.contains('Note')) {
          _navigate(12);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _D.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _D.border),
          boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10, offset: const Offset(0, 2),
          )],
        ),
        child: Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(IconData(k.icon, fontFamily: 'MaterialIcons'), color: color, size: 19),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(k.value,
                  style: TextStyle(color: color, fontSize: 24,
                      fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              Text(k.label,
                  style: const TextStyle(color: _D.textPri, fontSize: 12,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Row(children: [
                Icon(
                  k.positive ? Icons.trending_up_rounded : Icons.warning_amber_rounded,
                  size: 11,
                  color: k.positive ? _D.emerald : _D.amber,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(k.delta,
                      style: TextStyle(
                          color: k.positive ? _D.emerald : _D.amber,
                          fontSize: 11, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    )
    .animate(delay: Duration(milliseconds: 80 * index))
    .fadeIn(duration: 350.ms)
    .slideY(begin: 0.1, end: 0, duration: 350.ms, curve: Curves.easeOut);
  }

  // ─── Garage PRO Section ───────────────────────────────────────────────────

  Widget _buildGarageProSection(DashboardStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          _sectionLabel('Garages PRO', Icons.store_rounded),
          const Spacer(),
          GestureDetector(
            onTap: () => _navigate(9),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _D.violetL,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _D.violet.withOpacity(0.3)),
              ),
              child: const Row(children: [
                Text('Voir le dashboard PRO',
                    style: TextStyle(color: _D.violet, fontSize: 12,
                        fontWeight: FontWeight.w600)),
                SizedBox(width: 5),
                Icon(Icons.arrow_forward_ios_rounded, size: 11, color: _D.violet),
              ]),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          // Stat cards garages
          Expanded(flex: 3, child: Row(children: [
            _garageStatCard('Total garages', '${stats.totalGarages}',
                Icons.store_rounded, _D.violet, _D.violetL, 9),
            const SizedBox(width: 12),
            _garageStatCard('Actifs', '${stats.garagesActifs}',
                Icons.visibility_rounded, _D.emerald, _D.emeraldL, 10),
            const SizedBox(width: 12),
            _garageStatCard('Vérifiés', '${stats.garagesVerifies}',
                Icons.verified_rounded, _D.sky, _D.skyL, 10),
            const SizedBox(width: 12),
            _garageStatCard('RDV ce mois', '${stats.rdvCeMois}',
                Icons.calendar_month_rounded, _D.amber, _D.amberL, 11),
          ])),
          const SizedBox(width: 16),
          // Note moyenne
          Expanded(
            child: _noteMoyenneCard(stats),
          ),
        ]),
        const SizedBox(height: 14),
        // RDV statuts strip
        _buildRdvStatutStrip(stats),
      ],
    ).animate(delay: 300.ms).fadeIn(duration: 400.ms);
  }

  Widget _garageStatCard(String label, String value, IconData icon,
      Color color, Color bgColor, int navIdx) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _navigate(navIdx),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _D.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _D.border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, color: color, size: 17),
            ),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(
                color: color, fontSize: 22, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(
                color: _D.textSec, fontSize: 11.5, fontWeight: FontWeight.w500)),
          ]),
        ),
      ),
    );
  }

  Widget _noteMoyenneCard(DashboardStats stats) {
    final note = stats.noteMoyenneGlobale;
    final color = note >= 4 ? _D.emerald : note >= 3 ? _D.amber : _D.rose;
    return GestureDetector(
      onTap: () => _navigate(12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _D.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _D.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.star_rounded, color: _D.amber, size: 17),
            const SizedBox(width: 8),
            const Text('Note moyenne', style: TextStyle(
                color: _D.textPri, fontSize: 13, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 14),
          Text(note.toStringAsFixed(1),
              style: TextStyle(color: color, fontSize: 36,
                  fontWeight: FontWeight.w900, letterSpacing: -1)),
          Text('sur 5.0 · ${stats.totalAvis} avis',
              style: const TextStyle(color: _D.textSec, fontSize: 11.5)),
          const SizedBox(height: 12),
          // Stars row
          Row(children: List.generate(5, (i) {
            final filled = i < note.floor();
            final half   = !filled && i < note;
            return Icon(
              half ? Icons.star_half_rounded : filled
                  ? Icons.star_rounded : Icons.star_outline_rounded,
              color: _D.amber, size: 18,
            );
          })),
        ]),
      ),
    );
  }

  Widget _buildRdvStatutStrip(DashboardStats stats) {
    final statuts = [
      ('En attente', stats.rdvEnAttente, _D.amber),
      ('Confirmés',  stats.rdvConfirme,  _D.emerald),
      ('Terminés',   stats.rdvTermine,   _D.sky),
      ('Annulés',    stats.rdvAnnule,    _D.rose),
      ('No show',    stats.rdvNoShow,    _D.textSec),
    ];
    final total = stats.rdvTotal > 0 ? stats.rdvTotal : 1;

    return GestureDetector(
      onTap: () => _navigate(11),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _D.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _D.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.donut_small_rounded, color: _D.indigo, size: 15),
            const SizedBox(width: 8),
            const Text('Répartition des rendez-vous',
                style: TextStyle(color: _D.textPri, fontSize: 13,
                    fontWeight: FontWeight.w700)),
            const Spacer(),
            Text('${stats.rdvTotal} total',
                style: const TextStyle(color: _D.textSec, fontSize: 11)),
          ]),
          const SizedBox(height: 14),
          // Progress bar segmentée
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: statuts.where((s) => s.$2 > 0).map((s) {
                final pct = s.$2 / total;
                return Flexible(
                  flex: (pct * 1000).round(),
                  child: Container(height: 8, color: s.$3),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          // Légende
          Wrap(
            spacing: 16, runSpacing: 6,
            children: statuts.map((s) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 8, height: 8,
                    decoration: BoxDecoration(color: s.$3, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 6),
                Text('${s.$1}  ', style: const TextStyle(color: _D.textSec, fontSize: 11)),
                Text('${s.$2}',
                    style: TextStyle(color: s.$3, fontSize: 11, fontWeight: FontWeight.w700)),
              ],
            )).toList(),
          ),
        ]),
      ),
    );
  }

  // ─── Charts Row ───────────────────────────────────────────────────────────

  Widget _buildChartsRow(DashboardStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Tendance & analyse', Icons.analytics_rounded),
        const SizedBox(height: 14),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 3, child: _buildTrendChart(stats)),
          const SizedBox(width: 16),
          Expanded(flex: 2, child: _buildTopGaragesList(stats)),
        ]),
      ],
    ).animate(delay: 450.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildTrendChart(DashboardStats stats) {
    final trend = stats.rdvTrend7j;
    final maxY  = trend.isEmpty ? 5.0 :
        (trend.map((p) => p.count).reduce((a, b) => a > b ? a : b) + 1).toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _D.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _D.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: _D.indigoL, borderRadius: BorderRadius.circular(9)),
            child: const Icon(Icons.show_chart_rounded, color: _D.indigo, size: 16),
          ),
          const SizedBox(width: 12),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Rendez-vous — 7 derniers jours',
                style: TextStyle(color: _D.textPri, fontSize: 13, fontWeight: FontWeight.w800)),
            Text('Données réelles depuis Supabase',
                style: TextStyle(color: _D.textSec, fontSize: 11)),
          ]),
        ]),
        const SizedBox(height: 20),
        SizedBox(
          height: 180,
          child: LineChart(LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) =>
                  FlLine(color: _D.border, strokeWidth: 0.8, dashArray: [4, 4]),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true, reservedSize: 24, interval: maxY > 5 ? null : 1,
                getTitlesWidget: (v, _) => Text('${v.toInt()}',
                    style: const TextStyle(color: _D.textHint, fontSize: 10)),
              )),
              bottomTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true, reservedSize: 20,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= trend.length) return const SizedBox.shrink();
                  final d = trend[i].date;
                  const days = ['L','M','Me','J','V','S','D'];
                  return Text(days[d.weekday - 1],
                      style: const TextStyle(color: _D.textHint, fontSize: 10));
                },
              )),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            minX: 0, maxX: 6, minY: 0, maxY: maxY,
            lineBarsData: [
              LineChartBarData(
                spots: trend.asMap().entries.map((e) =>
                    FlSpot(e.key.toDouble(), e.value.count.toDouble())).toList(),
                isCurved: true,
                curveSmoothness: 0.4,
                color: _D.indigo,
                barWidth: 2.5,
                dotData: FlDotData(show: true,
                    getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                      radius: 3.5, color: _D.indigo,
                      strokeWidth: 1.5, strokeColor: Colors.white,
                    )),
                belowBarData: BarAreaData(show: true,
                    gradient: LinearGradient(
                      colors: [_D.indigo.withOpacity(0.16), _D.indigo.withOpacity(0)],
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    )),
              ),
            ],
          )),
        ),
      ]),
    );
  }

  Widget _buildTopGaragesList(DashboardStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _D.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _D.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: _D.violetL, borderRadius: BorderRadius.circular(9)),
            child: const Icon(Icons.emoji_events_rounded, color: _D.violet, size: 16),
          ),
          const SizedBox(width: 12),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Top garages', style: TextStyle(
                color: _D.textPri, fontSize: 13, fontWeight: FontWeight.w800)),
            Text('Par nombre de RDV', style: TextStyle(color: _D.textSec, fontSize: 11)),
          ]),
        ]),
        const SizedBox(height: 16),
        if (stats.topGarages.isEmpty)
          const Center(child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Aucun garage enregistré', style: TextStyle(color: _D.textHint, fontSize: 13)),
          ))
        else
          ...stats.topGarages.asMap().entries.map((e) =>
              _topGarageRow(e.value, e.key)),
      ]),
    );
  }

  Widget _topGarageRow(TopGarageItem g, int rank) {
    final medals = ['🥇','🥈','🥉'];
    return GestureDetector(
      onTap: () => _navigate(10),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Text(rank < 3 ? medals[rank] : '${rank+1}.',
              style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(g.nom, style: const TextStyle(
                  color: _D.textPri, fontSize: 12.5, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis),
              Text(g.ville, style: const TextStyle(color: _D.textSec, fontSize: 11)),
            ],
          )),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(children: [
              const Icon(Icons.star_rounded, color: _D.amber, size: 12),
              const SizedBox(width: 3),
              Text(g.note.toStringAsFixed(1),
                  style: const TextStyle(color: _D.amber, fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ]),
            Text('${g.nbRdv} RDV',
                style: const TextStyle(color: _D.textSec, fontSize: 10)),
          ]),
          if (g.estVerifie) ...[
            const SizedBox(width: 6),
            const Icon(Icons.verified_rounded, color: _D.sky, size: 14),
          ],
        ]),
      ),
    );
  }

  // ─── Bottom Row ───────────────────────────────────────────────────────────

  Widget _buildBottomRow(DashboardStats stats) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(flex: 3, child: _buildPieChartSection(stats)),
      const SizedBox(width: 16),
      Expanded(flex: 2, child: _buildQuickActions()),
    ]);
  }

  Widget _buildPieChartSection(DashboardStats stats) {
    final total = stats.totalGarages;
    if (total == 0) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: _D.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _D.border),
        ),
        child: const Center(child: Text('Aucun garage',
            style: TextStyle(color: _D.textHint, fontSize: 13))),
      );
    }

    final nonVerifies = stats.garagesActifs - stats.garagesVerifies;
    final inactifs    = stats.totalGarages  - stats.garagesActifs;

    final sections = [
      ('Vérifiés',    stats.garagesVerifies.toDouble(), _D.emerald),
      ('Non vérifiés',nonVerifies > 0 ? nonVerifies.toDouble() : 0.0, _D.amber),
      ('Inactifs',    inactifs > 0    ? inactifs.toDouble()    : 0.0, _D.rose),
    ].where((s) => s.$2 > 0).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _D.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _D.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: _D.emeraldL, borderRadius: BorderRadius.circular(9)),
            child: const Icon(Icons.pie_chart_rounded, color: _D.emerald, size: 16),
          ),
          const SizedBox(width: 12),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Statut des garages', style: TextStyle(
                color: _D.textPri, fontSize: 13, fontWeight: FontWeight.w800)),
            Text('Répartition actuelle', style: TextStyle(color: _D.textSec, fontSize: 11)),
          ]),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          SizedBox(
            width: 130, height: 130,
            child: Stack(alignment: Alignment.center, children: [
              PieChart(PieChartData(
                pieTouchData: PieTouchData(touchCallback: (FlTouchEvent event, PieTouchResponse? resp) {
                  setState(() {
                    if (resp == null || event is FlPointerExitEvent) {
                      _touchedPieIndex = -1;
                    } else {
                      _touchedPieIndex = resp.touchedSection?.touchedSectionIndex ?? -1;
                    }
                  });
                }),
                borderData: FlBorderData(show: false),
                sectionsSpace: 3,
                centerSpaceRadius: 34,
                sections: sections.asMap().entries.map((e) {
                  final touched = e.key == _touchedPieIndex;
                  final pct = ((e.value.$2 / total) * 100).round();
                  return PieChartSectionData(
                    value: e.value.$2,
                    title: '$pct%',
                    color: e.value.$3,
                    radius: touched ? 48 : 40,
                    titleStyle: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: touched ? 12 : 10,
                    ),
                  );
                }).toList(),
              )),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text('$total', style: const TextStyle(
                    color: _D.textPri, fontSize: 18, fontWeight: FontWeight.w900)),
                const Text('garages', style: TextStyle(color: _D.textSec, fontSize: 9)),
              ]),
            ]),
          ),
          const SizedBox(width: 20),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: sections.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                Container(width: 10, height: 10,
                    decoration: BoxDecoration(
                        color: s.$3, borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 8),
                Expanded(child: Text(s.$1,
                    style: const TextStyle(color: _D.textSec, fontSize: 11.5))),
                Text('${s.$2.toInt()}',
                    style: TextStyle(color: s.$3, fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ]),
            )).toList(),
          )),
        ]),
      ]),
    ).animate(delay: 550.ms).fadeIn(duration: 400.ms);
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _D.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _D.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: _D.amberL, borderRadius: BorderRadius.circular(9)),
            child: const Icon(Icons.bolt_rounded, color: _D.amber, size: 16),
          ),
          const SizedBox(width: 10),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Actions rapides', style: TextStyle(
                color: _D.textPri, fontSize: 13, fontWeight: FontWeight.w800)),
            Text('Navigation directe', style: TextStyle(color: _D.textSec, fontSize: 11)),
          ]),
        ]),
        const SizedBox(height: 14),
        ...List.generate(_quickActions.length, (i) {
          final a = _quickActions[i];
          return Padding(
            padding: EdgeInsets.only(bottom: i < _quickActions.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => _navigate(a.navIndex),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _D.surface2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _D.border),
                ),
                child: Row(children: [
                  Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                        color: a.bgColor, borderRadius: BorderRadius.circular(8)),
                    child: Icon(a.icon, size: 15, color: a.color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.label, style: const TextStyle(
                          color: _D.textPri, fontSize: 12.5, fontWeight: FontWeight.w700)),
                      Text(a.sub, style: const TextStyle(
                          color: _D.textSec, fontSize: 10.5)),
                    ],
                  )),
                  Icon(Icons.arrow_forward_ios_rounded, size: 11, color: a.color),
                ]),
              ),
            ).animate(delay: Duration(milliseconds: 600 + 60 * i))
             .fadeIn(duration: 280.ms)
             .slideX(begin: 0.05, end: 0, duration: 280.ms),
          );
        }),
      ]),
    ).animate(delay: 600.ms).fadeIn(duration: 400.ms);
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Widget _sectionLabel(String label, IconData icon) {
    return Row(children: [
      Icon(icon, size: 15, color: _D.textSec),
      const SizedBox(width: 8),
      Text(label, style: const TextStyle(
          color: _D.textSec, fontSize: 12,
          fontWeight: FontWeight.w700, letterSpacing: 0.3)),
    ]);
  }
}

class AppStyle {
  static const TextStyle caption = TextStyle(fontSize: 12, color: _D.textSec);
}