/// Meal Quality Detection
/// Analyzes meal quality - detects oil, freshness, burnt food from images
library;

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;

class MealQualityDetectorPage extends StatefulWidget {
  const MealQualityDetectorPage({super.key});

  @override
  State<MealQualityDetectorPage> createState() => _MealQualityDetectorPageState();
}

class _MealQualityDetectorPageState extends State<MealQualityDetectorPage> {
  Uint8List? _imageBytes;
  bool _isAnalyzing = false;
  MealQualityReport? _qualityReport;

  Future<void> _pickAndAnalyzeImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true, // ensure bytes populated for web
      );

      if (result != null && result.files.first.bytes != null) {
        setState(() {
          _imageBytes = result.files.first.bytes;
          _isAnalyzing = true;
          _qualityReport = null;
        });

        await _analyzeMealQuality();
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  Future<void> _analyzeMealQuality() async {
    if (_imageBytes == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final groqApiKey = prefs.getString('groq_api_key') ?? 
          ''; // TODO: Add your GROQ API key here

      // Compress image
      final compressedBytes = await _compressImage(_imageBytes!);
      final base64Image = base64Encode(compressedBytes);

      print('🔍 Analyzing meal quality with vision model...');

      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $groqApiKey',
        },
        body: json.encode({
          'model': 'meta-llama/llama-4-scout-17b-16e-instruct',
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': '''Analyze this meal image for quality and health impact. Respond ONLY with JSON:
{
  "freshness": 8,
  "oilContent": "Medium",
  "cookingQuality": "Perfect",
  "color": "Natural",
  "texture": "Good",
  "overallScore": 85,
  "healthImpact": "Positive",
  "warnings": ["Warning if any"],
  "recommendations": ["Tip 1", "Tip 2"],
  "detectedFoods": ["item1", "item2"],
  "calories": 450,
  "analysis": "Brief quality assessment"
}'''
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': 'data:image/jpeg;base64,$base64Image'
                  }
                }
              ]
            }
          ],
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      print('📊 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        print('📝 Response: $content');

        // Extract JSON from response
        final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(content);
        if (jsonMatch != null) {
          final result = json.decode(jsonMatch.group(0)!);
          setState(() {
            _qualityReport = MealQualityReport.fromJson(result);
          });
        } else {
          _showError('Failed to parse quality analysis');
        }
      } else {
        final errorBody = response.body;
        print('❌ Error: $errorBody');
        _showError('Failed to analyze: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exception: $e');
      _showError('Error: $e');
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  Future<Uint8List> _compressImage(Uint8List bytes) async {
    final image = img.decodeImage(bytes);
    if (image == null) return bytes;

    // Resize to max 512px
    final resized = img.copyResize(image, width: 512);
    
    // Encode as JPEG with quality 60
    return Uint8List.fromList(img.encodeJpg(resized, quality: 60));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Quality Detector'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Upload button
              if (_imageBytes == null)
                Card(
                  elevation: 4,
                  child: InkWell(
                    onTap: _pickAndAnalyzeImage,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade100, Colors.orange.shade300],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 64, color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Upload Food Image',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'We\'ll analyze freshness, oil content & quality',
                            style: TextStyle(fontSize: 14, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Image preview
              if (_imageBytes != null) ...[
                Card(
                  elevation: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      _imageBytes!,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _pickAndAnalyzeImage,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Analyze Another'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],

              // Loading
              if (_isAnalyzing) ...[
                const SizedBox(height: 32),
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Analyzing meal quality...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
              ],

              // Quality report
              if (_qualityReport != null && !_isAnalyzing) ...[
                const SizedBox(height: 24),
                
                // Overall score with animated gradient
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getScoreColor(_qualityReport!.overallScore),
                          _getScoreColor(_qualityReport!.overallScore).withValues(alpha: 0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.grade, color: Colors.white, size: 48),
                        const SizedBox(height: 12),
                        const Text(
                          'Quality Score',
                          style: TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_qualityReport!.overallScore}',
                          style: const TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [Shadow(blurRadius: 10, color: Colors.black26)],
                          ),
                        ),
                        Text(
                          _qualityReport!.overallScore >= 80
                              ? '🌟 Excellent Quality'
                              : _qualityReport!.overallScore >= 60
                                  ? '✅ Good Quality'
                                  : '⚠️ Needs Improvement',
                          style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Detected Foods
                if (_qualityReport!.detectedFoods.isNotEmpty) ...[
                  const Text(
                    '🍽️ Detected Foods',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _qualityReport!.detectedFoods.map((food) => Chip(
                      label: Text(food),
                      backgroundColor: Colors.orange.shade100,
                      avatar: const Icon(Icons.restaurant, size: 18),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Calories
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_fire_department, color: Colors.orange.shade700, size: 32),
                        const SizedBox(width: 12),
                        Text(
                          '~${_qualityReport!.calories} kcal',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Health Impact
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: _getHealthImpactColor(_qualityReport!.healthImpact),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(
                          _getHealthImpactIcon(_qualityReport!.healthImpact),
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Health Impact',
                                style: TextStyle(fontSize: 14, color: Colors.white70),
                              ),
                              Text(
                                _qualityReport!.healthImpact,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Quality metrics
                const Text(
                  '📊 Quality Metrics',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                _buildMetricCard('Freshness', '${_qualityReport!.freshness}/10',
                    Icons.eco, Colors.green),
                _buildMetricCard('Oil Content', _qualityReport!.oilContent,
                    Icons.opacity, Colors.orange),
                _buildMetricCard('Cooking Quality', _qualityReport!.cookingQuality,
                    Icons.local_fire_department, Colors.red),
                _buildMetricCard('Color', _qualityReport!.color,
                    Icons.palette, Colors.purple),
                _buildMetricCard('Texture', _qualityReport!.texture,
                    Icons.grain, Colors.brown),

                // Warnings
                if (_qualityReport!.warnings.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 28),
                              const SizedBox(width: 12),
                              const Text(
                                'Health Warnings',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ..._qualityReport!.warnings.map(
                            (warning) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('⚠️ ', style: TextStyle(fontSize: 16)),
                                  Expanded(
                                    child: Text(
                                      warning,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.red.shade900,
                                      ),
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
                ],

                // Recommendations
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.tips_and_updates, color: Colors.green.shade700, size: 28),
                            const SizedBox(width: 12),
                            const Text(
                              'Recommendations',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ..._qualityReport!.recommendations.map(
                          (rec) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('💡 ', style: TextStyle(fontSize: 16)),
                                Expanded(
                                  child: Text(
                                    rec,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.green.shade900,
                                    ),
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

                // Analysis
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.article, color: Colors.blue.shade700),
                            const SizedBox(width: 12),
                            const Text(
                              'Detailed Analysis',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _qualityReport!.analysis,
                          style: const TextStyle(fontSize: 15, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Info section
              if (_qualityReport == null && !_isAnalyzing) ...[
                const SizedBox(height: 32),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'What We Detect:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text('✓ Food freshness level'),
                        Text('✓ Excessive oil/grease'),
                        Text('✓ Burnt or overcooked food'),
                        Text('✓ Color abnormalities'),
                        Text('✓ Texture issues (soggy, dry)'),
                        Text('✓ Overall nutritional quality'),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  Color _getHealthImpactColor(String impact) {
    switch (impact.toLowerCase()) {
      case 'positive':
      case 'excellent':
        return Colors.green;
      case 'neutral':
      case 'moderate':
        return Colors.orange;
      case 'negative':
      case 'poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getHealthImpactIcon(String impact) {
    switch (impact.toLowerCase()) {
      case 'positive':
      case 'excellent':
        return Icons.favorite;
      case 'neutral':
      case 'moderate':
        return Icons.remove_circle_outline;
      case 'negative':
      case 'poor':
        return Icons.warning;
      default:
        return Icons.help_outline;
    }
  }
}

class MealQualityReport {
  final int freshness;
  final String oilContent;
  final String cookingQuality;
  final String color;
  final String texture;
  final int overallScore;
  final String healthImpact;
  final List<String> warnings;
  final List<String> recommendations;
  final List<String> detectedFoods;
  final int calories;
  final String analysis;

  MealQualityReport({
    required this.freshness,
    required this.oilContent,
    required this.cookingQuality,
    required this.color,
    required this.texture,
    required this.overallScore,
    required this.healthImpact,
    required this.warnings,
    required this.recommendations,
    required this.detectedFoods,
    required this.calories,
    required this.analysis,
  });

  factory MealQualityReport.fromJson(Map<String, dynamic> json) {
    return MealQualityReport(
      freshness: json['freshness'] ?? 5,
      oilContent: json['oilContent'] ?? 'Unknown',
      cookingQuality: json['cookingQuality'] ?? 'Unknown',
      color: json['color'] ?? 'Unknown',
      texture: json['texture'] ?? 'Unknown',
      overallScore: json['overallScore'] ?? 50,
      healthImpact: json['healthImpact'] ?? 'Neutral',
      warnings: List<String>.from(json['warnings'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      detectedFoods: List<String>.from(json['detectedFoods'] ?? []),
      calories: json['calories'] ?? 0,
      analysis: json['analysis'] ?? 'No analysis available',
    );
  }
}
