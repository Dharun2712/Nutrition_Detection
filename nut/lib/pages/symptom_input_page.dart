/// Symptom Input Page for Multimodal Diagnosis
/// Combines user-reported symptoms with image analysis for stronger accuracy
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SymptomData {
  final List<String> selectedSymptoms;
  final String lifestyleActivity; // 'sedentary', 'moderate', 'active'
  final int sunlightMinutes;
  final String dietType; // 'vegan', 'vegetarian', 'non-veg', 'mixed'
  final int sleepHours;
  final bool indoorJob;
  final List<String> recentDiet; // Foods consumed in last 24h

  SymptomData({
    required this.selectedSymptoms,
    required this.lifestyleActivity,
    required this.sunlightMinutes,
    required this.dietType,
    required this.sleepHours,
    required this.indoorJob,
    required this.recentDiet,
  });

  Map<String, dynamic> toJson() {
    return {
      'selectedSymptoms': selectedSymptoms,
      'lifestyleActivity': lifestyleActivity,
      'sunlightMinutes': sunlightMinutes,
      'dietType': dietType,
      'sleepHours': sleepHours,
      'indoorJob': indoorJob,
      'recentDiet': recentDiet,
    };
  }

  factory SymptomData.fromJson(Map<String, dynamic> json) {
    return SymptomData(
      selectedSymptoms: List<String>.from(json['selectedSymptoms'] ?? []),
      lifestyleActivity: json['lifestyleActivity'] ?? 'moderate',
      sunlightMinutes: json['sunlightMinutes'] ?? 15,
      dietType: json['dietType'] ?? 'mixed',
      sleepHours: json['sleepHours'] ?? 7,
      indoorJob: json['indoorJob'] ?? false,
      recentDiet: List<String>.from(json['recentDiet'] ?? []),
    );
  }
}

class SymptomInputPage extends StatefulWidget {
  const SymptomInputPage({super.key});

  @override
  State<SymptomInputPage> createState() => _SymptomInputPageState();
}

class _SymptomInputPageState extends State<SymptomInputPage> {
  // Symptom categories and options
  final Map<String, List<String>> symptomCategories = {
    'Energy & Mood': [
      'Chronic fatigue',
      'Weakness',
      'Dizziness',
      'Depression',
      'Mood swings',
      'Brain fog',
    ],
    'Skin & Hair': [
      'Dry skin',
      'Acne',
      'Hair loss',
      'Slow wound healing',
      'Pale skin',
      'Dark circles',
    ],
    'Nails & Lips': [
      'Brittle nails',
      'Spoon-shaped nails',
      'Cracked lips',
      'Mouth sores',
      'Pale nails',
    ],
    'Eyes': [
      'Dry eyes',
      'Night blindness',
      'Pale inner eyelids',
      'Blurred vision',
    ],
    'Bones & Muscles': [
      'Bone pain',
      'Muscle cramps',
      'Muscle weakness',
      'Joint pain',
      'Numbness/tingling',
    ],
    'Digestive': [
      'Frequent infections',
      'Loss of appetite',
      'Constipation',
      'Diarrhea',
    ],
  };

