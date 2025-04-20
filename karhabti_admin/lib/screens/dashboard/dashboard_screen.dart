import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/chart_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 24),
            _buildStatCards(),
            const SizedBox(height: 24),
            _buildCharts(),
            const SizedBox(height: 24),
            _buildRecentActivities(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tableau de bord', style: AppTheme.headingLarge),
            const SizedBox(height: 8),
            Text(
              'Bienvenue dans le panneau d\'administration KARHABTI',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.greyColor),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Ajouter une pièce'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCards() {
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
          title: 'Total des véhicules',
          value: '157',
          icon: Icons.directions_car,
          iconColor: AppTheme.primaryColor,
          subtitle: '+12% ce mois-ci',
          onTap: () {},
        ),
        StatCard(
          title: 'Clients actifs',
          value: '423',
          icon: Icons.people,
          iconColor: AppTheme.secondaryColor,
          subtitle: '+8% ce mois-ci',
          onTap: () {},
        ),
        StatCard(
          title: 'Nouvelles demandes',
          value: '28',
          icon: Icons.mail,
          iconColor: AppTheme.accentColor,
          subtitle: '+5 aujourd\'hui',
          onTap: () {},
        ),
        StatCard(
          title: 'Pièces en stock',
          value: '892',
          icon: Icons.settings,
          iconColor: AppTheme.successColor,
          subtitle: '48 à réapprovisionner',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildCharts() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: ChartCard(
            title: 'Analyse des pannes véhicules',
            showActions: true,
            chart: LineChartWidget(
              data: [
                CustomLineChartData(
                  color: AppTheme.primaryColor,
                  spots: [
                    const FlSpot(0, 3),
                    const FlSpot(1, 1.5),
                    const FlSpot(2, 4),
                    const FlSpot(3, 3),
                    const FlSpot(4, 4.5),
                    const FlSpot(5, 4),
                    const FlSpot(6, 5.5),
                  ],
                ),
                CustomLineChartData(
                  color: AppTheme.accentColor,
                  spots: [
                    const FlSpot(0, 1),
                    const FlSpot(1, 2.5),
                    const FlSpot(2, 2),
                    const FlSpot(3, 4),
                    const FlSpot(4, 3.5),
                    const FlSpot(5, 5),
                    const FlSpot(6, 4.5),
                  ],
                ),
              ],
            ),
            legendItems: [
              ChartLegendItem(
                label: 'Prédictions',
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
        Expanded(
          flex: 2,
          child: Column(
            children: [
              ChartCard(
                title: 'Types de véhicules',
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
                      value: 40,
                      title: '40%',
                      color: AppTheme.secondaryColor,
                      radius: 50,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      value: 25,
                      title: '25%',
                      color: AppTheme.accentColor,
                      radius: 50,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                legendItems: [
                  ChartLegendItem(
                    label: 'Particuliers',
                    color: AppTheme.primaryColor,
                  ),
                  ChartLegendItem(
                    label: 'Professionnels',
                    color: AppTheme.secondaryColor,
                  ),
                  ChartLegendItem(
                    label: 'Entreprises',
                    color: AppTheme.accentColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Activités récentes', style: AppTheme.headingSmall),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Rafraîchir'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getRandomColor(index).withOpacity(0.2),
                  child: Icon(
                    _getRandomIcon(index),
                    color: _getRandomColor(index),
                  ),
                ),
                title: Text(
                  _getActivityTitle(index),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  _getActivityTime(index),
                  style: AppStyle.caption,
                ),
                trailing: _getActivityStatus(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getRandomColor(int index) {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
      AppTheme.successColor,
      Colors.purple,
    ];
    return colors[index % colors.length];
  }

  IconData _getRandomIcon(int index) {
    final icons = [
      Icons.directions_car,
      Icons.settings,
      Icons.person,
      Icons.star,
      Icons.message,
    ];
    return icons[index % icons.length];
  }

  String _getActivityTitle(int index) {
    final activities = [
      'Nouveau client enregistré',
      'Vidange ajoutée à l\'inventaire',
      'Maintenance programmée',
      'Message client reçu',
      'Nouvelle prédiction de panne',
    ];
    return activities[index % activities.length];
  }

  String _getActivityTime(int index) {
    final times = [
      'Il y a 5 minutes',
      'Il y a 20 minutes',
      'Il y a 1 heure',
      'Il y a 3 heures',
      'Aujourd\'hui, 10:30',
    ];
    return times[index % times.length];
  }

  Widget _getActivityStatus(int index) {
    final statuses = [
      'Nouveau',
      'Terminé',
      'En attente',
      'Nouveau',
      'En cours',
    ];
    final colors = [
      AppTheme.primaryColor,
      AppTheme.successColor,
      AppTheme.accentColor,
      AppTheme.primaryColor,
      AppTheme.greyColor,
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colors[index % colors.length].withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statuses[index % statuses.length],
        style: TextStyle(
          color: colors[index % colors.length],
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class AppStyle {
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppTheme.greyColor,
  );
}
