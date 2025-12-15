/// Smart Nutrition Report Generator
/// Generates PDF reports with charts, weekly improvements, and doctor-share options
library;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/health_data.dart';
import '../services/health_database.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
// qr_flutter and typed_data not needed in this file

class NutritionReportPage extends StatefulWidget {
  const NutritionReportPage({super.key});

  @override
  State<NutritionReportPage> createState() => _NutritionReportPageState();
}

class _NutritionReportPageState extends State<NutritionReportPage> {
  List<DeficiencyRecord> _deficiencies = [];
  List<MealRecord> _meals = [];
  List<ProgressDataPoint> _progressData = [];
  bool _isLoading = true;

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
      final db = HealthDatabase.instance;
      final deficiencies = await db.getRecentDeficiencies(days: 30);
      final meals = await db.getRecentMeals(days: 30);
      final progress = await db.getProgressHistory(days: 30);

      setState(() {
        _deficiencies = deficiencies;
        _meals = meals;
        _progressData = progress;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _generateHealthSummary() {
    if (_deficiencies.isEmpty) {
      return 'Congratulations! No significant deficiencies detected in the past 30 days. '
          'Continue maintaining your healthy eating habits.';
    }

    final Map<String, List<DeficiencyRecord>> byNutrient = {};
    for (var def in _deficiencies) {
      byNutrient.putIfAbsent(def.nutrient, () => []).add(def);
    }

    final improvements = <String>[];
    final concerns = <String>[];

    byNutrient.forEach((nutrient, records) {
      if (records.length >= 2) {
        final first = records.last; // oldest
        final last = records.first; // newest
        final lastScore = _severityToScore(last.severity);
        final firstScore = _severityToScore(first.severity);
        if (lastScore < firstScore) {
          improvements.add('$nutrient deficiency improved from ${first.severity.toString().split('.').last} to ${last.severity.toString().split('.').last}');
        } else if (lastScore > firstScore) {
          concerns.add('$nutrient deficiency worsened from ${first.severity.toString().split('.').last} to ${last.severity.toString().split('.').last}');
        }
      }
    });

    String summary = '';
    if (improvements.isNotEmpty) {
      summary += '✅ Improvements:\n${improvements.join('\n')}\n\n';
    }
    if (concerns.isNotEmpty) {
      summary += '⚠️ Concerns:\n${concerns.join('\n')}\n\n';
    }
    
    summary += 'Total deficiencies detected: ${_deficiencies.length}\n';
    summary += 'Meals logged: ${_meals.length}\n';
    if (_meals.isNotEmpty) {
      final avgRecovery = _meals.map((m) => m.recoveryScore).reduce((a, b) => a + b) / _meals.length;
      summary += 'Average meal recovery score: ${avgRecovery.toStringAsFixed(1)}/100';
    }

    return summary;
  }

  int _severityToScore(DeficiencySeverity severity) {
    switch (severity) {
      case DeficiencySeverity.normal: return 0;
      case DeficiencySeverity.mild: return 1;
      case DeficiencySeverity.moderate: return 2;
      case DeficiencySeverity.severe: return 3;
    }
  }

  Future<void> _generatePDF() async {
    try {
      final pdf = pw.Document();
      final records = _deficiencies;
      final healthSummary = _generateHealthSummary();

      // Create PDF pages
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Nutrition Health Report',
                            style: pw.TextStyle(
                                fontSize: 24, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 4),
                        pw.Text('Generated: ${DateFormat.yMMMMd().format(DateTime.now())}',
                            style: const pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Health Summary
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.blue200, width: 2),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Health Summary',
                        style: pw.TextStyle(
                            fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 12),
                    pw.Text(healthSummary,
                        style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.5)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Deficiency Breakdown
              pw.Text('Deficiency Analysis',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 12),
              ..._buildDeficiencyPdfTable(records),

              pw.SizedBox(height: 20),

              // Recommendations
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green50,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Personalized Recommendations',
                        style: pw.TextStyle(
                            fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 8),
                    ..._buildRecommendationsList(records),
                  ],
                ),
              ),

              // Footer with QR code
              pw.SizedBox(height: 30),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                      'Share this report with your doctor for personalized guidance',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                ],
              ),
            ];
          },
        ),
      );

      // Show PDF preview
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ PDF Generated! You can now print or share it.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error generating PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<pw.Widget> _buildDeficiencyPdfTable(List<DeficiencyRecord> records) {
    if (records.isEmpty) {
      return [
        pw.Text('No deficiency records found.',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600))
      ];
    }

    // Build breakdown from provided records
    final Map<String, Map<String, dynamic>> breakdown = {};
    for (var r in records) {
      final key = r.nutrient;
      final sev = r.severity.displayName;
      breakdown.putIfAbsent(key, () => {'count': 0, 'severity': sev});
      breakdown[key]!['count'] = (breakdown[key]!['count'] as int) + 1;
    }

    return [
      pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey300),
        children: [
          // Header
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.blue100),
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text('Nutrient',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text('Occurrences',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text('Severity',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
            ],
          ),
          // Data rows
          ...breakdown.entries.map((entry) {
            final severity = entry.value['severity'] as String;
            final count = entry.value['count'] as int;
            return pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(entry.key),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text('$count'),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(severity),
                ),
              ],
            );
          }).toList(),
        ],
      ),
    ];
  }

  List<pw.Widget> _buildRecommendationsList(List<DeficiencyRecord> records) {
    final recommendations = <String>[];
    // Build breakdown for recommendations
    final Map<String, int> breakdown = {};
    for (var r in records) {
      breakdown[r.nutrient] = (breakdown[r.nutrient] ?? 0) + 1;
    }

    for (var entry in breakdown.entries) {
      final nutrient = entry.key;
      switch (nutrient) {
        case 'Iron':
          recommendations.add('🥬 Eat spinach, red meat, lentils, and fortified cereals');
          recommendations.add('🍊 Combine with Vitamin C for better absorption');
          break;
        case 'Vitamin B12':
          recommendations.add('🥚 Include eggs, dairy, fish, and fortified plant milk');
          recommendations.add('💊 Consider B12 supplements if vegetarian/vegan');
          break;
        case 'Vitamin D':
          recommendations.add('☀️ Get 15-20 minutes of sunlight daily');
          recommendations.add('🐟 Eat fatty fish, egg yolks, and fortified foods');
          break;
        case 'Calcium':
          recommendations.add('🥛 Consume dairy, leafy greens, and fortified foods');
          recommendations.add('🏃 Combine with weight-bearing exercise');
          break;
        case 'Vitamin A':
          recommendations.add('🥕 Eat carrots, sweet potatoes, and dark leafy greens');
          recommendations.add('🧈 Include healthy fats for better absorption');
          break;
      }
    }

    if (recommendations.isEmpty) {
      recommendations.add('✅ Great job! No major deficiencies detected.');
      recommendations.add('🎯 Continue maintaining a balanced diet.');
    }

    return recommendations
        .map((rec) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Text('• $rec', style: const pw.TextStyle(fontSize: 11)),
            ))
        .toList();
  }

  Future<void> _shareViaEmail() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📧 Email sharing coming soon! Your report will be sent to your doctor.'),
        duration: Duration(seconds: 3),
      ),
    );

    // TODO: Implement email sharing using share_plus or email launcher
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Health Report'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generatePDF,
            tooltip: 'Generate PDF',
          ),
          IconButton(
            icon: const Icon(Icons.email),
            onPressed: _shareViaEmail,
            tooltip: 'Email to Doctor',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.deepPurple, Colors.deepPurple.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.assessment, color: Colors.white, size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          'Nutrition Health Report',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Generated on ${DateFormat('MMM dd, yyyy').format(DateTime.now())}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          'Reporting Period: Last 30 days',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Summary Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'Deficiencies\nDetected',
                            _deficiencies.length.toString(),
                            Icons.warning_amber,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            'Meals\nLogged',
                            _meals.length.toString(),
                            Icons.restaurant_menu,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            'Avg Recovery\nScore',
                            _meals.isEmpty
                                ? 'N/A'
                                : '${(_meals.map((m) => m.recoveryScore).reduce((a, b) => a + b) / _meals.length).toStringAsFixed(0)}%',
                            Icons.trending_up,
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Health Summary
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.summarize, color: Colors.deepPurple),
                              SizedBox(width: 12),
                              Text(
                                'Health Summary',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Text(
                            _generateHealthSummary(),
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Recovery Trend Chart
                  if (_progressData.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.show_chart, color: Colors.blue),
                                SizedBox(width: 12),
                                Text(
                                  'Recovery Trend',
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
                                  gridData: const FlGridData(show: true),
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          if (value.toInt() >= 0 && value.toInt() < _progressData.length) {
                                            return Text(
                                              DateFormat('MM/dd').format(_progressData[value.toInt()].date),
                                              style: const TextStyle(fontSize: 10),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 40,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            value.toInt().toString(),
                                            style: const TextStyle(fontSize: 10),
                                          );
                                        },
                                      ),
                                    ),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  borderData: FlBorderData(show: true),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: _progressData.asMap().entries.map((entry) {
                                        return FlSpot(
                                          entry.key.toDouble(),
                                          entry.value.averageRecoveryScore,
                                        );
                                      }).toList(),
                                      isCurved: true,
                                      color: Colors.blue,
                                      barWidth: 3,
                                      dotData: const FlDotData(show: true),
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
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Deficiency Breakdown
                  if (_deficiencies.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.pie_chart, color: Colors.orange),
                                SizedBox(width: 12),
                                Text(
                                  'Deficiency Breakdown',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ..._getDeficiencyBreakdown().entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          entry.key,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '${entry.value} instances',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    LinearProgressIndicator(
                                      value: entry.value / _deficiencies.length,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation(Colors.orange[400]!),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _generatePDF,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text(
                              'Download PDF Report',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _shareViaEmail,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.deepPurple,
                              side: const BorderSide(color: Colors.deepPurple, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.email),
                            label: const Text(
                              'Email to Doctor',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _getDeficiencyBreakdown() {
    final Map<String, int> breakdown = {};
    for (var def in _deficiencies) {
      breakdown[def.nutrient] = (breakdown[def.nutrient] ?? 0) + 1;
    }
    return breakdown;
  }
}
