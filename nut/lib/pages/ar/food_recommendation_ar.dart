import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class FoodRecommendationAR extends StatefulWidget {
  final List<String> deficiencies;
  
  const FoodRecommendationAR({
    Key? key,
    this.deficiencies = const [],
  }) : super(key: key);

  @override
  State<FoodRecommendationAR> createState() => _FoodRecommendationARState();
}

class _FoodRecommendationARState extends State<FoodRecommendationAR> {
  CameraController? _cameraController;
  bool _isInitialized = false;
  int _selectedFoodIndex = 0;
  
  late List<FoodRecommendation> _recommendations;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadRecommendations();
  }

  void _loadRecommendations() {
    _recommendations = [
      FoodRecommendation(
        'Spinach',
        'Rich in iron and vitamins',
        '🥬',
        Colors.green,
        ['Iron: 2.7mg', 'Vitamin K: 145mcg', 'Folate: 58mcg'],
      ),
      FoodRecommendation(
        'Salmon',
        'High in Omega-3 and Vitamin D',
        '🐟',
        Colors.orange,
        ['Vitamin D: 570 IU', 'Omega-3: 2.3g', 'Protein: 25g'],
      ),
      FoodRecommendation(
        'Almonds',
        'Calcium and protein source',
        '🌰',
        Colors.brown,
        ['Calcium: 76mg', 'Protein: 6g', 'Vitamin E: 7.3mg'],
      ),
      FoodRecommendation(
        'Eggs',
        'Complete protein with B12',
        '🥚',
        Colors.amber,
        ['Protein: 6g', 'B12: 0.6mcg', 'Vitamin D: 41 IU'],
      ),
      FoodRecommendation(
        'Milk',
        'Calcium and fortified vitamins',
        '🥛',
        Colors.blue,
        ['Calcium: 300mg', 'Vitamin D: 124 IU', 'Protein: 8g'],
      ),
    ];
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

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentFood = _recommendations[_selectedFoodIndex];
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('AR Food Recommendations'),
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
          
          // 3D Food Model Placeholder (using emoji as 3D model)
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentFood.color.withOpacity(0.3),
                      border: Border.all(
                        color: currentFood.color,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: currentFood.color.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        currentFood.icon,
                        style: const TextStyle(fontSize: 100),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Food info card
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    currentFood.color.withOpacity(0.9),
                    currentFood.color.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        currentFood.icon,
                        style: const TextStyle(fontSize: 40),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentFood.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              currentFood.description,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nutritional Benefits:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...currentFood.nutrients.map((nutrient) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          nutrient,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
              ),
            ),
          ),
          
          // Navigation arrows
          Positioned(
            left: 20,
            top: MediaQuery.of(context).size.height / 2 - 30,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 40),
              onPressed: () {
                setState(() {
                  _selectedFoodIndex = (_selectedFoodIndex - 1) % _recommendations.length;
                });
              },
            ),
          ),
          Positioned(
            right: 20,
            top: MediaQuery.of(context).size.height / 2 - 30,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 40),
              onPressed: () {
                setState(() {
                  _selectedFoodIndex = (_selectedFoodIndex + 1) % _recommendations.length;
                });
              },
            ),
          ),
          
          // Food counter
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_selectedFoodIndex + 1}/${_recommendations.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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

class FoodRecommendation {
  final String name;
  final String description;
  final String icon;
  final Color color;
  final List<String> nutrients;

  FoodRecommendation(this.name, this.description, this.icon, this.color, this.nutrients);
}
