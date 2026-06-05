import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/piece_recommendation_model.dart';
import '../../models/piece_validation_model.dart';
import '../../models/vehicule_analytics_models.dart';
import '../../services/responsable_technicien_service.dart';
import '../../theme/karhabti_tokens.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
class _DS {
  static const Color background   = Color(0xFFFAFBFF);
  static const Color surface      = Color(0xFFFFFFFF);
  static const Color surfaceAlt   = Color(0xFFF4F6FC);
  static const Color surfaceBlue  = Color(0xFFEEF2FF);

  static const Color gold         = Color(0xFFE6A817);
  static const Color goldLight    = Color(0xFFFFF4D9);
  static const Color accent       = Color(0xFF5B8DEF);
  static const Color accentLight  = Color(0xFFE8EFFF);

  static const Color success      = Color(0xFF34C78A);
  static const Color successLight = Color(0xFFDFF5EC);
  static const Color warning      = Color(0xFFF5A623);
  static const Color warningLight = Color(0xFFFFF3DC);
  static const Color danger       = Color(0xFFEF5B5B);
  static const Color dangerLight  = Color(0xFFFFEAEA);
  static const Color info         = Color(0xFF5B8DEF);

  static const Color textPri  = Color(0xFF1A1F36);
  static const Color textSec  = Color(0xFF6B7280);
  static const Color textMute = Color(0xFFB0B7C3);
  static const Color border   = Color(0xFFE8ECF4);

  static const double radiusSm = 10;
  static const double radiusMd = 16;
  static const double radiusLg = 22;

  static List<BoxShadow> shadowSm = [
    const BoxShadow(color: Color(0x0A1A1F36), blurRadius: 8, offset: Offset(0, 2)),
  ];
  static List<BoxShadow> shadowGold = [
    const BoxShadow(color: Color(0x30E6A817), blurRadius: 18, offset: Offset(0, 4)),
  ];
}

// ─── Écran principal ──────────────────────────────────────────────────────────
class VehiculeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> vehiculeData;
  const VehiculeDetailScreen({super.key, required this.vehiculeData});

  @override
  State<VehiculeDetailScreen> createState() => _VehiculeDetailScreenState();
}

