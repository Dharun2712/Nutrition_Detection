/// Progress Dashboard - Track deficiency recovery over time
library;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/health_data.dart';
import '../services/health_database.dart';

class ProgressDashboardPage extends StatefulWidget {
  const ProgressDashboardPage({super.key});

  @override
  State<ProgressDashboardPage> createState() => _ProgressDashboardPageState();
}

class _ProgressDashboardPageState extends State<ProgressDashboardPage> {
  List<ProgressDataPoint> _progressData = [];
  List<DeficiencyRecord> _recentDeficiencies = [];
  List<MealRecord> _recentMeals = [];
  bool _isLoading = true;
  int _selectedDays = 30;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final progressData = await HealthDatabase.instance.getProgressHistory(
        days: _selectedDays,
      );
      final deficiencies = await HealthDatabase.instance.getRecentDeficiencies(
        days: _selectedDays,
      );
      final meals = await HealthDatabase.instance.getRecentMeals(
        days: 7,
      );

      setState(() {
        _progressData = progressData;
        _recentDeficiencies = deficiencies;
        _recentMeals = meals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Dashboard'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.date_range),
            onSelected: (days) {
              setState(() {
                _selectedDays = days;
              });
              _loadData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 7, child: Text('Last 7 days')),
              const PopupMenuItem(value: 30, child: Text('Last 30 days')),
              const PopupMenuItem(value: 90, child: Text('Last 90 days')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Summary Cards
                    _buildSummaryCards(),
                    const SizedBox(height: 24),

                    // Recovery Score Chart
                    if (_progressData.isNotEmpty) ...[
                      _buildRecoveryScoreChart(),
                      const SizedBox(height: 24),
                    ],

                    // Deficiency Trends
                    if (_recentDeficiencies.isNotEmpty) ...[
                      _buildDeficiencyTrends(),
                      const SizedBox(height: 24),
                    ],

                    // Recent Meals
                    if (_recentMeals.isNotEmpty) ...[
                      _buildRecentMeals(),
                      const SizedBox(height: 24),
                    ],

                    // No Data Message
                    if (_progressData.isEmpty &&
                        _recentDeficiencies.isEmpty &&
                        _recentMeals.isEmpty)
                      _buildNoDataMessage(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCards() {
    final avgRecoveryScore = _progressData.isNotEmpty
        ? _progressData.map((p) => p.averageRecoveryScore).reduce((a, b) => a + b) /
            _progressData.length
        : 0.0;

    final activeDeficiencies = _recentDeficiencies
        .where((d) => d.detectedAt.isAfter(
            DateTime.now().subtract(const Duration(days: 7))))
        .map((d) => d.nutrient)
        .toSet()
        .length;

    final mealsThisWeek = _recentMeals.length;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Avg Recovery',
            '${avgRecoveryScore.toStringAsFixed(0)}%',
            Icons.trending_up,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Deficiencies',
            '$activeDeficiencies',
            Icons.warning,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Meals Logged',
            '$mealsThisWeek',
            Icons.restaurant,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.7), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryScoreChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, color: Colors.teal[700]),
              const SizedBox(width: 8),
              const Text(
                'Recovery Score Trend',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey[300]!,
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 &&
                            value.toInt() < _progressData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _progressData[value.toInt()].formattedDate,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: _progressData
                        .asMap()
                        .entries
                        .map((e) => FlSpot(
                              e.key.toDouble(),
                              e.value.averageRecoveryScore,
                            ))
                        .toList(),
                    isCurved: true,
                    color: Colors.teal,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.teal.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeficiencyTrends() {
    // Group deficiencies by nutrient
    final Map<String, List<DeficiencyRecord>> deficienciesByNutrient = {};
    for (final def in _recentDeficiencies) {
      deficienciesByNutrient.putIfAbsent(def.nutrient, () => []).add(def);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.orange[700]),
              const SizedBox(width: 8),
              const Text(
                'Deficiency History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...deficienciesByNutrient.entries.map((entry) {
            final latest = entry.value.first;
            final severityColor = _getSeverityColor(latest.severity);
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: severityColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: severityColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: severityColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${latest.severity.displayName} - ${latest.bodyPart}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('MMM dd').format(latest.detectedAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${entry.value.length} record${entry.value.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentMeals() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.restaurant_menu, color: Colors.blue[700]),
              const SizedBox(width: 8),
              const Text(
                'Recent Meals',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._recentMeals.map((meal) {
            final scoreColor = _getScoreColor(meal.recoveryScore);
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: scoreColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${meal.recoveryScore}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.foods.map((f) => f.name).join(', '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMM dd, HH:mm').format(meal.consumedAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNoDataMessage() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.insights,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Data Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start analyzing your meals and body parts to see progress',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(DeficiencySeverity severity) {
    switch (severity) {
      case DeficiencySeverity.severe:
        return Colors.red;
      case DeficiencySeverity.moderate:
        return Colors.orange;
      case DeficiencySeverity.mild:
        return Colors.amber;
      case DeficiencySeverity.normal:
        return Colors.green;
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}
