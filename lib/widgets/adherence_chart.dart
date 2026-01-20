import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:myapp/models/medicine_log.dart';
import 'package:intl/intl.dart';

class AdherenceChart extends StatelessWidget {
  final List<MedicineLog> logs;

  const AdherenceChart({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    final dataPoints = _calculateLast7DaysData();
    final theme = Theme.of(context);

    return Container(
      height: 200,
      padding: const EdgeInsets.only(right: 16, top: 16),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value < 0 || value >= dataPoints.length)
                    return const SizedBox();
                  return Text(
                    dataPoints[value.toInt()].label,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                },
                reservedSize: 22,
              ),
            ),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: dataPoints
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.value))
                  .toList(),
              isCurved: true,
              color: theme.colorScheme.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: theme.colorScheme.primary.withAlpha((0.1 * 255).toInt()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_ChartData> _calculateLast7DaysData() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final count =
          logs.where((log) => DateUtils.isSameDay(log.timestamp, date)).length;
      // Mock percentage for chart display (count normalized to 0-10)
      return _ChartData(
        DateFormat('E').format(date),
        count.toDouble().clamp(0, 10),
      );
    }).toList();
  }
}

class _ChartData {
  final String label;
  final double value;
  _ChartData(this.label, this.value);
}
