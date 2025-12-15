/// Nutrient information database and food analysis service
library;

import '../models/health_data.dart';

/// Comprehensive nutrient database
class NutrientDatabase {
  static final Map<String, NutrientInfo> _nutrients = {
    'Iron': NutrientInfo(
      name: 'Iron',
      description: 'Essential mineral for blood production and oxygen transport',
      foodSources: [
        'Spinach (100g = 20% DV)',
        'Red meat (100g = 15% DV)',
        'Lentils (1 cup = 37% DV)',
        'Pumpkin seeds (28g = 23% DV)',
        'Quinoa (1 cup = 15% DV)',
        'Dark chocolate (28g = 19% DV)',
        'Tofu (126g = 19% DV)',
      ],
      benefits: 'Prevents anemia, boosts energy, supports immune function',
      deficiencySymptoms: 'Pale nails/skin, fatigue, weakness, brittle nails',
    ),
    'Vitamin B12': NutrientInfo(
      name: 'Vitamin B12',
      description: 'Crucial for nerve function and red blood cell formation',
      foodSources: [
        'Eggs (2 large = 46% DV)',
        'Milk (1 cup = 54% DV)',
        'Salmon (100g = 80% DV)',
        'Chicken (100g = 13% DV)',
        'Fortified cereals (1 cup = 100% DV)',
        'Yogurt (1 cup = 38% DV)',
      ],
      benefits: 'Brain health, energy production, DNA synthesis',
      deficiencySymptoms: 'Swollen tongue, fatigue, memory issues, tingling hands/feet',
    ),
    'Vitamin B2': NutrientInfo(
      name: 'Vitamin B2 (Riboflavin)',
      description: 'Important for energy production and cellular function',
      foodSources: [
        'Almonds (28g = 17% DV)',
        'Eggs (1 large = 15% DV)',
        'Mushrooms (1 cup = 23% DV)',
        'Spinach (1 cup cooked = 21% DV)',
        'Milk (1 cup = 26% DV)',
      ],
      benefits: 'Skin health, eye health, energy metabolism',
      deficiencySymptoms: 'Cracked lips, magenta tongue, inflamed throat',
    ),
    'Calcium': NutrientInfo(
      name: 'Calcium',
      description: 'Essential for strong bones and teeth',
      foodSources: [
        'Milk (1 cup = 30% DV)',
        'Yogurt (1 cup = 30% DV)',
        'Cheese (28g = 20% DV)',
        'Sardines (100g = 38% DV)',
        'Kale (1 cup = 9% DV)',
        'Almonds (28g = 8% DV)',
      ],
      benefits: 'Bone strength, muscle function, nerve signaling',
      deficiencySymptoms: 'Brittle nails, weak bones, muscle cramps',
    ),
    'Vitamin A': NutrientInfo(
      name: 'Vitamin A',
      description: 'Critical for vision, immune system, and skin health',
      foodSources: [
        'Carrots (1 medium = 184% DV)',
        'Sweet potatoes (1 medium = 156% DV)',
        'Spinach (1 cup = 56% DV)',
        'Mango (1 cup = 25% DV)',
        'Egg (1 large = 6% DV)',
      ],
      benefits: 'Eye health, immune function, skin repair',
      deficiencySymptoms: 'Yellow tinge in eyes, night blindness, dry skin',
    ),
    'Vitamin C': NutrientInfo(
      name: 'Vitamin C',
      description: 'Powerful antioxidant for immune support and iron absorption',
      foodSources: [
        'Orange (1 medium = 92% DV)',
        'Strawberries (1 cup = 149% DV)',
        'Bell peppers (1 cup = 190% DV)',
        'Broccoli (1 cup = 135% DV)',
        'Tomatoes (1 medium = 28% DV)',
      ],
      benefits: 'Immune support, collagen production, wound healing',
      deficiencySymptoms: 'Bleeding gums, slow wound healing, fatigue',
    ),
    'B-Complex': NutrientInfo(
      name: 'B-Complex Vitamins',
      description: 'Group of vitamins essential for energy and metabolism',
      foodSources: [
        'Whole grains',
        'Eggs',
        'Leafy greens',
        'Legumes',
        'Nuts and seeds',
      ],
      benefits: 'Energy production, brain function, cell metabolism',
      deficiencySymptoms: 'Pale tongue, fatigue, irritability',
    ),
  };