  final Set<String> _selectedSymptoms = {};
  String _lifestyleActivity = 'moderate';
  double _sunlightMinutes = 15;
  String _dietType = 'mixed';
  double _sleepHours = 7;
  bool _indoorJob = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString('symptom_data');
      if (savedJson != null) {
        final data = SymptomData.fromJson(jsonDecode(savedJson));
        setState(() {
          _selectedSymptoms.addAll(data.selectedSymptoms);
          _lifestyleActivity = data.lifestyleActivity;
          _sunlightMinutes = data.sunlightMinutes.toDouble();
          _dietType = data.dietType;
          _sleepHours = data.sleepHours.toDouble();
          _indoorJob = data.indoorJob;
        });
      }
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> _saveAndContinue() async {
    final data = SymptomData(
      selectedSymptoms: _selectedSymptoms.toList(),
      lifestyleActivity: _lifestyleActivity,
      sunlightMinutes: _sunlightMinutes.toInt(),
      dietType: _dietType,
      sleepHours: _sleepHours.toInt(),
      indoorJob: _indoorJob,
      recentDiet: [],
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('symptom_data', jsonEncode(data.toJson()));
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Symptom data saved! This will improve diagnosis accuracy.'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context, data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Symptom & Lifestyle Input'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal, Colors.teal.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.assignment_outlined, color: Colors.white, size: 40),
                  SizedBox(height: 12),
                  Text(
                    'Help Us Understand Better',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Combining symptoms with image analysis improves diagnosis accuracy by up to 40%',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Symptom Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🩺 Select Your Symptoms',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_selectedSymptoms.length} selected',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...symptomCategories.entries.map((category) {
                    return _buildSymptomCategory(
                      category.key,
                      category.value,
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Lifestyle Factors
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🏃 Lifestyle Factors',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Diet Type
                  _buildOptionCard(
                    'Diet Type',
                    Icons.restaurant_menu,
                    Colors.orange,
                    DropdownButton<String>(
                      value: _dietType,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'vegan', child: Text('Vegan')),
                        DropdownMenuItem(value: 'vegetarian', child: Text('Vegetarian')),
                        DropdownMenuItem(value: 'non-veg', child: Text('Non-Vegetarian')),
                        DropdownMenuItem(value: 'mixed', child: Text('Mixed/Balanced')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _dietType = value!;
                        });
                      },
                    ),
                  ),

                  // Activity Level
                  _buildOptionCard(
                    'Activity Level',
                    Icons.directions_run,
                    Colors.blue,
                    DropdownButton<String>(
                      value: _lifestyleActivity,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'sedentary', child: Text('Sedentary (desk job, minimal movement)')),
                        DropdownMenuItem(value: 'moderate', child: Text('Moderate (some walking, light exercise)')),
                        DropdownMenuItem(value: 'active', child: Text('Active (regular exercise, physical work)')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _lifestyleActivity = value!;
                        });
                      },
                    ),
                  ),

                  // Sunlight Exposure
                  _buildSliderCard(
                    'Daily Sunlight Exposure',
                    Icons.wb_sunny,
                    Colors.amber,
                    _sunlightMinutes,
                    0,
                    120,
                    '${_sunlightMinutes.toInt()} minutes/day',
                    (value) {
                      setState(() {
                        _sunlightMinutes = value;
                      });
                    },
                  ),

                  // Sleep Hours
                  _buildSliderCard(
                    'Sleep Duration',
                    Icons.bedtime,
                    Colors.indigo,
                    _sleepHours,
                    4,
                    12,
                    '${_sleepHours.toInt()} hours/night',
                    (value) {
                      setState(() {
                        _sleepHours = value;
                      });
                    },
                  ),

                  // Indoor Job
                  _buildSwitchCard(
                    'Indoor Job/Work from Home',
                    Icons.home_work,
                    Colors.purple,
                    _indoorJob,
                    (value) {
                      setState(() {
                        _indoorJob = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Save Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAndContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle),
                      SizedBox(width: 12),
                      Text(
                        'Save & Continue to Image Analysis',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomCategory(String category, List<String> symptoms) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          category,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        children: symptoms.map((symptom) {
          final isSelected = _selectedSymptoms.contains(symptom);
          return CheckboxListTile(
            title: Text(
              symptom,
              style: const TextStyle(fontSize: 13),
            ),
            value: isSelected,
            activeColor: Colors.teal,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedSymptoms.add(symptom);
                } else {
                  _selectedSymptoms.remove(symptom);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOptionCard(String title, IconData icon, Color color, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildSliderCard(
    String title,
    IconData icon,
    Color color,
    double value,
    double min,
    double max,
    String label,
    Function(double) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            activeColor: color,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchCard(
    String title,
    IconData icon,
    Color color,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Switch(
            value: value,
            activeColor: color,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
