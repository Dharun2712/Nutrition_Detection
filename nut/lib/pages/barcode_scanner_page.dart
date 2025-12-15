/// Smart Ingredient Scanner
/// Scans barcodes to identify packaged foods and analyze nutritional content
library;

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;
  String? _scannedCode;
  Map<String, dynamic>? _productInfo;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _lookupProduct(String barcode) async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
      _scannedCode = barcode;
      _productInfo = null;
    });

    try {
      // Use Open Food Facts API
      final response = await http.get(
        Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1) {
          setState(() {
            _productInfo = data['product'];
          });
          _analyzeForDeficiency();
        } else {
          _showError('Product not found in database');
        }
      } else {
        _showError('Failed to fetch product information');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _analyzeForDeficiency() {
    if (_productInfo == null) return;

    final nutrients = _productInfo!['nutriments'] as Map<String, dynamic>?;
    if (nutrients == null) return;

    final recommendations = <String>[];
    
    // Check Iron
    final iron = nutrients['iron_100g'] ?? 0.0;
    if (iron > 2.0) {
      recommendations.add('✅ Good source of Iron');
    } else {
      recommendations.add('⚠️ Low in Iron - Not ideal for iron deficiency');
    }

    // Check Vitamin B12
    final b12 = nutrients['vitamin-b12_100g'] ?? 0.0;
    if (b12 > 0.5) {
      recommendations.add('✅ Contains Vitamin B12');
    }

    // Check Vitamin D
    final vitaminD = nutrients['vitamin-d_100g'] ?? 0.0;
    if (vitaminD > 1.0) {
      recommendations.add('✅ Good source of Vitamin D');
    }

    // Check Calcium
    final calcium = nutrients['calcium_100g'] ?? 0.0;
    if (calcium > 120.0) {
      recommendations.add('✅ Good source of Calcium');
    } else {
      recommendations.add('⚠️ Low in Calcium');
    }

    // Check Vitamin A
    final vitaminA = nutrients['vitamin-a_100g'] ?? 0.0;
    if (vitaminA > 80.0) {
      recommendations.add('✅ Contains Vitamin A');
    }

    _showRecommendations(recommendations);
  }

  void _showRecommendations(List<String> recommendations) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Nutritional Analysis',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ...recommendations.map((rec) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rec.substring(0, 2), style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                rec.substring(2),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildNutriscoreCard(String grade) {
    final colors = {
      'a': Colors.green,
      'b': Colors.lightGreen,
      'c': Colors.yellow,
      'd': Colors.orange,
      'e': Colors.red,
    };
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colors[grade.toLowerCase()] ?? Colors.grey,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.stars, color: Colors.white, size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nutri-Score',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  grade.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientBar(String label, String value, double ratio, Color color) {
    final clampedRatio = ratio.clamp(0.0, 1.0);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: clampedRatio,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasVitaminsOrMinerals() {
    final nutrients = _productInfo!['nutriments'] as Map<String, dynamic>?;
    if (nutrients == null) return false;
    
    return nutrients.containsKey('calcium_100g') ||
           nutrients.containsKey('iron_100g') ||
           nutrients.containsKey('vitamin-a_100g') ||
           nutrients.containsKey('vitamin-c_100g') ||
           nutrients.containsKey('vitamin-d_100g') ||
           nutrients.containsKey('vitamin-b12_100g');
  }

  Widget _buildMicronutrientGrid() {
    final nutrients = _productInfo!['nutriments'] as Map<String, dynamic>;
    final micronutrients = <Widget>[];

    if (nutrients['calcium_100g'] != null) {
      micronutrients.add(_buildMicronutrientChip(
        '🦴 Calcium',
        '${nutrients['calcium_100g']}mg',
        Colors.blue,
      ));
    }
    if (nutrients['iron_100g'] != null) {
      micronutrients.add(_buildMicronutrientChip(
        '⚡ Iron',
        '${nutrients['iron_100g']}mg',
        Colors.red,
      ));
    }
    if (nutrients['vitamin-a_100g'] != null) {
      micronutrients.add(_buildMicronutrientChip(
        '👁️ Vitamin A',
        '${nutrients['vitamin-a_100g']}μg',
        Colors.orange,
      ));
    }
    if (nutrients['vitamin-c_100g'] != null) {
      micronutrients.add(_buildMicronutrientChip(
        '🍊 Vitamin C',
        '${nutrients['vitamin-c_100g']}mg',
        Colors.orange,
      ));
    }
    if (nutrients['vitamin-d_100g'] != null) {
      micronutrients.add(_buildMicronutrientChip(
        '☀️ Vitamin D',
        '${nutrients['vitamin-d_100g']}μg',
        Colors.yellow,
      ));
    }
    if (nutrients['vitamin-b12_100g'] != null) {
      micronutrients.add(_buildMicronutrientChip(
        '💊 B12',
        '${nutrients['vitamin-b12_100g']}μg',
        Colors.purple,
      ));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: micronutrients,
    );
  }

  Widget _buildMicronutrientChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthAnalysis() {
    final nutrients = _productInfo!['nutriments'] as Map<String, dynamic>?;
    if (nutrients == null) return const SizedBox.shrink();

    final recommendations = <Map<String, dynamic>>[];

    // Check Iron
    final iron = nutrients['iron_100g'] ?? 0.0;
    if (iron > 2.0) {
      recommendations.add({
        'icon': '✅',
        'text': 'Good source of Iron - supports blood health',
        'color': Colors.green,
      });
    } else {
      recommendations.add({
        'icon': '⚠️',
        'text': 'Low in Iron - not ideal for iron deficiency',
        'color': Colors.orange,
      });
    }

    // Check Calcium
    final calcium = nutrients['calcium_100g'] ?? 0.0;
    if (calcium > 120.0) {
      recommendations.add({
        'icon': '✅',
        'text': 'Excellent source of Calcium for bone health',
        'color': Colors.green,
      });
    }

    // Check Vitamin C
    final vitaminC = nutrients['vitamin-c_100g'] ?? 0.0;
    if (vitaminC > 15.0) {
      recommendations.add({
        'icon': '✅',
        'text': 'Rich in Vitamin C - boosts immunity',
        'color': Colors.green,
      });
    }

    // Check Sugar
    final sugar = nutrients['sugars_100g'] ?? 0.0;
    if (sugar > 15.0) {
      recommendations.add({
        'icon': '⚠️',
        'text': 'High sugar content - consume in moderation',
        'color': Colors.red,
      });
    }

    // Check Salt
    final salt = nutrients['salt_100g'] ?? 0.0;
    if (salt > 1.5) {
      recommendations.add({
        'icon': '⚠️',
        'text': 'High salt content - may affect blood pressure',
        'color': Colors.red,
      });
    }

    if (recommendations.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.health_and_safety, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                const Text(
                  'Health Impact Analysis',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rec['icon'], style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      rec['text'],
                      style: TextStyle(
                        fontSize: 15,
                        color: rec['color'],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Food Barcode'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(cameraController.torchEnabled == TorchState.on
                ? Icons.flash_on
                : Icons.flash_off),
            onPressed: () => cameraController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && !_isProcessing) {
                final barcode = barcodes.first;
                if (barcode.rawValue != null) {
                  _lookupProduct(barcode.rawValue!);
                }
              }
            },
          ),

          // Scanning overlay
          Center(
            child: Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  'Align barcode within frame',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),

          // Loading indicator
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Product info card
          if (_productInfo != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.75,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product header
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _productInfo!['product_name'] ?? 'Unknown Product',
                                    style: const TextStyle(
                                        fontSize: 22, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _productInfo!['brands'] ?? '',
                                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _productInfo = null;
                                  _scannedCode = null;
                                });
                              },
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Nutrition Score
                        if (_productInfo!['nutriscore_grade'] != null)
                          _buildNutriscoreCard(_productInfo!['nutriscore_grade']),

                        const SizedBox(height: 16),

                        // Main Nutrients
                        const Text(
                          '📊 Nutrition Facts (per 100g)',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),

                        if (_productInfo!['nutriments'] != null) ...[
                          _buildNutrientBar(
                            'Energy',
                            '${_productInfo!['nutriments']['energy-kcal_100g'] ?? 0} kcal',
                            (_productInfo!['nutriments']['energy-kcal_100g'] ?? 0) / 2500,
                            Colors.orange,
                          ),
                          _buildNutrientBar(
                            'Proteins',
                            '${_productInfo!['nutriments']['proteins_100g'] ?? 0}g',
                            (_productInfo!['nutriments']['proteins_100g'] ?? 0) / 50,
                            Colors.blue,
                          ),
                          _buildNutrientBar(
                            'Carbs',
                            '${_productInfo!['nutriments']['carbohydrates_100g'] ?? 0}g',
                            (_productInfo!['nutriments']['carbohydrates_100g'] ?? 0) / 300,
                            Colors.purple,
                          ),
                          _buildNutrientBar(
                            'Fat',
                            '${_productInfo!['nutriments']['fat_100g'] ?? 0}g',
                            (_productInfo!['nutriments']['fat_100g'] ?? 0) / 70,
                            Colors.red,
                          ),
                          _buildNutrientBar(
                            'Sugar',
                            '${_productInfo!['nutriments']['sugars_100g'] ?? 0}g',
                            (_productInfo!['nutriments']['sugars_100g'] ?? 0) / 90,
                            Colors.pink,
                          ),
                          _buildNutrientBar(
                            'Fiber',
                            '${_productInfo!['nutriments']['fiber_100g'] ?? 0}g',
                            (_productInfo!['nutriments']['fiber_100g'] ?? 0) / 25,
                            Colors.green,
                          ),
                          _buildNutrientBar(
                            'Salt',
                            '${_productInfo!['nutriments']['salt_100g'] ?? 0}g',
                            (_productInfo!['nutriments']['salt_100g'] ?? 0) / 6,
                            Colors.grey,
                          ),

                          const SizedBox(height: 20),

                          // Vitamins & Minerals
                          if (_hasVitaminsOrMinerals()) ...[
                            const Text(
                              '💊 Vitamins & Minerals',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            _buildMicronutrientGrid(),
                            const SizedBox(height: 20),
                          ],

                          // Health Analysis
                          _buildHealthAnalysis(),

                          const SizedBox(height: 16),

                          // Ingredients
                          if (_productInfo!['ingredients_text'] != null) ...[
                            const Text(
                              '📝 Ingredients',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _productInfo!['ingredients_text'],
                                style: const TextStyle(fontSize: 14, height: 1.5),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Scan another button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _productInfo = null;
                                  _scannedCode = null;
                                });
                              },
                              icon: const Icon(Icons.qr_code_scanner),
                              label: const Text('Scan Another Product'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