  static NutrientInfo? get(String nutrient) => _nutrients[nutrient];
  static List<NutrientInfo> getAll() => _nutrients.values.toList();
}

/// Food recognition and nutrient mapping service
class FoodAnalyzer {
  /// Common Indian foods with their nutrient profiles (% daily value per 100g)
  static final Map<String, Map<String, double>> _foodDatabase = {
    // Vegetables
    'spinach': {'Iron': 20, 'Vitamin A': 56, 'Calcium': 10, 'Vitamin C': 47},
    'carrot': {'Vitamin A': 184, 'Vitamin C': 12, 'Iron': 2},
    'tomato': {'Vitamin C': 28, 'Vitamin A': 17, 'Iron': 2},
    'broccoli': {'Vitamin C': 135, 'Calcium': 4, 'Iron': 4, 'Vitamin A': 11},
    'bell pepper': {'Vitamin C': 190, 'Vitamin A': 8, 'Iron': 2},
    'kale': {'Vitamin A': 206, 'Vitamin C': 134, 'Calcium': 9, 'Iron': 6},
    
    // Proteins
    'chicken': {'Vitamin B12': 13, 'Iron': 5, 'B-Complex': 25},
    'egg': {'Vitamin B12': 23, 'Vitamin A': 6, 'Vitamin B2': 15, 'Iron': 5},
    'fish': {'Vitamin B12': 80, 'Vitamin A': 3, 'Iron': 6, 'B-Complex': 30},
    'salmon': {'Vitamin B12': 80, 'Iron': 3, 'B-Complex': 40},
    'tofu': {'Iron': 19, 'Calcium': 35, 'B-Complex': 5},
    'paneer': {'Calcium': 20, 'Vitamin B12': 10, 'Vitamin A': 4},
    
    // Grains
    'rice': {'Iron': 2, 'B-Complex': 8},
    'chapati': {'Iron': 10, 'B-Complex': 15, 'Calcium': 2},
    'quinoa': {'Iron': 15, 'B-Complex': 20, 'Calcium': 2},
    'oats': {'Iron': 20, 'B-Complex': 25, 'Calcium': 5},
    
    // Legumes
    'lentils': {'Iron': 37, 'B-Complex': 30, 'Calcium': 4},
    'dal': {'Iron': 35, 'B-Complex': 28, 'Calcium': 5},
    'chickpeas': {'Iron': 26, 'B-Complex': 20, 'Calcium': 5},
    'beans': {'Iron': 22, 'B-Complex': 18, 'Calcium': 6},
    
    // Dairy
    'milk': {'Calcium': 30, 'Vitamin B12': 54, 'Vitamin B2': 26, 'Vitamin A': 4},
    'yogurt': {'Calcium': 30, 'Vitamin B12': 38, 'Vitamin B2': 18},
    'cheese': {'Calcium': 20, 'Vitamin B12': 15, 'Vitamin A': 5},
    
    // Nuts & Seeds
    'almonds': {'Calcium': 8, 'Vitamin B2': 17, 'Iron': 6},
    'pumpkin seeds': {'Iron': 23, 'Calcium': 5, 'B-Complex': 10},
    'cashews': {'Iron': 11, 'B-Complex': 12, 'Calcium': 2},
    
    // Fruits
    'orange': {'Vitamin C': 92, 'Calcium': 5, 'Vitamin A': 4},
    'mango': {'Vitamin A': 25, 'Vitamin C': 67},
    'strawberry': {'Vitamin C': 149, 'Iron': 2},
    'banana': {'B-Complex': 22, 'Vitamin C': 17},
    
    // Others
    'dark chocolate': {'Iron': 19, 'Calcium': 3, 'B-Complex': 5},
    'beetroot': {'Iron': 4, 'Vitamin C': 8, 'B-Complex': 12},
  };

