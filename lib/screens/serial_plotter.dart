import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:serialbench/core/serial_service.dart';

class SerialPlotter extends StatefulWidget {
  const SerialPlotter({super.key});

  @override
  State<SerialPlotter> createState() => _SerialPlotterState();
}

class _SerialPlotterState extends State<SerialPlotter> {
  static const double pixelsPerPoint = 5.0;

  final Queue<FlSpot> points = Queue<FlSpot>();
  StreamSubscription<String>? lineSub;

  int xCounter = 0;
  int maxPoints = 200;
  double minY = 0;
  double maxY = 100;
  double? lastValue;
  bool prefilled = false;

  @override
  void initState() {
    super.initState();
    lineSub = SerialService.instance.lines.listen(_onLine);
  }

  @override
  void dispose() {
    lineSub?.cancel();
    super.dispose();
  }

  void prefill(int maxPoints) {
    if (prefilled) return;
    points.clear();
    for (int i = 0; i < maxPoints; i++) {
      points.addLast(FlSpot.nullSpot);
    }
    xCounter = maxPoints;
    prefilled = true;
  }

  void _onLine(String line) {
    final value = double.tryParse(line.trim());
    if (value == null || value == lastValue) return; // skip dupes/junk
    lastValue = value;

    setState(() {
      points.addLast(FlSpot((xCounter++).toDouble(), value));
      if (points.length > maxPoints) points.removeFirst();

      final ys = points.map((p) => p.y);
      minY = ys.reduce((a, b) => a < b ? a : b);
      maxY = ys.reduce((a, b) => a > b ? a : b);
    });
  }

  double tickInterval(double span, {int targetTicks = 4}) {
    final step = span / targetTicks;
    return step < 1 ? 1.0 : step;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          maxPoints = (constraints.maxWidth / pixelsPerPoint).round().clamp(10, 5000);
          prefill(maxPoints);

          if (points.isEmpty) {
            return const Center(
              child: Text('No data 📈', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            );
          }

          // Pad the range so the trace sits centered, not glued to an edge.
          final span = (maxY - minY).abs();
          final padding = span == 0 ? 10.0 : span * 0.15;
          final plotMinY = minY - padding;
          final plotMaxY = maxY + padding;
          final plotSpan = plotMaxY - plotMinY;

          return LineChart(
            duration: Duration.zero,
            LineChartData(
              minY: plotMinY,
              maxY: plotMaxY,
              minX: (xCounter - maxPoints).clamp(0, xCounter).toDouble(),
              maxX: xCounter.toDouble(),
              lineBarsData: [
                LineChartBarData(
                  spots: points.toList(growable: false),
                  isCurved: true,
                  curveSmoothness: 0.25,
                  preventCurveOverShooting: true,
                  color: Colors.teal,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                ),
              ],
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(show: true),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  // axisNameWidget: const Text('Samples'),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 12,
                    interval: tickInterval(maxPoints.toDouble()),
                    getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 10)),
                  ),
                ),
                leftTitles: AxisTitles(
                  // axisNameWidget: const Text('Value'),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: tickInterval(plotSpan, targetTicks: plotSpan > 200 ? 8 : (plotSpan > 50 ? 6 : 4)),
                    getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 10)),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
