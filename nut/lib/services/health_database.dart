/// Database service for storing health and nutrition data
library;

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/health_data.dart';

class HealthDatabase {
  static Database? _database;
  static final HealthDatabase instance = HealthDatabase._();

  HealthDatabase._();

  // In-memory fallback for web (sqflite is not supported on web)
  final List<MealRecord> _inMemoryMeals = [];
  final List<DeficiencyRecord> _inMemoryDeficiencies = [];

  Future<Database> get database async {
    if (kIsWeb) {
      throw Exception('Database not available on web; use in-memory storage via methods');
    }

    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'nutrition_health.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Deficiency records table
    await db.execute('''
      CREATE TABLE deficiencies (
        id TEXT PRIMARY KEY,
        detectedAt INTEGER NOT NULL,
        bodyPart TEXT NOT NULL,
        nutrient TEXT NOT NULL,
        severity INTEGER NOT NULL,
        confidence REAL NOT NULL,
        visualSigns TEXT NOT NULL,
        imagePath TEXT
      )
    ''');

    // Meal records table
    await db.execute('''
      CREATE TABLE meals (
        id TEXT PRIMARY KEY,
        consumedAt INTEGER NOT NULL,
        imagePath TEXT,
        recoveryScore INTEGER NOT NULL,
        feedbackMessage TEXT NOT NULL
      )
    ''');

    // Food items table (related to meals)
    await db.execute('''
      CREATE TABLE food_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mealId TEXT NOT NULL,
        name TEXT NOT NULL,
        confidence REAL NOT NULL,
        nutrients TEXT NOT NULL,
        FOREIGN KEY (mealId) REFERENCES meals (id)
      )
    ''');

    // Create indices for faster queries
    await db.execute('CREATE INDEX idx_deficiency_date ON deficiencies(detectedAt)');
    await db.execute('CREATE INDEX idx_meal_date ON meals(consumedAt)');
  }

  // ========== DEFICIENCY OPERATIONS ==========

  Future<void> insertDeficiency(DeficiencyRecord record) async {
    if (kIsWeb) {
      _inMemoryDeficiencies.add(record);
      return;
    }

    final db = await database;
    await db.insert('deficiencies', record.toMap());
  }

  Future<List<DeficiencyRecord>> getRecentDeficiencies({int days = 30}) async {
    if (kIsWeb) {
      final cutoff = DateTime.now().subtract(Duration(days: days));
      return _inMemoryDeficiencies.where((d) => d.detectedAt.isAfter(cutoff)).toList();
    }

    final db = await database;
    final cutoff = DateTime.now().subtract(Duration(days: days)).millisecondsSinceEpoch;
    
    final maps = await db.query(
      'deficiencies',
      where: 'detectedAt >= ?',
      whereArgs: [cutoff],
      orderBy: 'detectedAt DESC',
    );

    return maps.map((map) => DeficiencyRecord.fromMap(map)).toList();
  }

  Future<List<DeficiencyRecord>> getDeficienciesByNutrient(String nutrient) async {
    if (kIsWeb) {
      return _inMemoryDeficiencies.where((d) => d.nutrient == nutrient).toList();
    }

    final db = await database;
    
    final maps = await db.query(
      'deficiencies',
      where: 'nutrient = ?',
      whereArgs: [nutrient],
      orderBy: 'detectedAt DESC',
    );

    return maps.map((map) => DeficiencyRecord.fromMap(map)).toList();
  }

  // ========== MEAL OPERATIONS ==========

  Future<void> insertMeal(MealRecord meal) async {
    if (kIsWeb) {
      _inMemoryMeals.add(meal);
      return;
    }

    final db = await database;

    // Insert meal record
    await db.insert('meals', {
      'id': meal.id,
      'consumedAt': meal.consumedAt.millisecondsSinceEpoch,
      'imagePath': meal.imagePath,
      'recoveryScore': meal.recoveryScore,
      'feedbackMessage': meal.feedbackMessage,
    });

    // Insert food items
    for (final food in meal.foods) {
      await db.insert('food_items', {
        'mealId': meal.id,
        'name': food.name,
        'confidence': food.confidence,
        'nutrients': _encodeNutrients(food.nutrients),
      });
    }
  }

