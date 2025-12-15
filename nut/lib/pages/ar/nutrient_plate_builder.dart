import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:math' as math;

class NutrientPlateBuilder extends StatefulWidget {
  const NutrientPlateBuilder({Key? key}) : super(key: key);

  @override
  State<NutrientPlateBuilder> createState() => _NutrientPlateBuilderState();
}

class _NutrientPlateBuilderState extends State<NutrientPlateBuilder>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isInitialized = false;
  
  List<PlateItem> _plateItems = [];
  int _totalScore = 0;
  int _maxScore = 1000;
  
  late AnimationController _scoreController;
  
  final List<FoodItem> _availableFoods = [
    FoodItem('Broccoli', Icons.eco, Colors.green, 150, {'Vitamin C': 89, 'Fiber': 5}),
    FoodItem('Chicken', Icons.dinner_dining, Colors.brown, 200, {'Protein': 31, 'B12': 0.3}),
    FoodItem('Rice', Icons.rice_bowl, Colors.amber, 100, {'Carbs': 28, 'Iron': 0.4}),
    FoodItem('Apple', Icons.apple, Colors.red, 80, {'Fiber': 4, 'Vitamin C': 14}),
    FoodItem('Yogurt', Icons.breakfast_dining, Colors.blue, 120, {'Calcium': 150, 'Protein': 10}),
  ];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        
        if (mounted) {
          setState(() => _isInitialized = true);
        }
      }
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  void _addFood(FoodItem food) {
    setState(() {
      _plateItems.add(PlateItem(food, DateTime.now()));
      _calculateScore();
    });
    _scoreController.forward(from: 0);
  }

  void _removeFood(int index) {
    setState(() {
      _plateItems.removeAt(index);
      _calculateScore();
    });
  }

  void _calculateScore() {
    _totalScore = _plateItems.fold(0, (sum, item) => sum + item.food.score);
  }

  String get _scoreGrade {
    final percentage = (_totalScore / _maxScore * 100);
    if (percentage >= 80) return 'Excellent';
    if (percentage >= 60) return 'Good';
    if (percentage >= 40) return 'Fair';
    return 'Needs Improvement';
  }

  Color get _scoreColor {
    final percentage = (_totalScore / _maxScore * 100);
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.lightGreen;
    if (percentage >= 40) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Nutrient Plate Builder'),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          // Camera preview
          if (_isInitialized && _cameraController != null)
            SizedBox.expand(
              child: CameraPreview(_cameraController!),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          
          // Virtual plate
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.9),
                border: Border.all(color: _scoreColor, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: _scoreColor.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Plate items
                  ..._plateItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final angle = (index * 360 / _plateItems.length) * 3.14159 / 180;
                    final radius = 80.0;
                    
                    return Positioned(
                      left: 140 + radius * math.cos(angle) - 25,
                      top: 140 + radius * math.sin(angle) - 25,
                      child: GestureDetector(
                        onTap: () => _removeFood(index),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 400),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: item.food.color,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  item.food.icon,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }).toList(),
                  
                  // Center score
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _scoreController,
                          builder: (context, child) {
                            return Text(
                              '${(_totalScore * _scoreController.value).toInt()}',
                              style: TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: _scoreColor,
                              ),
                            );
                          },
                        ),
                        Text(
                          _scoreGrade,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _scoreColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Food selector
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: _availableFoods.length,
                itemBuilder: (context, index) {
                  final food = _availableFoods[index];
                  return GestureDetector(
                    onTap: () => _addFood(food),
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      decoration: BoxDecoration(
                        color: food.color,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(food.icon, color: Colors.white, size: 30),
                          const SizedBox(height: 4),
                          Text(
                            food.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Progress bar
          Positioned(
            top: 100,
            left: 40,
            right: 40,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: (_totalScore / _maxScore).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_scoreColor, _scoreColor.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      '$_totalScore / $_maxScore points',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
}

class FoodItem {
  final String name;
  final IconData icon;
  final Color color;
  final int score;
  final Map<String, num> nutrients;

  FoodItem(this.name, this.icon, this.color, this.score, this.nutrients);
}

class PlateItem {
  final FoodItem food;
  final DateTime addedAt;

  PlateItem(this.food, this.addedAt);
}
