/// User Profile Page - Collect user information for personalized analysis
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../models/user_profile.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  
  String _selectedGender = 'Male';
  double? _calculatedBMI;
  String _bmiCategory = '';
  Color _bmiColor = Colors.grey;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _calculateBMI() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);

    if (weight != null && height != null && height > 0) {
      setState(() {
        // BMI = weight (kg) / (height (m))^2
        final heightInMeters = height / 100;
        _calculatedBMI = weight / (heightInMeters * heightInMeters);
        
        // Categorize BMI
        if (_calculatedBMI! < 18.5) {
          _bmiCategory = 'Underweight';
          _bmiColor = Colors.blue;
        } else if (_calculatedBMI! < 25) {
          _bmiCategory = 'Normal';
          _bmiColor = Colors.green;
        } else if (_calculatedBMI! < 30) {
          _bmiCategory = 'Overweight';
          _bmiColor = Colors.orange;
        } else {
          _bmiCategory = 'Obese';
          _bmiColor = Colors.red;
        }
      });
    }
  }

  void _proceedToAnalysis() {
    if (_formKey.currentState!.validate()) {
      if (_calculatedBMI == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please calculate your BMI first'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Create user profile
      final userProfile = UserProfile(
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        bmi: _calculatedBMI!,
        bmiCategory: _bmiCategory,
      );

      // Navigate to image upload page with user profile
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ImageUploadPage(userProfile: userProfile),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF667eea),
              const Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  const SizedBox(height: 20),
                  const Icon(
                    Icons.person_add_rounded,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your Health Profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Help us personalize your nutrition analysis',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Form Container
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Name Field
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: const Icon(Icons.person, color: Color(0xFF667eea)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Age Field
                        TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          decoration: InputDecoration(
                            labelText: 'Age (years)',
                            prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF667eea)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your age';
                            }
                            final age = int.tryParse(value);
                            if (age == null || age < 1 || age > 120) {
                              return 'Please enter a valid age';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Gender Radio Buttons
                        const Text(
                          'Gender',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Male'),
                                value: 'Male',
                                groupValue: _selectedGender,
                                activeColor: const Color(0xFF667eea),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedGender = value!;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Female'),
                                value: 'Female',
                                groupValue: _selectedGender,
                                activeColor: const Color(0xFF667eea),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedGender = value!;
                                  });
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Weight Field
                        TextFormField(
                          controller: _weightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Weight (kg)',
                            prefixIcon: const Icon(Icons.monitor_weight, color: Color(0xFF667eea)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
                            ),
                          ),
                          onChanged: (value) => _calculateBMI(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your weight';
                            }
                            final weight = double.tryParse(value);
                            if (weight == null || weight <= 0 || weight > 500) {
                              return 'Please enter a valid weight';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Height Field
                        TextFormField(
                          controller: _heightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Height (cm)',
                            prefixIcon: const Icon(Icons.height, color: Color(0xFF667eea)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
                            ),
                          ),
                          onChanged: (value) => _calculateBMI(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your height';
                            }
                            final height = double.tryParse(value);
                            if (height == null || height <= 0 || height > 300) {
                              return 'Please enter a valid height';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),

                        // BMI Display
                        if (_calculatedBMI != null)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [_bmiColor.withOpacity(0.7), _bmiColor],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: _bmiColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Your BMI',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _calculatedBMI!.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _bmiCategory,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: _bmiColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _getBMIAdvice(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 30),

                        // Proceed Button
                        ElevatedButton(
                          onPressed: _proceedToAnalysis,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667eea),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Continue to Analysis',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getBMIAdvice() {
    if (_calculatedBMI == null) return '';
    
    if (_calculatedBMI! < 18.5) {
      return 'You may be underweight. Focus on nutrient-dense foods and consider consulting a nutritionist.';
    } else if (_calculatedBMI! < 25) {
      return 'Your BMI is in the healthy range. Maintain your current lifestyle!';
    } else if (_calculatedBMI! < 30) {
      return 'You may be overweight. Consider balanced diet and regular exercise.';
    } else {
      return 'Your BMI indicates obesity. Consult a healthcare provider for personalized guidance.';
    }
  }
}