class _VehiculeDetailScreenState extends State<VehiculeDetailScreen>
    with TickerProviderStateMixin {
  final _service = ResponsableTechnicienService();
  DateFormat get _dateFmt => DateFormat('dd/MM/yyyy', 'fr_FR');

  final _types = const [
    'batterie', 'freins', 'pneus', 'embrayage',
    'courroie', 'amortisseurs', 'filtres', 'huile_moteur', 'refroidissement',
  ];

  late TabController _tabCtrl;
  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  bool _loading = true;
  VehiculeComplet? _data;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, PieceRecommendation?> _recs = {};

  String get _immat => widget.vehiculeData['immatriculation'] as String;

  @override
  void initState() {
    super.initState();
    _tabCtrl  = TabController(length: 4, vsync: this);
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim  = CurvedAnimation(parent: _fadeCtrl,  curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    for (final t in _types) {
      _controllers[t] = TextEditingController();
    }
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _fadeCtrl.reset();
    _slideCtrl.reset();
    final complet = await _service.getVehiculeComplet(_immat);
    final all     = await _service.getAllRecommendations(_immat);
    for (final t in _types) {
      PieceRecommendation? rec;
      for (final item in all) { if (item.pieceType == t) { rec = item; break; } }
      _recs[t] = rec;
      _controllers[t]!.text = rec?.recommendation ?? '';
    }
    if (mounted) {
      setState(() { _data = complet; _loading = false; });
      _fadeCtrl.forward();
      _slideCtrl.forward();
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final v = _data?.voiture;

    return Scaffold(
      backgroundColor: _DS.background,
      // ── AppBar fixe et propre — pas de NestedScrollView / SliverAppBar ──
      appBar: _buildAppBar(v),
      body: _loading
          ? _buildLoader()
          : _data == null
              ? _buildEmptyState('Véhicule introuvable dans la base.')
              : FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: TabBarView(
                      controller: _tabCtrl,
                      children: [
                        _buildSyntheseTab(),
                        _buildVoitureTab(),
                        _buildFacteurTab(),
                        _buildPiecesTab(),
                      ],
                    ),
                  ),
                ),
    );
  }

  // ─── AppBar classique (stable, pas de overflow) ───────────────────────────
  PreferredSizeWidget _buildAppBar(Map<String, dynamic>? v) {
    final marque  = v != null ? '${v['marque']} ${v['modele']}' : _immat;
    final detail  = v != null ? '${v['moteur']} · ${v['annee']}' : '';

    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 56 + 48),
      // kToolbarHeight(56) + header info(56) + TabBar(48) = 160
      child: Container(
        color: _DS.surface,
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Ligne titre ─────────────────────────────────────────────
              SizedBox(
                height: kToolbarHeight + 20,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Bouton retour
                      _CircleIconBtn(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 12),
                      // Icône véhicule
                      Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_DS.goldLight, Color(0xFFFFE49A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: _DS.shadowGold,
                        ),
                        child: const Icon(Icons.directions_car_filled_rounded,
                            color: _DS.gold, size: 24),
                      ),
                      const SizedBox(width: 12),
                      // Marque + moteur
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(marque,
                                style: const TextStyle(
                                  color: _DS.textPri, fontSize: 17,
                                  fontWeight: FontWeight.w800, letterSpacing: -0.3,
                                ),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                            if (detail.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(detail,
                                  style: const TextStyle(
                                      color: _DS.textSec, fontSize: 12,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ],
                        ),
                      ),
                      // Badge immat
                      _ImmatBadge(immat: _immat),
                    ],
                  ),
                ),
              ),

              // Séparateur
              Divider(height: 0, thickness: 1, color: _DS.border),

              // ── TabBar ──────────────────────────────────────────────────
              _buildTabBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: _DS.surface,
      height: 48,
      child: TabBar(
        controller: _tabCtrl,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: _DS.goldLight,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: _DS.border,
        labelColor: _DS.gold,
        unselectedLabelColor: _DS.textSec,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        tabs: const [
          Tab(text: 'Synthèse'),
          Tab(text: 'Véhicule'),
          Tab(text: 'Facteurs'),
          Tab(text: 'Pièces'),
        ],
      ),
    );
  }

  // ─── Loader ───────────────────────────────────────────────────────────────
  Widget _buildLoader() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(
        width: 48, height: 48,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation(_DS.gold),
          backgroundColor: _DS.goldLight,
        ),
      ),
      const SizedBox(height: 16),
      const Text('Chargement…', style: TextStyle(color: _DS.textSec, fontSize: 14)),
    ]),
  );

  Widget _buildEmptyState(String msg) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: _DS.surfaceAlt, shape: BoxShape.circle),
        child: const Icon(Icons.directions_car, color: _DS.textMute, size: 40),
      ),
      const SizedBox(height: 16),
      Text(msg, style: const TextStyle(color: _DS.textSec, fontSize: 14)),
    ]),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // ONGLET 1 — SYNTHÈSE
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSyntheseTab() {
    final d       = _data!;
    final metrics = predictionMetricsFromMap(d.prediction);
    final events  = maintenanceEventsFromMap(d.maintenanceDates);
    final client  = d.client;

    return RefreshIndicator(
      color: _DS.gold,
      backgroundColor: _DS.surface,
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          // Client
          if (client != null) ...[
            _KCard(
              icon: Icons.person_rounded,
              iconBg: _DS.accentLight, iconColor: _DS.accent,
              title: 'Client',
              child: Row(children: [
                _KBadge(label: _str(client['nom_client']), icon: Icons.badge_rounded),
                const SizedBox(width: 10),
                _KBadge(label: _str(client['telephone']),  icon: Icons.phone_rounded),
              ]),
            ),
            const SizedBox(height: 14),
          ],

          // Prédictions
          _KCard(
            icon: Icons.insights_rounded,
            iconBg: _DS.goldLight, iconColor: _DS.gold,
            title: 'Prédictions d\'usure',
            subtitle: _predictionSubtitle(d.prediction),
            child: metrics.isEmpty
                ? _noData('Aucune prédiction enregistrée pour ce véhicule.')
                : Column(children: [
                    // ── Graphiques côte à côte ──────────────────────────
                    SizedBox(
                      height: 260,
                      child: Row(
                        children: [
                          // Courbe d'évolution (gauche)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 4, bottom: 6),
                                  child: Text('Évolution',
                                      style: TextStyle(
                                          color: _DS.textSec, fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3)),
                                ),
                                Expanded(child: _wearLineChart(metrics)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Radar (droite)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 4, bottom: 6),
                                  child: Text('Radar global',
                                      style: TextStyle(
                                          color: _DS.textSec, fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3)),
                                ),
                                Expanded(child: _radarChart(metrics)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...metrics.map(_wearBar),
                    const SizedBox(height: 8),
                    _legendRow(),
                  ]),
          ),
          const SizedBox(height: 14),

          // Historique entretiens
          _KCard(
            icon: Icons.history_rounded,
            iconBg: _DS.accentLight, iconColor: _DS.accent,
            title: 'Historique des entretiens',
            child: events.every((e) => e.date == null)
                ? _noData('Aucune date d\'entretien enregistrée.')
                : Column(children: [
                    SizedBox(height: 200, child: _maintenanceBarChart(events)),
                    const SizedBox(height: 16),
                    ...events.map(_maintenanceTile),
                  ]),
          ),
        ],
      ),
    );
  }

  String? _predictionSubtitle(Map<String, dynamic>? p) {
    if (p == null) return null;
    final next = p['next_replacement_date'];
    if (next == null) return null;
    try {
      return 'Prochain remplacement : ${_dateFmt.format(DateTime.parse(next.toString()))}';
    } catch (_) { return null; }
  }

  // ─── Line Chart d'évolution d'usure ──────────────────────────────────────
  Widget _wearLineChart(List<PredictionMetric> metrics) {
    // Simule une courbe d'évolution sur 6 mois à partir des valeurs actuelles
    // On projette chaque métrique avec une légère progression
    final spots = <FlSpot>[];
    for (int i = 0; i < metrics.length; i++) {
      spots.add(FlSpot(i.toDouble(), metrics[i].value.clamp(0, 100)));
    }

    // Courbe "tendance passée" simulée (valeurs -20% il y a 3 mois)
    final spotsOld = <FlSpot>[];
    for (int i = 0; i < metrics.length; i++) {
      final older = (metrics[i].value * 0.75).clamp(0.0, 100.0);
      spotsOld.add(FlSpot(i.toDouble(), older));
    }

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 105,
        clipData: FlClipData.all(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: _DS.border, strokeWidth: 1, dashArray: [4, 4]),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= metrics.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    metrics[i].label.split(' ').first.substring(0, 3),
                    style: TextStyle(color: _DS.textMute, fontSize: 8,
                        fontWeight: FontWeight.w600),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 25,
              getTitlesWidget: (v, _) => Text(
                '${v.toInt()}',
                style: TextStyle(color: _DS.textMute, fontSize: 8),
              ),
            ),
          ),
        ),
        lineBarsData: [
          // Courbe passée (gris)
          LineChartBarData(
            spots: spotsOld,
            isCurved: true,
            color: _DS.textMute.withOpacity(0.5),
            barWidth: 1.5,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
            dashArray: [4, 4],
          ),
          // Courbe actuelle (dégradé gold → danger selon valeur)
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: LinearGradient(
              colors: [_DS.success, _DS.warning, _DS.danger],
            ),
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) {
                final col = _wearColor(spot.y);
                return FlDotCirclePainter(
                  radius: 3.5,
                  color: col,
                  strokeWidth: 1.5,
                  strokeColor: _DS.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  _DS.gold.withValues(alpha: 0.15),
                  _DS.danger.withValues(alpha: 0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: _DS.surface,
            tooltipBorder: BorderSide(color: _DS.border),
            getTooltipItems: (spots) => spots.map((s) {
              if (s.barIndex == 0) return null;
              final m = metrics[s.x.toInt()];
              return LineTooltipItem(
                '${m.label.split(' ').first}\n${s.y.toStringAsFixed(0)} %',
                TextStyle(color: _wearColor(s.y), fontSize: 10,
                    fontWeight: FontWeight.w700),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // ─── Radar Chart ─────────────────────────────────────────────────────────
  Widget _radarChart(List<PredictionMetric> metrics) {
    return RadarChart(
      RadarChartData(
        radarShape: RadarShape.polygon,
        radarBorderData: BorderSide(color: _DS.border, width: 1.5),
        gridBorderData: BorderSide(color: _DS.border, width: 0.6),
        tickBorderData: BorderSide.none,
        tickCount: 4,
        ticksTextStyle: TextStyle(color: _DS.textMute, fontSize: 9),
        titleTextStyle: TextStyle(color: _DS.textSec, fontSize: 10,
            fontWeight: FontWeight.w600),
        titlePositionPercentageOffset: 0.18,
        getTitle: (index, _) {
          if (index >= metrics.length) return RadarChartTitle(text: '');
          final short = metrics[index].label.split(' ').first;
          return RadarChartTitle(text: short, angle: 0);
        },
        dataSets: [
          RadarDataSet(
            fillColor: _DS.gold.withOpacity(0.18),
            borderColor: _DS.gold,
            borderWidth: 2,
            entryRadius: 4,
            dataEntries: metrics
                .map((m) => RadarEntry(value: m.value.clamp(0, 100)))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ─── Barre d'usure ────────────────────────────────────────────────────────
  Widget _wearBar(PredictionMetric m) {
    final color = _wearColor(m.value);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(m.label,
                style: const TextStyle(color: _DS.textPri, fontSize: 13,
                    fontWeight: FontWeight.w500))),
            Text('${m.value.toStringAsFixed(0)} %',
                style: TextStyle(color: color, fontWeight: FontWeight.w800,
                    fontSize: 14)),
            const SizedBox(width: 8),
            _RiskChip(value: m.value),
          ]),
          const SizedBox(height: 8),
          Stack(children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            FractionallySizedBox(
              widthFactor: (m.value.clamp(0, 100)) / 100,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [color.withOpacity(0.7), color]),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  // ─── Bar chart entretiens ─────────────────────────────────────────────────
  Widget _maintenanceBarChart(List<MaintenanceEvent> events) {
    final withDates = events.where((e) => e.date != null).toList();
    if (withDates.isEmpty) return const SizedBox.shrink();

    final now     = DateTime.now();
    final maxDays = withDates
        .map((e) => now.difference(e.date!).inDays.toDouble())
        .fold<double>(0, (a, b) => a > b ? a : b)
        .clamp(1, 3650);

    return BarChart(BarChartData(
      maxY: maxDays * 1.15,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: _DS.border, strokeWidth: 1, dashArray: [4, 4]),
      ),
      titlesData: FlTitlesData(
        topTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 38,
            getTitlesWidget: (v, _) => Text('${v.toInt()}j',
                style: const TextStyle(color: _DS.textMute, fontSize: 10)),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= withDates.length) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(withDates[i].label.substring(0, 3),
                    style: const TextStyle(color: _DS.textSec, fontSize: 10,
                        fontWeight: FontWeight.w600)),
              );
            },
          ),
        ),
      ),
      barGroups: List.generate(withDates.length, (i) {
        final days = now.difference(withDates[i].date!).inDays.toDouble();
        return BarChartGroupData(x: i, barRods: [
          BarChartRodData(
            toY: days,
            gradient: LinearGradient(
              colors: [_DS.accent.withOpacity(0.6), _DS.accent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ]);
      }),
    ));
  }

  Widget _maintenanceTile(MaintenanceEvent e) {
    final rel      = e.date != null ? _relativeDate(e.date!) : 'Non renseigné';
    final hasDate  = e.date != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: hasDate ? _DS.successLight : _DS.surfaceAlt,
        borderRadius: BorderRadius.circular(_DS.radiusMd),
        border: Border.all(
            color: hasDate ? _DS.success.withOpacity(0.3) : _DS.border),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: hasDate ? _DS.success.withOpacity(0.15) : _DS.border,
            shape: BoxShape.circle,
          ),
          child: Icon(
            hasDate ? Icons.check_rounded : Icons.help_outline_rounded,
            color: hasDate ? _DS.success : _DS.textMute,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(e.label, style: const TextStyle(color: _DS.textPri,
                fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 2),
            Text(rel, style: const TextStyle(color: _DS.textSec, fontSize: 12)),
          ],
        )),
        if (e.date != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _DS.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _DS.border),
            ),
            child: Text(_dateFmt.format(e.date!),
                style: const TextStyle(color: _DS.textSec, fontSize: 11,
                    fontWeight: FontWeight.w500)),
          ),
      ]),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ONGLET 2 — VÉHICULE
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildVoitureTab() {
    final v = _data!.voiture;
    final items = voitureFieldLabels.entries
        .map((e) => _DetailItem(e.value, _formatVoitureValue(e.key, v[e.key])))
        .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        _KCard(
          icon: Icons.description_rounded,
          iconBg: _DS.accentLight, iconColor: _DS.accent,
          title: 'Fiche véhicule',
          child: _detailGrid(items),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ONGLET 3 — FACTEURS
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildFacteurTab() {
    final f = _data!.facteur;
    if (f == null) return _buildEmptyState('Aucune fiche facteur d\'usure pour ce véhicule.');
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [_DS.accentLight, _DS.surfaceBlue],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(_DS.radiusMd),
            border: Border.all(color: Color(0x335B8DEF)),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline_rounded, color: _DS.accent, size: 20),
            const SizedBox(width: 12),
            const Expanded(child: Text(
              'Ces données décrivent le contexte d\'utilisation '
              'et l\'état des pièces au moment de l\'analyse prédictive.',
              style: TextStyle(color: _DS.accent, fontSize: 13, height: 1.4,
                  fontWeight: FontWeight.w500),
            )),
          ]),
        ),
        ...facteurSections.map((section) {
          final fields = section.fields
              .map((field) =>
                  _DetailItem(field.label, _formatFacteurValue(f[field.key])))
              .toList();
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _KCard(
              icon: section.icon,
              iconBg: _DS.goldLight, iconColor: _DS.gold,
              title: section.title,
              child: _detailGrid(fields),
            ),
          );
        }),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ONGLET 4 — PIÈCES
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildPiecesTab() {
    final immat = _immat;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: _types.asMap().entries.map((entry) {
        return _AnimatedPieceCard(
          index: entry.key,
          type:  entry.value,
          immat: immat,
          rec:   _recs[entry.value],
          ctrl:  _controllers[entry.value]!,
          onSave:     () => _saveRecommendation(immat, entry.value),
          onValidate: () => _validateReplacement(immat, entry.value),
        );
      }).toList(),
    );
  }

  // ─── Actions ──────────────────────────────────────────────────────────────
  Future<void> _saveRecommendation(String immat, String t) async {
    final me = await _service.getMyProfile();
    if (me == null) return;
    await _service.upsertRecommendation(PieceRecommendation(
      id: _recs[t]?.id ?? '',
      responsableId: me.id,
      immatriculation: immat,
      pieceType: t,
      recommendation: _controllers[t]!.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
    if (mounted) {
      _showSnack('Recommandation enregistrée',
        icon: Icons.check_circle_rounded, color: _DS.success);
    }
  }

  Future<void> _validateReplacement(String immat, String t) async {
    final me = await _service.getMyProfile();
    if (me == null) return;
    await _service.validerRemplacement(PieceValidation(
      id: '',
      responsableId: me.id,
      immatriculation: immat,
      pieceType: t,
      dateRemplacement: DateTime.now(),
      note: _controllers[t]!.text.trim().isEmpty ? null : _controllers[t]!.text.trim(),
    ));
    if (mounted) {
      _showSnack('Remplacement validé',
        icon: Icons.verified_rounded, color: _DS.gold);
    }
  }

  void _showSnack(String msg, {required IconData icon, required Color color}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: _DS.surface,
      elevation: 6,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_DS.radiusMd)),
      content: Row(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Text(msg, style: const TextStyle(color: _DS.textPri,
            fontWeight: FontWeight.w600)),
      ]),
    ));
  }

  // ─── Helpers layout ───────────────────────────────────────────────────────
  Widget _detailGrid(List<_DetailItem> items) {
    return LayoutBuilder(builder: (context, constraints) {
      final twoCols = constraints.maxWidth > 500;
      if (!twoCols) {
        return Column(children: items.map((i) => _detailRow(i.label, i.value)).toList());
      }
      return Wrap(
        spacing: 16, runSpacing: 0,
        children: items.map((i) => SizedBox(
          width: (constraints.maxWidth - 16) / 2,
          child: _detailRow(i.label, i.value),
        )).toList(),
      );
    });
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: _DS.textMute, fontSize: 11,
            fontWeight: FontWeight.w600, letterSpacing: 0.3)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: _DS.textPri, fontSize: 13,
            fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _noData(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(children: [
        const Icon(Icons.inbox_rounded, color: _DS.textMute, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(text,
            style: const TextStyle(color: _DS.textMute, fontSize: 13))),
      ]),
    );
  }

  Widget _legendRow() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      _legendDot('Faible',   _DS.success),
      const SizedBox(width: 20),
      _legendDot('Modéré',   _DS.warning),
      const SizedBox(width: 20),
      _legendDot('Élevé',    _DS.danger),
      const SizedBox(width: 20),
      _legendDot('Tendance', _DS.textMute),
    ]);
  }

  Widget _legendDot(String label, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 9, height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(color: _DS.textSec, fontSize: 11,
          fontWeight: FontWeight.w500)),
    ]);
  }

  Color _wearColor(double v) {
    if (v < 40) return _DS.success;
    if (v < 70) return _DS.warning;
    return _DS.danger;
  }

  String _str(dynamic v) => v == null || v.toString().isEmpty ? '—' : v.toString();

  String _formatVoitureValue(String key, dynamic v) {
    if (v == null) return '—';
    if (key == 'total_km' || key == 'daily_km') return _formatKm(v);
    if (key == 'poids') return '${(v as num).toStringAsFixed(0)} kg';
    return v.toString();
  }

  String _formatFacteurValue(dynamic v) {
    if (v == null || v.toString().isEmpty) return '—';
    if (v is String && v.contains('-') && v.length >= 8) {
      try { return _dateFmt.format(DateTime.parse(v)); } catch (_) {}
    }
    if (v is num && v is double) return v.toStringAsFixed(1);
    return v.toString();
  }

  String _formatKm(dynamic v) {
    if (v == null) return '—';
    final n = (v as num).toDouble();
    return '${NumberFormat.decimalPattern('fr').format(n)} km';
  }

  String _relativeDate(DateTime d) {
    final days = DateTime.now().difference(d).inDays;
    if (days == 0) return 'Aujourd\'hui';
    if (days == 1) return 'Il y a 1 jour';
    if (days < 30) return 'Il y a $days jours';
    if (days < 365) return 'Il y a ${(days / 30).floor()} mois';
    return 'Il y a ${(days / 365).floor()} an(s)';
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SOUS-WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

/// Badge immatriculation
class _ImmatBadge extends StatelessWidget {
  final String immat;
  const _ImmatBadge({required this.immat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _DS.goldLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0x66E6A817)),
      ),
      child: Text(immat, style: const TextStyle(
          color: _DS.gold, fontSize: 12,
          fontWeight: FontWeight.w800, letterSpacing: 0.8)),
    );
  }
}

