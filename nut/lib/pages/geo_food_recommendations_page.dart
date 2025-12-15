/// Geo-Based Food Suggestions
/// Region-specific food recommendations based on location
library;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class GeoFoodRecommendationsPage extends StatefulWidget {
  final String? deficiency;
  
  const GeoFoodRecommendationsPage({super.key, this.deficiency});

  @override
  State<GeoFoodRecommendationsPage> createState() => _GeoFoodRecommendationsPageState();
}

class _GeoFoodRecommendationsPageState extends State<GeoFoodRecommendationsPage> {
  String _currentRegion = 'Unknown';
  bool _isLoading = true;
  List<FoodRecommendation> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _detectLocation();
  }

  Future<void> _detectLocation() async {
    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Location permissions denied');
          return;
        }
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      // Get location details
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          _currentRegion = place.administrativeArea ?? place.locality ?? 'India';
          _recommendations = _getRegionalRecommendations(_currentRegion, widget.deficiency);
          _isLoading = false;
        });
      }
    } catch (e) {
      _showError('Error detecting location: $e');
      // Default to generic recommendations
      setState(() {
        _currentRegion = 'India';
        _recommendations = _getRegionalRecommendations('India', widget.deficiency);
        _isLoading = false;
      });
    }
  }

  List<FoodRecommendation> _getRegionalRecommendations(String region, String? deficiency) {
    final recommendations = <FoodRecommendation>[];
    
    // Regional food database
    final regionalFoods = <String, List<FoodRecommendation>>{
      'Tamil Nadu': [
        FoodRecommendation(
          name: 'Murungai Keerai (Drumstick Leaves)',
          nutrient: 'Iron',
          description: 'Rich in iron and commonly available in Tamil Nadu',
          howToEat: 'Make poriyal or add to sambar',
          ironContent: 4.5,
          icon: '🌿',
        ),
        FoodRecommendation(
          name: 'Ragi Mudde',
          nutrient: 'Calcium',
          description: 'Finger millet balls - excellent calcium source',
          howToEat: 'Eat with sambar or rasam',
          calciumContent: 350,
          icon: '🥘',
        ),
        FoodRecommendation(
          name: 'Tamarind Fish Curry',
          nutrient: 'Vitamin B12',
          description: 'Local fish varieties rich in B12',
          howToEat: 'Traditional meen kuzhambu',
          b12Content: 5.0,
          icon: '🐟',
        ),
      ],
      'Kerala': [
        FoodRecommendation(
          name: 'Moringa (Muringakka)',
          nutrient: 'Iron',
          description: 'Drumstick and leaves are iron-rich',
          howToEat: 'Thoran or sambar',
          ironContent: 4.0,
          icon: '🌿',
        ),
        FoodRecommendation(
          name: 'Meen Pollichathu',
          nutrient: 'Vitamin D',
          description: 'Wrapped fish with coconut - rich in Vitamin D',
          howToEat: 'Traditional Kerala fish preparation',
          vitaminDContent: 10.0,
          icon: '🐟',
        ),
        FoodRecommendation(
          name: 'Pazham Pori',
          nutrient: 'Vitamin A',
          description: 'Banana fritters - good source of Vitamin A',
          howToEat: 'Evening snack with tea',
          vitaminAContent: 64,
          icon: '🍌',
        ),
      ],
      'Maharashtra': [
        FoodRecommendation(
          name: 'Nachni Bhakri',
          nutrient: 'Calcium',
          description: 'Ragi flatbread packed with calcium',
          howToEat: 'With curd or vegetables',
          calciumContent: 350,
          icon: '🫓',
        ),
        FoodRecommendation(
          name: 'Zunka Bhakri',
          nutrient: 'Iron',
          description: 'Gram flour dish with greens',
          howToEat: 'Traditional Maharashtrian meal',
          ironContent: 3.5,
          icon: '🥘',
        ),
      ],
      'Gujarat': [
        FoodRecommendation(
          name: 'Methi Thepla',
          nutrient: 'Iron',
          description: 'Fenugreek flatbread - iron-rich',
          howToEat: 'With yogurt or pickle',
          ironContent: 3.0,
          icon: '🫓',
        ),
        FoodRecommendation(
          name: 'Dhokla',
          nutrient: 'Vitamin B12',
          description: 'Fermented gram flour cake',
          howToEat: 'Breakfast or snack',
          b12Content: 1.2,
          icon: '🍰',
        ),
      ],
      'West Bengal': [
        FoodRecommendation(
          name: 'Shukto',
          nutrient: 'Calcium',
          description: 'Mixed vegetable curry with milk',
          howToEat: 'Bengali lunch staple',
          calciumContent: 200,
          icon: '🥘',
        ),
        FoodRecommendation(
          name: 'Macher Jhol',
          nutrient: 'Vitamin D',
          description: 'Fish curry - Vitamin D rich',
          howToEat: 'With rice',
          vitaminDContent: 12.0,
          icon: '🐟',
        ),
      ],
      'Punjab': [
        FoodRecommendation(
          name: 'Sarson Ka Saag',
          nutrient: 'Iron',
          description: 'Mustard greens - super high in iron',
          howToEat: 'With makki di roti and butter',
          ironContent: 5.0,
          icon: '🌿',
        ),
        FoodRecommendation(
          name: 'Paneer Tikka',
          nutrient: 'Calcium',
          description: 'Cottage cheese - calcium powerhouse',
          howToEat: 'Tandoori or curry',
          calciumContent: 200,
          icon: '🧀',
        ),
      ],
    };

    // Get region-specific foods
    final regionalList = regionalFoods[region] ?? [];
    
    // Filter by deficiency if specified
    if (deficiency != null) {
      recommendations.addAll(
        regionalList.where((food) => food.nutrient == deficiency)
      );
    } else {
      recommendations.addAll(regionalList);
    }

    // Add generic Indian foods
    recommendations.addAll([
      FoodRecommendation(
        name: 'Spinach (Palak)',
        nutrient: 'Iron',
        description: 'Available nationwide - iron rich',
        howToEat: 'Palak paneer or dal',
        ironContent: 2.7,
        icon: '🥬',
      ),
      FoodRecommendation(
        name: 'Curd/Yogurt',
        nutrient: 'Calcium',
        description: 'Daily dairy for calcium',
        howToEat: 'Plain or as raita',
        calciumContent: 120,
        icon: '🥛',
      ),
    ]);

    return recommendations;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.orange),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regional Food Guide'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              setState(() => _isLoading = true);
              _detectLocation();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Location card
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.green, size: 40),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your Region',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                _currentRegion,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
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

                if (widget.deficiency != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Foods for ${widget.deficiency} deficiency in your region:',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                // Food recommendations
                ..._recommendations.map((food) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: Text(food.icon, style: const TextStyle(fontSize: 24)),
                        ),
                        title: Text(
                          food.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(food.description),
                            const SizedBox(height: 4),
                            Text(
                              '💡 ${food.howToEat}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade700,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getNutrientInfo(food),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    )),

                const SizedBox(height: 20),

                // Info card
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info, color: Colors.blue),
                            const SizedBox(width: 8),
                            const Text(
                              'Local is Better!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Foods grown in your region are fresher, more affordable, and often better suited to your body. Traditional regional foods have been perfected over centuries!',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  String _getNutrientInfo(FoodRecommendation food) {
    if (food.ironContent != null) {
      return '✅ Iron: ${food.ironContent}mg per 100g';
    } else if (food.calciumContent != null) {
      return '✅ Calcium: ${food.calciumContent}mg per 100g';
    } else if (food.b12Content != null) {
      return '✅ B12: ${food.b12Content}mcg per 100g';
    } else if (food.vitaminDContent != null) {
      return '✅ Vitamin D: ${food.vitaminDContent}mcg per 100g';
    } else if (food.vitaminAContent != null) {
      return '✅ Vitamin A: ${food.vitaminAContent}mcg per 100g';
    }
    return '';
  }
}

class FoodRecommendation {
  final String name;
  final String nutrient;
  final String description;
  final String howToEat;
  final String icon;
  final double? ironContent;
  final double? calciumContent;
  final double? b12Content;
  final double? vitaminDContent;
  final double? vitaminAContent;

  FoodRecommendation({
    required this.name,
    required this.nutrient,
    required this.description,
    required this.howToEat,
    required this.icon,
    this.ironContent,
    this.calciumContent,
    this.b12Content,
    this.vitaminDContent,
    this.vitaminAContent,
  });
}
