/// Dynamic Nutrient Timeline
/// Shows deficiency improvement over weeks with daily risk scores
library;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/health_database.dart';
import '../models/health_data.dart';
import 'package:intl/intl.dart';

class TimelineProgressPage extends StatefulWidget {
  const TimelineProgressPage({super.key});

  @override
  State<TimelineProgressPage> createState() => _TimelineProgressPageState();
}

class _TimelineProgressPageState extends State<TimelineProgressPage> {
  final _db = HealthDatabase.instance;
  List<DeficiencyRecord> _allRecords = [];
  String _selectedNutrient = 'Iron';
  
  final nutrients = ['Iron', 'Vitamin B12', 'Vitamin D', 'Calcium', 'Vitamin A'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final records = await _db.getRecentDeficiencies(days: 90);
    setState(() {
      _allRecords = records;
    });
  }

  List<FlSpot> _getTimelineData() {
    final filteredRecords = _allRecords
        .where((r) => r.nutrient.contains(_selectedNutrient))
        .toList();

    if (filteredRecords.isEmpty) return [];

    // Sort by date
    filteredRecords.sort((a, b) => a.detectedAt.compareTo(b.detectedAt));

    // Calculate days from start
    final startDate = filteredRecords.first.detectedAt;
    final spots = <FlSpot>[];

    for (var i = 0; i < filteredRecords.length; i++) {
      final record = filteredRecords[i];
      final daysDiff = record.detectedAt.difference(startDate).inDays.toDouble();
      final riskScore = _calculateRiskScore(record.severity);
      spots.add(FlSpot(daysDiff, riskScore));
    }

    return spots;
  }

  double _calculateRiskScore(DeficiencySeverity severity) {
    switch (severity) {
      case DeficiencySeverity.normal:
        return 10.0;
      case DeficiencySeverity.mild:
        return 30.0;
      case DeficiencySeverity.moderate:
        return 60.0;
      case DeficiencySeverity.severe:
        return 90.0;
    }
  }

  Color _getRiskColor(double score) {
    if (score < 40) return Colors.green;
    if (score < 70) return Colors.orange;
    return Colors.red;
  }

  double _getCurrentRiskScore() {
    final recentRecords = _allRecords
        .where((r) => r.nutrient.contains(_selectedNutrient))
        .toList();
    
    if (recentRecords.isEmpty) return 0;
    
    recentRecords.sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
    return _calculateRiskScore(recentRecords.first.severity);
  }

  String _getTrendAnalysis() {
    final spots = _getTimelineData();
    if (spots.length < 2) return 'Not enough data to analyze trend';

    final firstScore = spots.first.y;
    final lastScore = spots.last.y;
    final improvement = firstScore - lastScore;

    if (improvement > 20) {
      return '🎉 Excellent! Your $_selectedNutrient levels are improving significantly';
    } else if (improvement > 0) {
      return '✅ Good progress! Keep up the healthy eating';
    } else if (improvement < -20) {
      return '⚠️ Alert: $_selectedNutrient deficiency is worsening. Consult a doctor';
    } else {
      return '➡️ Stable: No major changes detected';
    }
  }

  @override
  Widget build(BuildContext context) {
    final spots = _getTimelineData();
    final currentRisk = _getCurrentRiskScore();
    final riskColor = _getRiskColor(currentRisk);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrient Timeline'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Current Risk Score Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [riskColor.withValues(alpha: 0.3), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Current Deficiency Risk',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${currentRisk.toInt()}',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: riskColor,
                    ),
                  ),
                  Text(
                    currentRisk < 40 ? 'Low Risk' : currentRisk < 70 ? 'Moderate' : 'High Risk',
                    style: TextStyle(
                      fontSize: 20,
                      color: riskColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Nutrient selector
          const Text(
            'Select Nutrient:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: nutrients.map((nutrient) {
              final isSelected = nutrient == _selectedNutrient;
              return ChoiceChip(
                label: Text(nutrient),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedNutrient = nutrient;
                    });
                  }
                },
                selectedColor: Colors.teal,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Timeline Chart
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Risk Score Timeline',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  if (spots.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'No data available for this nutrient',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 20,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.withValues(alpha: 0.2),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 20,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 7,
                                getTitlesWidget: (value, meta) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      'D${value.toInt()}',
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minY: 0,
                          maxY: 100,
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: Colors.teal,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: _getRiskColor(spot.y),
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.teal.withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Trend Analysis
          Card(
            elevation: 2,
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Trend Analysis',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getTrendAnalysis(),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Legend
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Risk Score Guide',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildLegendItem(Colors.green, '0-39', 'Low Risk - Healthy levels'),
                  _buildLegendItem(Colors.orange, '40-69', 'Moderate - Needs attention'),
                  _buildLegendItem(Colors.red, '70-100', 'High Risk - Consult doctor'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String range, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: '$range: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
