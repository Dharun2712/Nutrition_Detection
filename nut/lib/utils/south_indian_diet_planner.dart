/// South Indian Diet Planner
/// Generates personalized 7-day meal plans based on age group and deficiencies
library;

class SouthIndianDietPlanner {
  // Age group categories
  static const String ageChild = '0-12 years (Child)';
  static const String ageTeen = '13-19 years (Teen)';
  static const String ageAdult = '20-59 years (Adult)';
  static const String ageSenior = '60+ years (Senior)';
  
  /// Generate a 7-day South Indian meal plan based on age and deficiencies
  static Map<String, List<Map<String, String>>> generateWeekPlan({
    required String ageGroup,
    required Set<String> deficientNutrients,
  }) {
    // Determine if specific nutrients are deficient
    final hasIron = deficientNutrients.any((n) => 
        n.toLowerCase().contains('iron') || n.toLowerCase().contains('hemoglobin'));
    final hasVitaminD = deficientNutrients.any((n) => 
        n.toLowerCase().contains('vitamin d') || n.toLowerCase().contains('vitd'));
    final hasCalcium = deficientNutrients.any((n) => 
        n.toLowerCase().contains('calcium'));
    final hasProtein = deficientNutrients.any((n) => 
        n.toLowerCase().contains('protein'));
    final hasVitaminB12 = deficientNutrients.any((n) => 
        n.toLowerCase().contains('b12') || n.toLowerCase().contains('vitamin b'));

    // Generate meals for each day
    Map<String, List<Map<String, String>>> weekPlan = {};
    
    for (int day = 1; day <= 7; day++) {
      final dayName = _getDayName(day);
      weekPlan[dayName] = _generateDayMeals(
        day: day,
        ageGroup: ageGroup,
        hasIron: hasIron,
        hasVitaminD: hasVitaminD,
        hasCalcium: hasCalcium,
        hasProtein: hasProtein,
        hasVitaminB12: hasVitaminB12,
      );
    }
    
    return weekPlan;
  }
  
