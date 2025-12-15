/// Data models for health tracking and nutrition analysis
library;

import 'package:intl/intl.dart';

/// Severity levels for deficiencies
enum DeficiencySeverity {
  normal,
  mild,
  moderate,
  severe;

  String get displayName {
    switch (this) {
      case DeficiencySeverity.normal:
        return 'Normal';
      case DeficiencySeverity.mild:
        return 'Mild';
      case DeficiencySeverity.moderate:
        return 'Moderate';
      case DeficiencySeverity.severe:
        return 'Severe';
    }
  }

  /// Get severity from confidence score (0-1)
  static DeficiencySeverity fromConfidence(double confidence) {
    if (confidence < 0.3) return DeficiencySeverity.normal;
    if (confidence < 0.6) return DeficiencySeverity.mild;
    if (confidence < 0.85) return DeficiencySeverity.moderate;
    return DeficiencySeverity.severe;
  }
}

/// Represents a detected deficiency with details
class DeficiencyRecord {
  final String id;
  final DateTime detectedAt;
  final String bodyPart;
  final String nutrient; // Iron, B12, Vitamin A, etc.
  final DeficiencySeverity severity;
  final double confidence;
  final List<String> visualSigns; // pale, ridge, cracked, etc.
  final String? imagePath;

  DeficiencyRecord({
    required this.id,
    required this.detectedAt,
    required this.bodyPart,
    required this.nutrient,
    required this.severity,
    required this.confidence,
    required this.visualSigns,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'detectedAt': detectedAt.millisecondsSinceEpoch,
      'bodyPart': bodyPart,
      'nutrient': nutrient,
      'severity': severity.index,
      'confidence': confidence,
      'visualSigns': visualSigns.join(','),
      'imagePath': imagePath,
    };
  }

  factory DeficiencyRecord.fromMap(Map<String, dynamic> map) {
    return DeficiencyRecord(
      id: map['id'],
      detectedAt: DateTime.fromMillisecondsSinceEpoch(map['detectedAt']),
      bodyPart: map['bodyPart'],
      nutrient: map['nutrient'],
      severity: DeficiencySeverity.values[map['severity']],
      confidence: map['confidence'],
      visualSigns: (map['visualSigns'] as String).split(','),
      imagePath: map['imagePath'],
    );
  }
}

/// Food item detected in meal analysis
class FoodItem {
  final String name;
  final double confidence;
  final Map<String, double> nutrients; // nutrient name -> amount (% daily value)

  FoodItem({
    required this.name,
    required this.confidence,
    required this.nutrients,
  });

  double getNutrientAmount(String nutrient) => nutrients[nutrient] ?? 0.0;
}

/// Meal record with analyzed food items
class MealRecord {
  final String id;
  final DateTime consumedAt;
  final List<FoodItem> foods;
  final String? imagePath;
  final int recoveryScore; // 0-100 based on deficiency match
  final String feedbackMessage;

  MealRecord({
    required this.id,
    required this.consumedAt,
    required this.foods,
    this.imagePath,
    required this.recoveryScore,
    required this.feedbackMessage,
  });

  /// Calculate total nutrient amounts
  Map<String, double> get totalNutrients {
    final totals = <String, double>{};
    for (final food in foods) {
      food.nutrients.forEach((nutrient, amount) {
        totals[nutrient] = (totals[nutrient] ?? 0.0) + amount;
      });
    }
    return totals;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'consumedAt': consumedAt.millisecondsSinceEpoch,
      'foods': foods.map((f) => {
        'name': f.name,
        'confidence': f.confidence,
        'nutrients': f.nutrients,
      }).toList(),
      'imagePath': imagePath,
      'recoveryScore': recoveryScore,
      'feedbackMessage': feedbackMessage,
    };
  }

  factory MealRecord.fromMap(Map<String, dynamic> map) {
    return MealRecord(
      id: map['id'],
      consumedAt: DateTime.fromMillisecondsSinceEpoch(map['consumedAt']),
      foods: (map['foods'] as List).map((f) => FoodItem(
        name: f['name'],
        confidence: f['confidence'],
        nutrients: Map<String, double>.from(f['nutrients']),
      )).toList(),
      imagePath: map['imagePath'],
      recoveryScore: map['recoveryScore'],
      feedbackMessage: map['feedbackMessage'],
    );
  }
}

/// User's health profile with active deficiencies
class HealthProfile {
  final List<DeficiencyRecord> activeDeficiencies;
  final List<MealRecord> mealHistory;
  final DateTime lastUpdated;

  HealthProfile({
    required this.activeDeficiencies,
    required this.mealHistory,
    required this.lastUpdated,
  });

  /// Get unique nutrients that are deficient
  Set<String> get deficientNutrients {
    return activeDeficiencies.map((d) => d.nutrient).toSet();
  }

  /// Get meals from last N days
  List<MealRecord> getMealsInLastDays(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return mealHistory.where((m) => m.consumedAt.isAfter(cutoff)).toList();
  }

  /// Calculate average recovery score over last N days
  double getAverageRecoveryScore(int days) {
    final meals = getMealsInLastDays(days);
    if (meals.isEmpty) return 0.0;
    return meals.map((m) => m.recoveryScore).reduce((a, b) => a + b) / meals.length;
  }
}

/// Nutrient database entry
class NutrientInfo {
  final String name;
  final String description;
  final List<String> foodSources;
  final String benefits;
  final String deficiencySymptoms;

  NutrientInfo({
    required this.name,
    required this.description,
    required this.foodSources,
    required this.benefits,
    required this.deficiencySymptoms,
  });
}

/// Progress tracking data point
class ProgressDataPoint {
  final DateTime date;
  final Map<String, DeficiencySeverity> deficiencies;
  final double averageRecoveryScore;

  ProgressDataPoint({
    required this.date,
    required this.deficiencies,
    required this.averageRecoveryScore,
  });

  String get formattedDate => DateFormat('MMM dd').format(date);
}
