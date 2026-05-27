import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final Widget chart;
  final List<ChartLegendItem>? legendItems;
  final bool showActions;
  final VoidCallback? onMorePressed;

  const ChartCard({
    super.key,
    required this.title,
    required this.chart,
    this.legendItems,
    this.showActions = false,
    this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      color: AppTheme.whiteColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppTheme.headingSmall),
                if (showActions)
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: AppTheme.greyColor),
                    onPressed: onMorePressed,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: chart,
            ),
            if (legendItems != null && legendItems!.isNotEmpty) ...[  
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: legendItems!.map((item) => _buildLegendItem(item)).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(ChartLegendItem item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: item.color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          item.label,
          style: AppTheme.caption.copyWith(color: AppTheme.darkColor),
        ),
      ],
    );
  }
}

class ChartLegendItem {
  final String label;
  final Color color;

  ChartLegendItem({
    required this.label,
    required this.color,
  });
}

// Widgets préconstruits pour les graphiques courants

// Graphique en lignes
class LineChartWidget extends StatelessWidget {
  final List<CustomLineChartData> data;
  final bool showGrid;
  final bool showBorder;
  final bool curved;

  const LineChartWidget({
    super.key,
    required this.data,
    this.showGrid = true,
    this.showBorder = false,
    this.curved = true,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: showGrid),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 30),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: showBorder),
        lineBarsData: data.map((lineData) => 
          LineChartBarData(
            spots: lineData.spots,
            isCurved: curved,
            color: lineData.color,
            barWidth: lineData.width,
            isStrokeCapRound: true,
            dotData: FlDotData(show: lineData.showDots),
            belowBarData: BarAreaData(
              show: lineData.showArea,
              // ignore: deprecated_member_use
              color: lineData.color.withOpacity(0.15),
            ),
          )
        ).toList(),
      ),
    );
  }
}

class CustomLineChartData {
  final List<FlSpot> spots;
  final Color color;
  final double width;
  final bool showDots;
  final bool showArea;

  CustomLineChartData({
    required this.spots,
    required this.color,
    this.width = 3.0,
    this.showDots = true,
    this.showArea = true,
  });
}

// Graphique en barres
class BarChartWidget extends StatelessWidget {
  final List<CustomBarGroup> data;
  final bool showGrid;
  final double maxY;

  const BarChartWidget({
    super.key,
    required this.data,
    this.showGrid = true,
    required this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(enabled: true),
        gridData: FlGridData(show: showGrid),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.map((group) => BarChartGroupData(
          x: group.x,
          barRods: group.bars.map((bar) => BarChartRodData(
            toY: bar.y,
            color: bar.color,
            width: bar.width,
            borderRadius: BorderRadius.circular(4),
          )).toList(),
        )).toList(),
      ),
    );
  }
}

class CustomBarGroup {
  final int x;
  final List<BarData> bars;

  CustomBarGroup({
    required this.x,
    required this.bars,
  });
}

class BarData {
  final double y;
  final Color color;
  final double width;

  BarData({
    required this.y,
    required this.color,
    this.width = 15,
  });
}

// Graphique en camembert
class PieChartWidget extends StatelessWidget {
  final List<PieChartSectionData> sections;
  final double radius;

  const PieChartWidget({
    super.key,
    required this.sections,
    this.radius = 120,
  });

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: radius / 3,
        sectionsSpace: 2,
      ),
    );
  }
}