  static String _getDayName(int day) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[(day - 1) % 7];
  }
  
  static List<Map<String, String>> _generateDayMeals({
    required int day,
    required String ageGroup,
    required bool hasIron,
    required bool hasVitaminD,
    required bool hasCalcium,
    required bool hasProtein,
    required bool hasVitaminB12,
  }) {
    // Different meal patterns based on day
    switch (day) {
      case 1: // Monday
        return [
          {
            'meal': 'Breakfast',
            'food': hasProtein 
                ? 'Idli (3-4 pcs) with Sambar and Coconut Chutney'
                : 'Plain Idli with Light Sambar',
            'benefits': hasProtein 
                ? 'Fermented rice cakes rich in protein and probiotics' 
                : 'Easy to digest, low calorie breakfast',
          },
          {
            'meal': 'Mid-Morning Snack',
            'food': hasVitaminD 
                ? 'Banana with Sesame Seeds Laddu' 
                : 'Fresh Seasonal Fruit',
            'benefits': hasVitaminD 
                ? 'Sesame seeds boost Vitamin D and calcium' 
                : 'Natural vitamins and fiber',
          },
          {
            'meal': 'Lunch',
            'food': hasIron 
                ? 'Spinach Dal, Brown Rice, Drumstick Sambar, Curd'
                : 'Mixed Vegetable Sambar, White Rice, Rasam, Curd',
            'benefits': hasIron 
                ? 'Spinach and drumstick are excellent iron sources' 
                : 'Balanced South Indian thali for energy',
          },
          {
            'meal': 'Evening Snack',
            'food': ageGroup == ageChild || ageGroup == ageTeen
                ? 'Ragi Malt with Jaggery'
                : 'Steamed Sundal (Chickpea Salad)',
            'benefits': ageGroup == ageChild || ageGroup == ageTeen
                ? 'Ragi is high in calcium and iron for growing kids'
                : 'High protein snack, low in calories',
          },
          {
            'meal': 'Dinner',
            'food': hasCalcium 
                ? 'Ragi Dosa with Milagu (Pepper) Rasam, Curd Rice'
                : 'Wheat Dosa with Mixed Vegetable Curry',
            'benefits': hasCalcium 
                ? 'Ragi is a calcium powerhouse'  : 'Light dinner for easy digestion',
          },
        ];
        
      case 2: // Tuesday
        return [
          {
            'meal': 'Breakfast',
            'food': hasIron 
                ? 'Pongal with Ghee, Vada, Coconut Chutney'
                : 'Upma with Vegetables and Coconut Chutney',
            'benefits': hasIron 
                ? 'Ghee enhances iron absorption'
                : 'Semolina is rich in B vitamins',
          },
          {
            'meal': 'Mid-Morning Snack',
            'food': 'Buttermilk (Moru) with Curry Leaves',
            'benefits': 'Cooling probiotic drink, aids digestion',
          },
          {
            'meal': 'Lunch',
            'food': hasProtein 
                ? 'Moong Dal Curry, Parboiled Rice, Beetroot Poriyal, Rasam'
                : 'Mixed Dal, Rice, Cabbage Poriyal, Rasam',
            'benefits': hasProtein 
                ? 'Moong dal is easily digestible protein'
                : 'Balanced meal with fiber',
          },
          {
            'meal': 'Evening Snack',
            'food': hasVitaminB12 
                ? 'Paneer Pakora with Mint Chutney'
                : 'Murukku (Rice Crackers) with Tea',
            'benefits': hasVitaminB12 
                ? 'Paneer is rich in Vitamin B12'
                : 'Traditional South Indian snack',
          },
          {
            'meal': 'Dinner',
            'food': ageGroup == ageSenior 
                ? 'Soft Idli with Milagu Rasam (Pepper Soup)'
                : 'Pesarattu (Green Gram Dosa) with Ginger Chutney',
            'benefits': ageGroup == ageSenior 
                ? 'Easy to digest for seniors'
                : 'High protein green gram dosa',
          },
        ];
        
      case 3: // Wednesday
        return [
          {
            'meal': 'Breakfast',
            'food': hasCalcium 
                ? 'Ragi Porridge with Jaggery and Milk'
                : 'Appam with Vegetable Stew',
            'benefits': hasCalcium 
                ? 'Ragi + milk = calcium boost'
                : 'Fermented rice pancakes with coconut milk',
          },
          {
            'meal': 'Mid-Morning Snack',
            'food': 'Fresh Pomegranate or Orange',
            'benefits': 'Vitamin C helps iron absorption',
          },
          {
            'meal': 'Lunch',
            'food': hasVitaminD 
                ? 'Mushroom Curry, Jeera Rice, Tomato Rasam, Curd'
                : 'Mixed Vegetable Kootu, White Rice, Rasam',
            'benefits': hasVitaminD 
                ? 'Mushrooms are a plant-based Vitamin D source'
                : 'Kootu is a protein-rich lentil dish',
          },
          {
            'meal': 'Evening Snack',
            'food': ageGroup == ageChild 
                ? 'Banana Dosa with Honey'
                : 'Roasted Groundnuts with Chaat Masala',
            'benefits': ageGroup == ageChild 
                ? 'Kid-friendly, naturally sweet'
                : 'Protein-rich, crunchy snack',
          },
          {
            'meal': 'Dinner',
            'food': hasIron 
                ? 'Methi (Fenugreek) Paratha, Drumstick Curry, Curd'
                : 'Wheat Roti, Mixed Vegetable Curry',
            'benefits': hasIron 
                ? 'Fenugreek and drumstick are iron-rich'
                : 'Whole wheat fiber and vegetables',
          },
        ];
        
      case 4: // Thursday
        return [
          {
            'meal': 'Breakfast',
            'food': hasProtein 
                ? 'Masala Dosa with Sambar and Chutney'
                : 'Rava Dosa with Coconut Chutney',
            'benefits': hasProtein 
                ? 'Potato filling adds protein and carbs'
                : 'Light and crispy semolina dosa',
          },
          {
            'meal': 'Mid-Morning Snack',
            'food': 'Fresh Tender Coconut Water',
            'benefits': 'Hydration and natural electrolytes',
          },
          {
            'meal': 'Lunch',
            'food': hasCalcium 
                ? 'Mor Kuzhambu (Buttermilk Curry), Rice, Paruppu Podi'
                : 'Vegetable Kurma, Pulao Rice, Raita',
            'benefits': hasCalcium 
                ? 'Buttermilk curry is calcium-rich'
                : 'Aromatic rice with mild spices',
          },
          {
            'meal': 'Evening Snack',
            'food': ageGroup == ageTeen 
                ? 'Egg Dosa (if non-veg) or Sweet Paniyaram'
                : 'Masala Vada with Coconut Chutney',
            'benefits': ageGroup == ageTeen 
                ? 'Protein-packed for growing teens'
                : 'Lentil fritters with protein',
          },
          {
            'meal': 'Dinner',
            'food': hasVitaminB12 
                ? 'Curd Rice with Pickle and Papad'
                : 'Lemon Rice with Roasted Cashews',
            'benefits': hasVitaminB12 
                ? 'Fermented curd has B12'
                : 'Tangy rice, easy on stomach',
          },
        ];
        
      case 5: // Friday
        return [
          {
            'meal': 'Breakfast',
            'food': hasVitaminD 
                ? 'Paneer Uthappam with Tomato Chutney'
                : 'Oats Idli with Sambar',
            'benefits': hasVitaminD 
                ? 'Paneer provides Vitamin D and protein'
                : 'Fiber-rich oats in South Indian style',
          },
          {
            'meal': 'Mid-Morning Snack',
            'food': 'Dates and Almonds (3-4 pieces)',
            'benefits': 'Natural energy, iron, and healthy fats',
          },
          {
            'meal': 'Lunch',
            'food': hasProtein 
                ? 'Chana Masala, Chapati, Vegetable Salad, Buttermilk'
                : 'Mixed Vegetable Sambar, Rice, Avial',
            'benefits': hasProtein 
                ? 'Chickpeas are protein powerhouses'
                : 'Kerala-style avial with coconut',
          },
          {
            'meal': 'Evening Snack',
            'food': ageGroup == ageSenior 
                ? 'Soft Banana with Honey'
                : 'Medu Vada with Sambhar',
            'benefits': ageGroup == ageSenior 
                ? 'Easy to chew, natural sugars'
                : 'Crispy lentil donuts',
          },
          {
            'meal': 'Dinner',
            'food': hasIron 
                ? 'Spinach Kootu, Brown Rice, Beetroot Pachadi'
                : 'Tomato Rice with Cucumber Raita',
            'benefits': hasIron 
                ? 'Double iron boost from spinach and beetroot'
                : 'One-pot meal, light on digestion',
          },
        ];
        
      case 6: // Saturday
        return [
          {
            'meal': 'Breakfast',
            'food': hasCalcium 
                ? 'Ragi Idli with Peanut Chutney'
                : 'Semolina Upma with Vegetables',
            'benefits': hasCalcium 
                ? 'Ragi and peanuts both have calcium'
                : 'Quick, nutritious breakfast',
          },
          {
            'meal': 'Mid-Morning Snack',
            'food': 'Guava or Papaya Slices',
            'benefits': 'High in Vitamin C and fiber',
          },
          {
            'meal': 'Lunch',
            'food': hasVitaminB12 
                ? 'Paneer Butter Masala, Roti, Curd'
                : 'Bisi Bele Bath (Mixed Lentil Rice)',
            'benefits': hasVitaminB12 
                ? 'Paneer and curd provide B12'
                : 'Karnataka specialty, complete meal',
          },
          {
            'meal': 'Evening Snack',
            'food': ageGroup == ageChild 
                ? 'Sweet Kesari (Rava Halwa) small portion'
                : 'Masala Tea with Rusks',
            'benefits': ageGroup == ageChild 
                ? 'Traditional sweet, kid favorite'
                : 'Warm beverage with light snack',
          },
          {
            'meal': 'Dinner',
            'food': hasProtein 
                ? 'Mixed Dal Tadka, Roti, Vegetable Salad'
                : 'Tamarind Rice with Roasted Papad',
            'benefits': hasProtein 
                ? 'Multi-lentil protein mix'
                : 'Tangy rice with crunch',
          },
        ];
        
      case 7: // Sunday
        return [
          {
            'meal': 'Breakfast',
            'food': hasIron 
                ? 'Adai (Mixed Lentil Pancake) with Jaggery'
                : 'Set Dosa with Coconut Chutney',
            'benefits': hasIron 
                ? 'Multiple lentils boost iron'
                : 'Soft, fluffy mini dosas',
          },
          {
            'meal': 'Mid-Morning Snack',
            'food': 'Fresh Sugarcane Juice or Watermelon',
            'benefits': 'Hydrating and refreshing',
          },
          {
            'meal': 'Lunch',
            'food': hasCalcium 
                ? 'Palak Paneer, Chapati, Jeera Rice, Curd'
                : 'Vegetable Pulao, Raita, Papad',
            'benefits': hasCalcium 
                ? 'Spinach + paneer = calcium combo'
                : 'Aromatic rice with yogurt',
          },
          {
            'meal': 'Evening Snack',
            'food': ageGroup == ageTeen || ageGroup == ageAdult
                ? 'Mysore Bonda with Coconut Chutney'
                : 'Banana Chips with Buttermilk',
            'benefits': ageGroup == ageTeen || ageGroup == ageAdult
                ? 'Energy-dense snack'
                : 'Traditional Kerala snack',
          },
          {
            'meal': 'Dinner',
            'food': hasVitaminD 
                ? 'Mushroom Biryani (small portion), Raita'
                : 'Curd Rice with Mango Pickle',
            'benefits': hasVitaminD 
                ? 'Mushrooms + ghee for Vitamin D'
                : 'Comfort food, probiotic-rich',
          },
        ];
        
      default:
        return [];
    }
  }
  
  /// Get age-specific nutritional advice
  static String getAgeSpecificAdvice(String ageGroup) {
    switch (ageGroup) {
      case ageChild:
        return 'Children need calcium and iron for growth. Focus on ragi, milk products, and leafy greens. Avoid excessive spices.';
      case ageTeen:
        return 'Teens need protein and iron for development. Include dal, paneer, eggs (if non-veg), and green vegetables daily.';
      case ageAdult:
        return 'Adults should maintain balanced nutrition with whole grains, vegetables, and moderate portions. Stay hydrated.';
      case ageSenior:
        return 'Seniors need easy-to-digest foods with calcium and Vitamin D. Focus on soft idlis, rasam, buttermilk, and cooked vegetables.';
      default:
        return 'Follow a balanced South Indian diet with variety.';
    }
  }
}