/// Carte section
class _KCard extends StatelessWidget {
  final IconData icon;
  final Color    iconBg;
  final Color    iconColor;
  final String   title;
  final String?  subtitle;
  final Widget   child;

  const _KCard({
    required this.icon, required this.iconBg, required this.iconColor,
    required this.title, required this.child, this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _DS.surface,
        borderRadius: BorderRadius.circular(_DS.radiusMd),
        border: Border.all(color: _DS.border),
        boxShadow: _DS.shadowSm,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: _DS.textPri, fontSize: 15,
                  fontWeight: FontWeight.w700)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: const TextStyle(color: _DS.gold,
                    fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ],
          )),
        ]),
        const SizedBox(height: 16),
        Divider(height: 0, thickness: 1, color: _DS.border),
        const SizedBox(height: 16),
        child,
      ]),
    );
  }
}

/// Badge info (client)
class _KBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  const _KBadge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _DS.surfaceAlt,
        borderRadius: BorderRadius.circular(_DS.radiusSm),
        border: Border.all(color: _DS.border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: _DS.accent),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: _DS.textPri, fontSize: 12,
            fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

/// Chip de risque
class _RiskChip extends StatelessWidget {
  final double value;
  const _RiskChip({required this.value});

  @override
  Widget build(BuildContext context) {
    final (label, color, bg) = switch (value) {
      < 40 => ('OK',        _DS.success, _DS.successLight),
      < 70 => ('Surveiller', _DS.warning, _DS.warningLight),
      _    => ('Critique',  _DS.danger,  _DS.dangerLight),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10,
          fontWeight: FontWeight.w800)),
    );
  }
}

