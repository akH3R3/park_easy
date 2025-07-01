
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartWidget extends StatelessWidget {
  final List<FlSpot> data;
  final String title;

  const LineChartWidget({
    Key? key,
    required this.data,
    required this.title,
  }) : super(key: key);

  String _bottomTitle(double value) {
    if (title == "Daily Parking") {
      if (value % 2 == 0) return value.toInt().toString();
      return '';
    } else if (title == "Weekly Parking") {
      const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
      int index = value.toInt() - 1;
      if (index >= 0 && index < days.length) return days[index];
      return '';
    } else if (title == "Monthly Parking") {
      if (value % 5 == 0) return value.toInt().toString();
      return '';
    } else if (title == "Yearly Parking") {
      if (value % 2 == 0) return value.toInt().toString();
      return '';
    }
    return value.toInt().toString();
  }

  String _leftTitle(double value) {
    if (value % 1 == 0) {
      if (title == "Yearly Parking" && value >= 1000) {
        return '${(value / 1000).toStringAsFixed(1)}K';
      }
      return value.toInt().toString();
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    double bottomInterval = 1;
    if (title == "Monthly Parking") {
      bottomInterval = 5;
    } else if (title == "Yearly Parking") {
      bottomInterval = 2;
    }

    double maxY = data.isNotEmpty
        ? data.map((e) => e.y).reduce((a, b) => a > b ? a : b)
        : 0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LineChart(
                LineChartData(
                  minX: data.isNotEmpty ? data.first.x : 0,
                  maxX: data.isNotEmpty ? data.last.x : 0,
                  minY: 0,
                  maxY: maxY * 1.2,
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: maxY / 5,
                    verticalInterval: bottomInterval,
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      left: BorderSide(),
                      bottom: BorderSide(),
                      top: BorderSide(color: Colors.transparent),
                      right: BorderSide(color: Colors.transparent),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: bottomInterval,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) => SideTitleWidget(
                          meta: meta,
                          child: Text(
                            _bottomTitle(value),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: maxY / 2,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => SideTitleWidget(
                          meta: meta,
                          child: Text(
                            _leftTitle(value),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