  /// Analyze detected foods against user's deficiencies
  static Map<String, dynamic> analyzeMeal({
    required List<FoodItem> detectedFoods,
    required Set<String> deficientNutrients,
  }) {
    // Calculate total nutrients from all foods
    final totalNutrients = <String, double>{};
    for (final food in detectedFoods) {
      food.nutrients.forEach((nutrient, amount) {
        totalNutrients[nutrient] = (totalNutrients[nutrient] ?? 0.0) + amount;
      });
    }

    // Calculate recovery score (0-100)
    int recoveryScore = 50; // Base score
    final helpfulNutrients = <String>[];
    final missingNutrients = <String>[];

    for (final nutrient in deficientNutrients) {
      final amount = totalNutrients[nutrient] ?? 0.0;
      if (amount >= 30) {
        recoveryScore += 15; // Excellent
        helpfulNutrients.add(nutrient);
      } else if (amount >= 15) {
        recoveryScore += 8; // Good
        helpfulNutrients.add(nutrient);
      } else {
        recoveryScore -= 5; // Missing
        missingNutrients.add(nutrient);
      }
    }

    // Cap the score
    recoveryScore = recoveryScore.clamp(0, 100);

    // Generate feedback message
    String feedbackMessage;
    if (recoveryScore >= 80) {
      feedbackMessage = '🌟 Excellent meal! This helps with ${helpfulNutrients.join(", ")} recovery.';
    } else if (recoveryScore >= 60) {
      feedbackMessage = '👍 Good choice! Provides ${helpfulNutrients.join(", ")}. ';
      if (missingNutrients.isNotEmpty) {
        feedbackMessage += 'Try adding foods rich in ${missingNutrients.join(", ")}.';
      }
    } else if (recoveryScore >= 40) {
      feedbackMessage = '⚠️ This meal is low in ${missingNutrients.join(", ")}. ';
      feedbackMessage += 'Consider adding ${_getSuggestions(missingNutrients)}.';
    } else {
      feedbackMessage = '❌ This meal doesn\'t address your deficiencies. ';
      feedbackMessage += 'Add: ${_getSuggestions(deficientNutrients.toList())}.';
    }

    return {
      'recoveryScore': recoveryScore,
      'feedbackMessage': feedbackMessage,
      'totalNutrients': totalNutrients,
      'helpfulNutrients': helpfulNutrients,
      'missingNutrients': missingNutrients,
    };
  }

  /// Get food suggestions for missing nutrients
  static String _getSuggestions(List<String> nutrients) {
    final suggestions = <String>[];
    for (final nutrient in nutrients) {
      final info = NutrientDatabase.get(nutrient);
      if (info != null && info.foodSources.isNotEmpty) {
        suggestions.add(info.foodSources.first.split(' ').first);
      }
    }
    return suggestions.take(3).join(', ');
  }

  /// Simulate food detection (replace with actual ML model)
  static List<FoodItem> detectFoods(List<int> imageBytes) {
    // TODO: Integrate with actual food recognition model
    // For now, return mock data for testing
    return [
      FoodItem(
        name: 'Rice',
        confidence: 0.92,
        nutrients: _foodDatabase['rice'] ?? {},
      ),
      FoodItem(
        name: 'Spinach',
        confidence: 0.88,
        nutrients: _foodDatabase['spinach'] ?? {},
      ),
      FoodItem(
        name: 'Dal',
        confidence: 0.85,
        nutrients: _foodDatabase['dal'] ?? {},
      ),
    ];
  }

  /// Get nutrient profile for a specific food
  static Map<String, double>? getFoodNutrients(String foodName) {
    return _foodDatabase[foodName.toLowerCase()];
  }

  /// Search for foods rich in specific nutrient
  static List<String> findFoodsRichIn(String nutrient, {double minAmount = 20}) {
    final richFoods = <String>[];
    _foodDatabase.forEach((food, nutrients) {
      if ((nutrients[nutrient] ?? 0.0) >= minAmount) {
        richFoods.add(food);
      }
    });
    return richFoods;
  }
}
