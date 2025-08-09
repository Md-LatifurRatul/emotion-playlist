import 'package:emo_music_app/controller/mood_history_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MoodHistoryChartScreen extends StatelessWidget {
  const MoodHistoryChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final moodCounts = context.watch<MoodHistoryProvider>().moodCounts;

    final moods = moodCounts.keys.toList();
    final counts = moodCounts.values.toList();

    if (moods.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mood History')),
        body: const Center(child: Text('No mood data yet.')),
      );
    }

    final maxCount = counts.isNotEmpty
        ? counts.reduce((a, b) => a > b ? a : b)
        : 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Mood History')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            maxY: (maxCount + 1).toDouble(),
            barGroups: List.generate(moods.length, (index) {
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: counts[index].toDouble(),
                    color: Theme.of(context).colorScheme.primary,
                    width: 22,
                    borderRadius: BorderRadius.circular(6),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: (maxCount + 1).toDouble(),
                      color: Colors.grey.shade300,
                    ),
                  ),
                ],
              );
            }),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true, interval: 1),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= moods.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        moods[index],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                  reservedSize: 42,
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipPadding: const EdgeInsets.all(8),
                tooltipMargin: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${moods[group.x.toInt()]}\n',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    children: [
                      TextSpan(
                        text: rod.toY.toInt().toString(),
                        style: const TextStyle(
                          color: Colors.yellowAccent,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        ),
      ),
    );
  }
}