/// Bouton icône circulaire
class _CircleIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: _DS.surfaceAlt,
          shape: BoxShape.circle,
          border: Border.all(color: _DS.border),
        ),
        child: Icon(icon, size: 16, color: _DS.textPri),
      ),
    );
  }
}

/// Carte pièce avec animation d'entrée échelonnée
class _AnimatedPieceCard extends StatefulWidget {
  final int index;
  final String type;
  final String immat;
  final PieceRecommendation? rec;
  final TextEditingController ctrl;
  final VoidCallback onSave;
  final VoidCallback onValidate;

  const _AnimatedPieceCard({
    required this.index, required this.type, required this.immat,
    required this.rec, required this.ctrl,
    required this.onSave, required this.onValidate,
  });

  @override
  State<_AnimatedPieceCard> createState() => _AnimatedPieceCardState();
}

class _AnimatedPieceCardState extends State<_AnimatedPieceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  static const Map<String, IconData> _pieceIcons = {
    'batterie':        Icons.battery_charging_full_rounded,
    'freins':          Icons.speed_rounded,
    'pneus':           Icons.tire_repair_rounded,
    'embrayage':       Icons.settings_rounded,
    'courroie':        Icons.loop_rounded,
    'amortisseurs':    Icons.compress_rounded,
    'filtres':         Icons.filter_alt_rounded,
    'huile_moteur':    Icons.opacity_rounded,
    'refroidissement': Icons.ac_unit_rounded,
  };

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 450));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final iconData = _pieceIcons[widget.type] ?? Icons.build_rounded;
    final hasRec   = widget.rec != null;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _DS.surface,
            borderRadius: BorderRadius.circular(_DS.radiusMd),
            border: Border.all(
                color: hasRec ? Color(0x4DE6A817) : _DS.border),
            boxShadow: _DS.shadowSm,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // En-tête
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: hasRec ? _DS.goldLight : _DS.surfaceAlt,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(_DS.radiusMd)),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: hasRec ? Color(0x33E6A817) : _DS.border,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(iconData,
                      color: hasRec ? _DS.gold : _DS.textMute, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  widget.type.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    color: hasRec ? _DS.gold : _DS.textSec,
                    fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.6,
                  ),
                )),
                if (hasRec)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Color(0x26E6A817),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Recommandation saisie',
                        style: TextStyle(color: _DS.gold, fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ),
              ]),
            ),
            // Corps
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                TextField(
                  controller: widget.ctrl,
                  maxLines: 2,
                  style: const TextStyle(color: _DS.textPri, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Entrez une recommandation…',
                    hintStyle: const TextStyle(color: _DS.textMute, fontSize: 12),
                    filled: true,
                    fillColor: _DS.surfaceAlt,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: _DS.border)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: _DS.border)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: _DS.gold, width: 1.5)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _KButton(
                    label: 'Enregistrer',
                    icon:  Icons.save_outlined,
                    onTap: widget.onSave,
                    filled: false,
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: _KButton(
                    label: 'Valider remplacement',
                    icon:  Icons.verified_rounded,
                    onTap: widget.onValidate,
                    filled: true,
                  )),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Bouton Karhabti
class _KButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  const _KButton({required this.label, required this.icon,
      required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: filled ? _DS.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: filled ? _DS.gold : _DS.border),
          boxShadow: filled ? _DS.shadowGold : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15,
                color: filled ? const Color(0xFF1A1200) : _DS.gold),
            const SizedBox(width: 6),
            Flexible(child: Text(label,
                style: TextStyle(
                  color: filled ? const Color(0xFF1A1200) : _DS.gold,
                  fontSize: 12, fontWeight: FontWeight.w700,
                ),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────
class _DetailItem {
  final String label;
  final String value;
  const _DetailItem(this.label, this.value);
}