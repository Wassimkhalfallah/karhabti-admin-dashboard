// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import '../../widgets/stat_card.dart';
import '../../services/garage_pro_service.dart';

class GaragesProDashboard extends StatefulWidget {
  const GaragesProDashboard({super.key});

  @override
  State<GaragesProDashboard> createState() => _GaragesProDashboardState();
}

class _GaragesProDashboardState extends State<GaragesProDashboard> {
  final GarageProService _service = GarageProService();
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _unconfirmedAlerts = [];
  List _flaggedReviews = [];
  List _newGarages = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final stats = await _service.getDashboardStats();
    final alerts = await _service.getUnconfirmedAlerts();
    final flagged = await _service.getFlaggedReviews();
    final newGarages = await _service.getNewUnverifiedGarages();
    if (mounted) {
      setState(() {
        _stats = stats;
        _unconfirmedAlerts = alerts;
        _flaggedReviews = flagged;
        _newGarages = newGarages;
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> get _global =>
      _stats['global'] as Map<String, dynamic>? ?? {};

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildKpiCards(),
          const SizedBox(height: 24),
          _buildChartsRow(),
          const SizedBox(height: 24),
          _buildAlertsSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Garages PRO', style: AppTheme.headingLarge),
            const SizedBox(height: 4),
            Text(
              'Vue d\'ensemble du module Garages PRO',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _loadData,
          icon: const Icon(Icons.refresh),
          label: const Text('Actualiser'),
        ),
      ],
    );
  }

  Widget _buildKpiCards() {
    return GridView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 170,
      ),
      children: [
        StatCard(
          title: 'Garages actifs',
          value: '${_global['nb_garages_actifs'] ?? 0}',
          icon: Icons.store,
          iconColor: AppTheme.primaryColor,
          onTap: () {},
        ),
        StatCard(
          title: 'Garages vérifiés',
          value: '${_global['nb_garages_verifies'] ?? 0}',
          icon: Icons.verified,
          iconColor: AppTheme.successColor,
          onTap: () {},
        ),
        StatCard(
          title: 'RDV aujourd\'hui',
          value: '${_global['nb_rdv_aujourdhui'] ?? 0}',
          icon: Icons.today,
          iconColor: AppTheme.accentColor,
          onTap: () {},
        ),
        StatCard(
          title: 'RDV en attente',
          value: '${_global['nb_rdv_en_attente'] ?? 0}',
          icon: Icons.schedule,
          iconColor: AppTheme.warningColor,
          onTap: () {},
        ),
        StatCard(
          title: 'Note moyenne',
          value: '${(_global['note_moyenne_globale'] ?? 0).toStringAsFixed(1)}',
          icon: Icons.star,
          iconColor: Colors.amber,
          onTap: () {},
        ),
        StatCard(
          title: 'Total RDV',
          value: '${_global['nb_total_rdv'] ?? 0}',
          icon: Icons.calendar_month,
          iconColor: AppTheme.secondaryColor,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildChartsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildRdvParMoisChart()),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: _buildStatusPieChart()),
      ],
    );
  }

  Widget _buildRdvParMoisChart() {
    final monthly = _stats['monthly'] as List<dynamic>? ?? [];
    final spots = <BarChartGroupData>[];
    for (int i = 0; i < monthly.length && i < 12; i++) {
      final m = monthly[i] as Map<String, dynamic>;
      spots.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: (m['nb_rdv'] ?? 0).toDouble(),
              color: AppTheme.primaryColor,
              width: 16,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('RDV par mois', style: AppTheme.headingSmall),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child:
                  spots.isEmpty
                      ? const Center(child: Text('Aucune donnée'))
                      : BarChart(
                        BarChartData(
                          barGroups: spots,
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPieChart() {
    final dist = _stats['status_distribution'] as Map<String, int>? ?? {};
    final sections = <PieChartSectionData>[];
    final colors = {
      'en_attente': AppTheme.warningColor,
      'confirme': AppTheme.successColor,
      'annule': AppTheme.dangerColor,
      'termine': AppTheme.accentColor,
      'no_show': AppTheme.greyColor,
    };
    final labels = {
      'en_attente': 'En attente',
      'confirme': 'Confirmé',
      'annule': 'Annulé',
      'termine': 'Terminé',
      'no_show': 'No show',
    };

    dist.forEach((key, value) {
      sections.add(
        PieChartSectionData(
          value: value.toDouble(),
          color: colors[key] ?? AppTheme.greyColor,
          title: '${labels[key] ?? key}\n$value',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    });

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Répartition par statut', style: AppTheme.headingSmall),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child:
                  sections.isEmpty
                      ? const Center(child: Text('Aucune donnée'))
                      : PieChart(
                        PieChartData(sections: sections, centerSpaceRadius: 30),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Alertes en temps réel', style: AppTheme.headingSmall),
            const SizedBox(height: 16),
            if (_unconfirmedAlerts.isNotEmpty) ...[
              _alertRow(
                Icons.warning_amber_rounded,
                AppTheme.dangerColor,
                '${_unconfirmedAlerts.length} RDV non confirmés depuis >24h',
              ),
              const SizedBox(height: 8),
            ],
            if (_flaggedReviews.isNotEmpty) ...[
              _alertRow(
                Icons.flag_rounded,
                AppTheme.warningColor,
                '${_flaggedReviews.length} avis nécessitant une modération',
              ),
              const SizedBox(height: 8),
            ],
            if (_newGarages.isNotEmpty) ...[
              _alertRow(
                Icons.store_rounded,
                AppTheme.successColor,
                '${_newGarages.length} nouveaux garages (non vérifiés)',
              ),
            ],
            if (_unconfirmedAlerts.isEmpty &&
                _flaggedReviews.isEmpty &&
                _newGarages.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Aucune alerte en cours',
                    style: TextStyle(color: AppTheme.greyColor),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _alertRow(IconData icon, Color color, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: AppTheme.bodyMedium)),
        ],
      ),
    );
  }
}
