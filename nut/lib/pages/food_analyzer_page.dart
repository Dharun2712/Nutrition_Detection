/// AI Food Analyzer - Upload meal photos and get nutrient analysis
library;

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img_lib;
import 'package:http/http.dart' as http;
import '../models/health_data.dart';
import '../services/health_database.dart';
import '../utils/south_indian_diet_planner.dart';

class FoodAnalyzerPage extends StatefulWidget {
  final Set<String> deficientNutrients;

  const FoodAnalyzerPage({
    super.key,
    this.deficientNutrients = const {},
  });

  @override
  State<FoodAnalyzerPage> createState() => _FoodAnalyzerPageState();
}

class _FoodAnalyzerPageState extends State<FoodAnalyzerPage> {
  PlatformFile? _SelectedImagePlaceholderToAvoidEmptyFileStart;
  PlatformFile? _selectedImage;
  bool _isAnalyzing = false;
  MealRecord? _analysisResult;

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final content = data['choices'][0]['message']['content'].toString().trim();

            // Clean markdown if present
            String cleanedContent = content
                .replaceAll('```json', '')
                .replaceAll('```', '')
                .trim();

            // Extract JSON
            final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(cleanedContent);
            if (jsonMatch != null) {
              parsedResult = json.decode(jsonMatch.group(0)!);
              // Success - stop retrying
              break;
            } else {
              lastError = 'Invalid JSON response from model $modelName';
              // try next model
              continue;
            }
          } else {
            // If model was decommissioned, try next candidate
            final bodyLower = response.body.toLowerCase();
            if (bodyLower.contains('decommission') || bodyLower.contains('decommissioned') || bodyLower.contains('model_decommissioned')) {
              lastError = 'Model $modelName decommissioned; trying next model';
              continue; // try next candidate
            }
            lastError = 'Vision API error (${response.statusCode}): ${response.body}';
            // For other non-retryable errors, break and surface message
            break;
          }
        } catch (err) {
          lastError = err.toString();
          // Try next model candidate
          continue;
        }
      }

      if (parsedResult == null) {
        throw Exception('Vision API failed: ${lastError ?? 'Unknown error'}');
      }

      // Convert GROQ response to app format
      final result = parsedResult;
      List<FoodItem> detectedFoods = [];
      
      if (result['foods'] is List) {
        for (var foodData in result['foods']) {
          if (foodData is! Map) continue;
          
          // Extract nutrients from each food item
          Map<String, double> nutrients = {};
          if (foodData['nutrients'] is Map) {
            final nutrientsRaw = foodData['nutrients'] as Map;
            nutrientsRaw.forEach((key, value) {
              double val = 0.0;
              if (value is num) {
                val = value.toDouble();
              } else if (value is String) {
                val = double.tryParse(value) ?? 0.0;
              }
              nutrients[key.toString()] = val;
            });
          }
          
          detectedFoods.add(FoodItem(
            name: foodData['name']?.toString() ?? 'Unknown Food',
            confidence: (foodData['confidence'] is num) 
                ? (foodData['confidence'] as num).toDouble() 
                : 0.95,
            nutrients: nutrients,
          ));
        }
      }
      
      // Calculate total nutrients across all foods
      Map<String, double> totalNutrients = {};
      for (var food in detectedFoods) {
        food.nutrients.forEach((key, value) {
          totalNutrients[key] = (totalNutrients[key] ?? 0.0) + value;
        });
      }
      
      // Calculate recovery score based on deficiencies
      int recoveryScore = _calculateRecoveryScore(totalNutrients, widget.deficientNutrients);
      
      // Get health advice from response or generate one
      String healthAdvice = result['health_advice']?.toString() ?? 
          'Meal analyzed. Continue eating balanced meals for optimal nutrition.';

      // Create meal record with GROQ analysis
      final mealRecord = MealRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        consumedAt: DateTime.now(),
        foods: detectedFoods,
        imagePath: kIsWeb ? null : _selectedImage!.path,
        recoveryScore: recoveryScore,
        feedbackMessage: healthAdvice,
      );

      // Save to database
      await HealthDatabase.instance.insertMeal(mealRecord);

      setState(() {
        _analysisResult = mealRecord;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      if (mounted) {
        // Show a retry dialog with error details (keeps snackbar as fallback)
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Analysis failed'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _analyzeFood();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error analyzing food: ${e.toString()}')),
        );
      }
    }
  }

  // Calculate recovery score based on nutrients and deficiencies
  int _calculateRecoveryScore(Map<String, double> nutrients, Set<String> deficiencies) {
    if (deficiencies.isEmpty) return 75; // base score if no deficiencies
    
    int score = 50; // base score
    
    // Map deficiencies to nutrient keys
    final deficiencyNutrientMap = {
      'Iron': ['iron_mg'],
      'Vitamin B12': ['protein_g'], // B12 found in protein sources
      'Vitamin A': ['vitaminA_IU'],
      'Vitamin C': ['vitaminC_mg'],
      'Calcium': ['calcium_mg'],
      'Vitamin D': ['vitaminA_IU', 'calcium_mg'], // Often co-occur
      'Vitamin B Complex': ['protein_g'],
      'Vitamin B2': ['protein_g'],
    };
    
    // Check which deficiencies are addressed
    int addressedCount = 0;
    for (var deficiency in deficiencies) {
      if (deficiencyNutrientMap.containsKey(deficiency)) {
        final nutrientKeys = deficiencyNutrientMap[deficiency]!;
        for (var key in nutrientKeys) {
          if (nutrients[key] != null && nutrients[key]! > 5.0) {
            addressedCount++;
            break;
          }
        }
      }
    }
    
    // Add points for addressing deficiencies
    if (deficiencies.isNotEmpty) {
      score += ((addressedCount / deficiencies.length) * 40).round();
    }
    
    // Add points for overall nutrition
    double totalNutrition = 0;
    nutrients.forEach((key, value) {
      if (value > 0) totalNutrition += 1;
    });
    score += (totalNutrition * 2).round().clamp(0, 10);
    
    return score.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Food Analyzer'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple[400]!, Colors.purple[600]!],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.restaurant_menu,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Smart Meal Analyzer',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload your meal photo to get nutrient analysis',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            

            // Upload Section
            if (_selectedImage == null)
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.deepPurple,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.deepPurple.withOpacity(0.05),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 64,
                          color: Colors.deepPurple[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tap to upload meal photo',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.deepPurple[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
                  // Image Preview
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 250,
                      width: double.infinity,
                      child: kIsWeb
                          ? Image.memory(
                              _selectedImage!.bytes!,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(_selectedImage!.path!),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Change Photo'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isAnalyzing ? null : _analyzeFood,
                          icon: _isAnalyzing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.analytics),
                          label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

            // Analysis Results
            if (_analysisResult != null) ...[
              const SizedBox(height: 32),
              _buildAnalysisResults(_analysisResult!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResults(MealRecord meal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Large uploaded image preview at the top
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: kIsWeb
              ? (_selectedImage != null && _selectedImage!.bytes != null
                  ? Image.memory(
                      _selectedImage!.bytes!,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: double.infinity,
                      height: 250,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 64),
                    ))
              : (_selectedImage != null && _selectedImage!.path != null
                  ? Image.file(
                      File(_selectedImage!.path!),
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: double.infinity,
                      height: 250,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 64),
                    )),
        ),
        const SizedBox(height: 20),
        
        // Recovery Score Card (simplified, no thumbnail since image is above)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _getScoreColors(meal.recoveryScore),
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text(
                'Recovery Score',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${meal.recoveryScore}/100',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getScoreMessage(meal.recoveryScore),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Feedback Message
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb, color: Colors.blue[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  meal.feedbackMessage,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Detected Foods (cards)
        const Text(
          'Detected Foods',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: meal.foods.map((food) => _buildFoodCard(food)).toList(),
        ),

        // Total Nutrients
        const SizedBox(height: 20),
        const Text(
          'Total Nutrients',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Column(
            children: meal.totalNutrients.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${entry.value.toStringAsFixed(0)}% DV',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        
        // (Diet plan is available from the Personalized Diet Plan screen)
        const SizedBox(height: 16),
      ],
    );
  }
  
  Widget _build7DayDietPlan() {
    // Import the planner at the top of file
    final dietPlan = SouthIndianDietPlanner.generateWeekPlan(
      ageGroup: _selectedAgeGroup,
      deficientNutrients: widget.deficientNutrients,
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange[400]!, Colors.deepOrange[600]!],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '7-Day Personalized Diet Plan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'South Indian meals for $_selectedAgeGroup',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Age-specific advice
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  SouthIndianDietPlanner.getAgeSpecificAdvice(_selectedAgeGroup),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Day-by-day meal plans
        ...dietPlan.entries.map((dayEntry) {
          return _buildDayCard(dayEntry.key, dayEntry.value);
        }),
      ],
    );
  }
  
  Widget _buildDayCard(String dayName, List<Map<String, String>> meals) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.deepPurple[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.restaurant, color: Colors.deepPurple[700], size: 24),
        ),
        title: Text(
          dayName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${meals.length} meals planned',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        children: meals.map((meal) {
          return Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        meal['meal']!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple[900],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  meal['food']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.green[600]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        meal['benefits']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFoodCard(FoodItem food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                food.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(food.confidence * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (food.nutrients.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: food.nutrients.entries.take(5).map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${entry.key}: ${entry.value.toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            // Simple visual bars for key macros
            if (food.nutrients.containsKey('calories_kcal')) ...[
              _nutrientBar('Calories', food.nutrients['calories_kcal'] ?? 0, Colors.orange),
            ],
            if (food.nutrients.containsKey('protein_g')) ...[
              _nutrientBar('Protein (g)', food.nutrients['protein_g'] ?? 0, Colors.green),
            ],
          ],
        ],
      ),
    );
  }

  List<Color> _getScoreColors(int score) {
    if (score >= 80) {
      return [Colors.green[400]!, Colors.green[600]!];
    } else if (score >= 60) {
      return [Colors.blue[400]!, Colors.blue[600]!];
    } else if (score >= 40) {
      return [Colors.orange[400]!, Colors.orange[600]!];
    } else {
      return [Colors.red[400]!, Colors.red[600]!];
    }
  }

  String _getScoreMessage(int score) {
    if (score >= 80) {
      return 'Excellent meal for your deficiencies!';
    } else if (score >= 60) {
      return 'Good nutritional match';
    } else if (score >= 40) {
      return 'Fair - could be improved';
    } else {
      return 'Low nutritional value for your needs';
    }
  }

  Widget _nutrientBar(String label, double value, Color color) {
    // value is expected in absolute units (calories or grams). We'll map to a small normalized 0-1 for visualization
    double normalized = (value / (value + 50)).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: normalized,
              minHeight: 8,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
