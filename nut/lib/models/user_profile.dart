/// User Profile Data Model
library;

class UserProfile {
  final String name;
  final int age;
  final String gender; // 'Male' or 'Female'
  final double weight; // in kg
  final double height; // in cm
  final double bmi;
  final String bmiCategory; // 'Underweight', 'Normal', 'Overweight', 'Obese'

  UserProfile({
    required this.name,
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.bmiCategory,
  });

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'weight': weight,
      'height': height,
      'bmi': bmi,
      'bmiCategory': bmiCategory,
    };
  }

  // Create from map
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      gender: map['gender'] ?? 'Male',
      weight: (map['weight'] ?? 0.0).toDouble(),
      height: (map['height'] ?? 0.0).toDouble(),
      bmi: (map['bmi'] ?? 0.0).toDouble(),
      bmiCategory: map['bmiCategory'] ?? 'Normal',
    );
  }

  // Get risk factors based on profile
  List<String> getRiskFactors() {
    List<String> risks = [];

    // Age-based risks
    if (age < 18) {
      risks.add('Growing body - higher nutrient needs');
    } else if (age > 50) {
      risks.add('Age-related absorption issues');
    }

    // Gender-based risks
    if (gender == 'Female') {
      if (age >= 12 && age <= 50) {
        risks.add('Menstruation - higher iron needs');
      }
    }

    // BMI-based risks
    if (bmi < 18.5) {
      risks.add('Underweight - malnutrition risk');
    } else if (bmi >= 30) {
      risks.add('Obesity - vitamin D and B12 deficiency risk');
    }

    return risks;
  }

  // Get personalized nutrition recommendations
  String getNutritionAdvice() {
    if (bmi < 18.5) {
      return 'Focus on calorie-dense, nutrient-rich foods. Increase protein intake and consider healthy fats.';
    } else if (bmi < 25) {
      return 'Maintain balanced meals with variety of fruits, vegetables, proteins, and whole grains.';
    } else if (bmi < 30) {
      return 'Focus on portion control and nutrient-dense foods. Reduce processed foods and sugary drinks.';
    } else {
      return 'Consult a healthcare provider. Focus on whole foods, vegetables, and lean proteins while reducing calories.';
    }
  }

  @override
  String toString() {
    return 'UserProfile(name: $name, age: $age, gender: $gender, BMI: ${bmi.toStringAsFixed(1)} - $bmiCategory)';
  }
}
