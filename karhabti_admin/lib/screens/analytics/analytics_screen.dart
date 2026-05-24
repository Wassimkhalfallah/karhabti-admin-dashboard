import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import '../../widgets/chart_card.dart';
import '../../widgets/stat_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'Ce mois';
  final List<String> _periods = [
    'Aujourd\'hui',
    'Cette semaine',
    'Ce mois',
    'Cette année',
    'Tout',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildPeriodSelector(),
            const SizedBox(height: 24),
            _buildMainStats(),
            const SizedBox(height: 24),
            _buildDataAnalyticsSection(),
            const SizedBox(height: 24),
            _buildVehicleStatsSection(),
            const SizedBox(height: 24),
            _buildMaintenanceSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Analytique & Statistiques', style: AppTheme.headingLarge),
        const SizedBox(height: 8),
        Text(
          'Visualisez les performances et statistiques du système CARHABTI pour une meilleure prise de décision.',
          style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
        ),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.lightGreyColor),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPeriod,
              items:
                  _periods
                      .map(
                        (period) => DropdownMenuItem(
                          value: period,
                          child: Text(period),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPeriod = value!;
                });
              },
            ),
          ),
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh),
              label: const Text('Actualiser'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download),
              label: const Text('Exporter'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainStats() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Pannes détectées',
            value: '128',
            icon: Icons.warning_amber,
            iconColor: AppTheme.dangerColor,
            subtitle: '+12% vs dernier mois',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Précision des prédictions',
            value: '87%',
            icon: Icons.insights,
            iconColor: AppTheme.successColor,
            subtitle: '+5% vs dernier mois',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Coût moyen maintenance',
            value: '245 DT',
            icon: Icons.monetization_on,
            iconColor: AppTheme.accentColor,
            subtitle: '-8% vs dernier mois',
            onTap: () {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Nouveaux utilisateurs',
            value: '32',
            icon: Icons.group_add,
            iconColor: AppTheme.primaryColor,
            subtitle: '+15% vs dernier mois',
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildDataAnalyticsSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Graphique des pannes prédites vs réelles
        Expanded(
          flex: 3,
          child: ChartCard(
            title: 'Pannes prédites vs réelles',
            showActions: true,
            chart: LineChartWidget(
              data: [
                CustomLineChartData(
                  color: AppTheme.primaryColor,
                  spots: [
                    const FlSpot(1, 4),
                    const FlSpot(2, 3.5),
                    const FlSpot(3, 4.5),
                    const FlSpot(4, 5),
                    const FlSpot(5, 3.8),
                    const FlSpot(6, 4.2),
                    const FlSpot(7, 5.5),
                    const FlSpot(8, 6.2),
                    const FlSpot(9, 5.8),
                    const FlSpot(10, 6.5),
                    const FlSpot(11, 7.1),
                    const FlSpot(12, 6.7),
                  ],
                ),
                CustomLineChartData(
                  color: AppTheme.accentColor,
                  spots: [
                    const FlSpot(1, 3),
                    const FlSpot(2, 2.5),
                    const FlSpot(3, 3.5),
                    const FlSpot(4, 3.2),
                    const FlSpot(5, 3.8),
                    const FlSpot(6, 3.5),
                    const FlSpot(7, 4.5),
                    const FlSpot(8, 5.2),
                    const FlSpot(9, 4.8),
                    const FlSpot(10, 5.5),
                    const FlSpot(11, 6.1),
                    const FlSpot(12, 5.7),
                  ],
                ),
              ],
            ),
            legendItems: [
              ChartLegendItem(
                label: 'Pannes prédites',
                color: AppTheme.primaryColor,
              ),
              ChartLegendItem(
                label: 'Pannes réelles',
                color: AppTheme.accentColor,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Répartition par type de panne
        Expanded(
          flex: 2,
          child: ChartCard(
            title: 'Types de pannes',
            chart: PieChartWidget(
              sections: [
                PieChartSectionData(
                  value: 35,
                  title: '35%',
                  color: AppTheme.primaryColor,
                  radius: 50,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PieChartSectionData(
                  value: 25,
                  title: '25%',
                  color: AppTheme.secondaryColor,
                  radius: 50,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PieChartSectionData(
                  value: 15,
                  title: '15%',
                  color: AppTheme.accentColor,
                  radius: 50,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PieChartSectionData(
                  value: 10,
                  title: '10%',
                  color: AppTheme.dangerColor,
                  radius: 50,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PieChartSectionData(
                  value: 15,
                  title: '15%',
                  color: AppTheme.greyColor,
                  radius: 50,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            legendItems: [
              ChartLegendItem(label: 'Pneus', color: AppTheme.primaryColor),
              ChartLegendItem(label: 'Freins', color: AppTheme.secondaryColor),
              ChartLegendItem(label: 'Vidange', color: AppTheme.accentColor),
              ChartLegendItem(label: 'Batterie', color: AppTheme.dangerColor),
              ChartLegendItem(label: 'Autres', color: AppTheme.greyColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleStatsSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Répartition des marques de véhicules
        Expanded(
          flex: 2,
          child: ChartCard(
            title: 'Marques de véhicules',
            chart: BarChartWidget(
              data: [
                CustomBarGroup(
                  x: 0,
                  bars: [BarData(y: 25, color: AppTheme.primaryColor)],
                ),
                CustomBarGroup(
                  x: 1,
                  bars: [BarData(y: 20, color: AppTheme.primaryColor)],
                ),
                CustomBarGroup(
                  x: 2,
                  bars: [BarData(y: 18, color: AppTheme.primaryColor)],
                ),
                CustomBarGroup(
                  x: 3,
                  bars: [BarData(y: 15, color: AppTheme.primaryColor)],
                ),
                CustomBarGroup(
                  x: 4,
                  bars: [BarData(y: 12, color: AppTheme.primaryColor)],
                ),
                CustomBarGroup(
                  x: 5,
                  bars: [BarData(y: 10, color: AppTheme.primaryColor)],
                ),
              ],
              maxY: 30,
            ),
            legendItems: const [],
          ),
        ),
        const SizedBox(width: 16),
        // Répartition par type de carburant
        Expanded(
          flex: 2,
          child: ChartCard(
            title: 'Types de carburant',
            chart: PieChartWidget(
              sections: [
                PieChartSectionData(
                  value: 55,
                  title: '55%',
                  color: AppTheme.primaryColor,
                  radius: 50,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PieChartSectionData(
                  value: 30,
                  title: '30%',
                  color: AppTheme.secondaryColor,
                  radius: 50,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PieChartSectionData(
                  value: 10,
                  title: '10%',
                  color: AppTheme.accentColor,
                  radius: 50,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PieChartSectionData(
                  value: 5,
                  title: '5%',
                  color: AppTheme.successColor,
                  radius: 50,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            legendItems: [
              ChartLegendItem(label: 'Diesel', color: AppTheme.primaryColor),
              ChartLegendItem(label: 'Essence', color: AppTheme.secondaryColor),
              ChartLegendItem(label: 'Hybride', color: AppTheme.accentColor),
              ChartLegendItem(
                label: 'Électrique',
                color: AppTheme.successColor,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Distribution des âges des véhicules
        Expanded(
          flex: 2,
          child: ChartCard(
            title: 'Âge des véhicules',
            chart: BarChartWidget(
              data: [
                CustomBarGroup(
                  x: 0,
                  bars: [BarData(y: 10, color: AppTheme.successColor)],
                ),
                CustomBarGroup(
                  x: 1,
                  bars: [BarData(y: 18, color: AppTheme.accentColor)],
                ),
                CustomBarGroup(
                  x: 2,
                  bars: [BarData(y: 25, color: AppTheme.primaryColor)],
                ),
                CustomBarGroup(
                  x: 3,
                  bars: [BarData(y: 15, color: AppTheme.secondaryColor)],
                ),
                CustomBarGroup(
                  x: 4,
                  bars: [BarData(y: 12, color: AppTheme.dangerColor)],
                ),
              ],
              maxY: 30,
            ),
            legendItems: [
              ChartLegendItem(label: '0-2 ans', color: AppTheme.successColor),
              ChartLegendItem(label: '3-5 ans', color: AppTheme.accentColor),
              ChartLegendItem(label: '6-10 ans', color: AppTheme.primaryColor),
              ChartLegendItem(
                label: '11-15 ans',
                color: AppTheme.secondaryColor,
              ),
              ChartLegendItem(label: '16+ ans', color: AppTheme.dangerColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMaintenanceSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Coûts de maintenance mensuels
        Expanded(
          flex: 3,
          child: ChartCard(
            title: 'Coûts de maintenance mensuels',
            showActions: true,
            chart: LineChartWidget(
              data: [
                CustomLineChartData(
                  color: AppTheme.primaryColor,
                  spots: [
                    const FlSpot(1, 240),
                    const FlSpot(2, 235),
                    const FlSpot(3, 255),
                    const FlSpot(4, 230),
                    const FlSpot(5, 245),
                    const FlSpot(6, 240),
                    const FlSpot(7, 250),
                    const FlSpot(8, 245),
                    const FlSpot(9, 260),
                    const FlSpot(10, 270),
                    const FlSpot(11, 265),
                    const FlSpot(12, 250),
                  ],
                ),
              ],
            ),
            legendItems: [
              ChartLegendItem(
                label: 'Coût moyen (DT)',
                color: AppTheme.primaryColor,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Tableau des statistiques de maintenance
        Expanded(
          flex: 2,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Statistiques de maintenance',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.more_vert),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Table(
                    border: TableBorder.all(
                      color: AppTheme.lightGreyColor,
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1.5),
                    },
                    children: [
                      const TableRow(
                        decoration: BoxDecoration(
                          color: AppTheme.lightGreyColor,
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Type de pièce',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Prédictions',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Coût moyen',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      _buildTableRow('Pneus', '35', '350 DT'),
                      _buildTableRow('Freins', '28', '180 DT'),
                      _buildTableRow('Vidange', '42', '120 DT'),
                      _buildTableRow('Batterie', '18', '220 DT'),
                      _buildTableRow('Amortisseurs', '15', '380 DT'),
                      _buildTableRow('Courroie', '10', '320 DT'),
                      _buildTableRow('Embrayage', '8', '450 DT'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Voir le rapport complet'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  TableRow _buildTableRow(String type, String predictions, String cost) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: Text(type)),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(predictions)),
        Padding(padding: const EdgeInsets.all(8.0), child: Text(cost)),
      ],
    );
  }
}