  Future<List<MealRecord>> getRecentMeals({int days = 7}) async {
    if (kIsWeb) {
      final cutoff = DateTime.now().subtract(Duration(days: days));
      return _inMemoryMeals.where((m) => m.consumedAt.isAfter(cutoff)).toList();
    }

    final db = await database;
    final cutoff = DateTime.now().subtract(Duration(days: days)).millisecondsSinceEpoch;
    
    final mealMaps = await db.query(
      'meals',
      where: 'consumedAt >= ?',
      whereArgs: [cutoff],
      orderBy: 'consumedAt DESC',
    );

    final meals = <MealRecord>[];
    for (final mealMap in mealMaps) {
      final foodMaps = await db.query(
        'food_items',
        where: 'mealId = ?',
        whereArgs: [mealMap['id']],
      );

      final foods = foodMaps.map((foodMap) => FoodItem(
        name: foodMap['name'] as String,
        confidence: (foodMap['confidence'] as num).toDouble(),
        nutrients: _decodeNutrients(foodMap['nutrients'] as String),
      )).toList();

      meals.add(MealRecord(
        id: mealMap['id'] as String,
        consumedAt: DateTime.fromMillisecondsSinceEpoch(mealMap['consumedAt'] as int),
        foods: foods,
        imagePath: mealMap['imagePath'] as String?,
        recoveryScore: mealMap['recoveryScore'] as int,
        feedbackMessage: mealMap['feedbackMessage'] as String,
      ));
    }

    return meals;
  }

  // ========== PROGRESS TRACKING ==========

  Future<List<ProgressDataPoint>> getProgressHistory({int days = 30}) async {
    if (kIsWeb) {
      // Build progress data from in-memory lists
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));
      final dataPoints = <ProgressDataPoint>[];

      for (int i = 0; i < days; i += 7) {
        final weekStart = startDate.add(Duration(days: i));
        final weekEnd = weekStart.add(const Duration(days: 7));

        final deficiencyMaps = _inMemoryDeficiencies.where((d) => d.detectedAt.isAfter(weekStart) && d.detectedAt.isBefore(weekEnd)).toList();
        final mealMaps = _inMemoryMeals.where((m) => m.consumedAt.isAfter(weekStart) && m.consumedAt.isBefore(weekEnd)).toList();

        double avgRecoveryScore = 0.0;
        if (mealMaps.isNotEmpty) {
          final total = mealMaps.fold<int>(0, (sum, meal) => sum + meal.recoveryScore);
          avgRecoveryScore = total / mealMaps.length;
        }

        final deficiencies = <String, DeficiencySeverity>{};
        for (final d in deficiencyMaps) {
          final nutrient = d.nutrient;
          final severity = d.severity;
          if (!deficiencies.containsKey(nutrient) || severity.index > deficiencies[nutrient]!.index) {
            deficiencies[nutrient] = severity;
          }
        }

        dataPoints.add(ProgressDataPoint(date: weekStart, deficiencies: deficiencies, averageRecoveryScore: avgRecoveryScore));
      }

      return dataPoints;
    }

    final db = await database;
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    
    final dataPoints = <ProgressDataPoint>[];

    // Group by week for better visualization
    for (int i = 0; i < days; i += 7) {
      final weekStart = startDate.add(Duration(days: i));
      final weekEnd = weekStart.add(const Duration(days: 7));

      // Get deficiencies for this week
      final deficiencyMaps = await db.query(
        'deficiencies',
        where: 'detectedAt >= ? AND detectedAt < ?',
        whereArgs: [
          weekStart.millisecondsSinceEpoch,
          weekEnd.millisecondsSinceEpoch,
        ],
      );

      // Get meals for this week
      final mealMaps = await db.query(
        'meals',
        where: 'consumedAt >= ? AND consumedAt < ?',
        whereArgs: [
          weekStart.millisecondsSinceEpoch,
          weekEnd.millisecondsSinceEpoch,
        ],
      );

      // Calculate average recovery score
      double avgRecoveryScore = 0.0;
      if (mealMaps.isNotEmpty) {
        final total = mealMaps.fold<int>(
          0,
          (sum, meal) => sum + (meal['recoveryScore'] as int),
        );
        avgRecoveryScore = total / mealMaps.length;
      }

      // Map deficiencies
      final deficiencies = <String, DeficiencySeverity>{};
      for (final map in deficiencyMaps) {
        final nutrient = map['nutrient'] as String;
        final severity = DeficiencySeverity.values[map['severity'] as int];
        
        // Keep the most severe reading
        if (!deficiencies.containsKey(nutrient) ||
            severity.index > deficiencies[nutrient]!.index) {
          deficiencies[nutrient] = severity;
        }
      }

      dataPoints.add(ProgressDataPoint(
        date: weekStart,
        deficiencies: deficiencies,
        averageRecoveryScore: avgRecoveryScore,
      ));
    }

    return dataPoints;
  }

  // ========== UTILITY METHODS ==========

  String _encodeNutrients(Map<String, double> nutrients) {
    return nutrients.entries.map((e) => '${e.key}:${e.value}').join(';');
  }

  Map<String, double> _decodeNutrients(String encoded) {
    final nutrients = <String, double>{};
    for (final part in encoded.split(';')) {
      final keyValue = part.split(':');
      if (keyValue.length == 2) {
        nutrients[keyValue[0]] = double.tryParse(keyValue[1]) ?? 0.0;
      }
    }
    return nutrients;
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('deficiencies');
    await db.delete('meals');
    await db.delete('food_items');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
