/// Comprehensive Deficiency Knowledge Base
/// Contains causes, effects, fixes, and prevention strategies for each nutrient
library;

class DeficiencyCause {
  final String category; // 'dietary', 'lifestyle', 'medical', 'absorption'
  final String description;
  final String icon;

  const DeficiencyCause({
    required this.category,
    required this.description,
    required this.icon,
  });
}

class DeficiencyEffect {
  final String symptom;
  final String severity; // 'mild', 'moderate', 'severe'
  final String bodyPart;

  const DeficiencyEffect({
    required this.symptom,
    required this.severity,
    required this.bodyPart,
  });
}

class DeficiencyFix {
  final String type; // 'food', 'lifestyle', 'supplement', 'medical'
  final String recommendation;
  final String priority; // 'high', 'medium', 'low'
  final List<String> foodSuggestions;

  const DeficiencyFix({
    required this.type,
    required this.recommendation,
    required this.priority,
    this.foodSuggestions = const [],
  });
}

class DeficiencyKnowledge {
  final String nutrient;
  final String scientificName;
  final String category; // 'vitamin', 'mineral', 'protein'
  final List<DeficiencyCause> causes;
  final List<DeficiencyEffect> effects;
  final List<DeficiencyFix> fixes;
  final List<String> preventionTips;
  final List<String> absorptionBoosters;
  final List<String> absorptionInhibitors;
  final String commonIn; // Demographics most affected
  final String urgencyLevel; // 'urgent', 'moderate', 'low'

  const DeficiencyKnowledge({
    required this.nutrient,
    required this.scientificName,
    required this.category,
    required this.causes,
    required this.effects,
    required this.fixes,
    required this.preventionTips,
    required this.absorptionBoosters,
    required this.absorptionInhibitors,
    required this.commonIn,
    required this.urgencyLevel,
  });
}

/// Complete Knowledge Database
class DeficiencyKnowledgeDatabase {
  static const Map<String, DeficiencyKnowledge> knowledgeBase = {
    'Iron': DeficiencyKnowledge(
      nutrient: 'Iron',
      scientificName: 'Ferrum (Fe)',
      category: 'mineral',
      causes: [
        DeficiencyCause(
          category: 'dietary',
          description: 'Low intake of iron-rich foods (red meat, spinach, lentils)',
          icon: '🍽️',
        ),
        DeficiencyCause(
          category: 'lifestyle',
          description: 'Excessive tea/coffee consumption reduces iron absorption',
          icon: '☕',
        ),
        DeficiencyCause(
          category: 'medical',
          description: 'Blood loss from menstruation or internal bleeding',
          icon: '🩸',
        ),
        DeficiencyCause(
          category: 'absorption',
          description: 'Poor gut absorption due to low stomach acid or vitamin C deficiency',
          icon: '🔬',
        ),
      ],
      effects: [
        DeficiencyEffect(symptom: 'Chronic fatigue and weakness', severity: 'moderate', bodyPart: 'whole_body'),
        DeficiencyEffect(symptom: 'Pale tongue and inner eyelids', severity: 'mild', bodyPart: 'tongue_eyes'),
        DeficiencyEffect(symptom: 'Brittle nails with spoon shape', severity: 'moderate', bodyPart: 'nails'),
        DeficiencyEffect(symptom: 'Shortness of breath', severity: 'severe', bodyPart: 'respiratory'),
        DeficiencyEffect(symptom: 'Dizziness and headaches', severity: 'moderate', bodyPart: 'head'),
      ],
      fixes: [
        DeficiencyFix(
          type: 'food',
          recommendation: 'Eat iron-rich foods daily',
          priority: 'high',
          foodSuggestions: ['Spinach (Palak)', 'Red meat', 'Lentils (Dal)', 'Beetroot', 'Jaggery (Gur)', 'Pomegranate'],
        ),
        DeficiencyFix(
          type: 'lifestyle',
          recommendation: 'Avoid tea/coffee 1 hour before and after meals',
          priority: 'high',
          foodSuggestions: [],
        ),
        DeficiencyFix(
          type: 'food',
          recommendation: 'Combine iron foods with Vitamin C sources',
          priority: 'high',
          foodSuggestions: ['Lemon juice', 'Oranges', 'Tomatoes', 'Bell peppers'],
        ),
        DeficiencyFix(
          type: 'medical',
          recommendation: 'Consider iron supplements if dietary changes insufficient',
          priority: 'medium',
          foodSuggestions: [],
        ),
      ],
      preventionTips: [
        'Include one iron-rich food in every meal',
        'Cook in cast-iron cookware to increase iron content',
        'Pair iron foods with vitamin C for better absorption',
        'Avoid calcium supplements with iron-rich meals',
        'For vegetarians: combine beans, nuts, and fortified cereals',
      ],
      absorptionBoosters: ['Vitamin C', 'Vitamin A', 'Meat protein', 'Folic acid'],
      absorptionInhibitors: ['Tea', 'Coffee', 'Calcium', 'Phytates (in grains)', 'Antacids'],
      commonIn: 'Women (menstruation), Vegetarians, Children, Pregnant women',
      urgencyLevel: 'urgent',
    ),
    
    'Vitamin B12': DeficiencyKnowledge(
      nutrient: 'Vitamin B12',
      scientificName: 'Cobalamin',
      category: 'vitamin',
      causes: [
        DeficiencyCause(
          category: 'dietary',
          description: 'Strict vegan/vegetarian diet with no animal products',
          icon: '🌱',
        ),
        DeficiencyCause(
          category: 'absorption',
          description: 'Poor absorption due to lack of intrinsic factor or gut issues',
          icon: '🔬',
        ),
        DeficiencyCause(
          category: 'medical',
          description: 'Pernicious anemia or gastrointestinal disorders',
          icon: '🩺',
        ),
        DeficiencyCause(
          category: 'lifestyle',
          description: 'Long-term use of antacids or metformin medication',
          icon: '💊',
        ),
      ],
      effects: [
        DeficiencyEffect(symptom: 'Extreme fatigue and weakness', severity: 'severe', bodyPart: 'whole_body'),
        DeficiencyEffect(symptom: 'Tingling in hands and feet (nerve damage)', severity: 'severe', bodyPart: 'nerves'),
        DeficiencyEffect(symptom: 'Memory problems and confusion', severity: 'moderate', bodyPart: 'brain'),
        DeficiencyEffect(symptom: 'Smooth, red tongue', severity: 'mild', bodyPart: 'tongue'),
        DeficiencyEffect(symptom: 'Depression and mood changes', severity: 'moderate', bodyPart: 'mental'),
      ],
      fixes: [
        DeficiencyFix(
          type: 'food',
          recommendation: 'Consume B12-rich animal products daily',
          priority: 'high',
          foodSuggestions: ['Eggs', 'Milk', 'Curd (Dahi)', 'Paneer', 'Fish', 'Chicken', 'Fortified cereals'],
        ),
        DeficiencyFix(
          type: 'supplement',
          recommendation: 'For vegans: B12 supplements or fortified foods essential',
          priority: 'high',
          foodSuggestions: ['Nutritional yeast', 'Fortified soy milk', 'B12 tablets'],
        ),
        DeficiencyFix(
          type: 'medical',
          recommendation: 'If absorption issue: B12 injections may be needed',
          priority: 'medium',
          foodSuggestions: [],
        ),
      ],
      preventionTips: [
        'Vegans must take B12 supplements regularly',
        'Include dairy or eggs at least once daily',
        'Check B12 levels annually if over 50 or vegan',
        'Consider fortified plant milks and cereals',
        'Avoid long-term antacid use without medical supervision',
      ],
      absorptionBoosters: ['Intrinsic factor (from stomach)', 'Healthy gut microbiome'],
      absorptionInhibitors: ['Antacids', 'Metformin', 'H. pylori infection', 'Alcohol'],
      commonIn: 'Vegans, Elderly (50+), People with gut disorders, Long-term PPI users',
      urgencyLevel: 'urgent',
    ),
    
    'Vitamin D': DeficiencyKnowledge(
      nutrient: 'Vitamin D',
      scientificName: 'Calciferol',
      category: 'vitamin',
      causes: [
        DeficiencyCause(
          category: 'lifestyle',
          description: 'Limited sunlight exposure (indoor jobs, pollution, clothing)',
          icon: '☀️',
        ),
        DeficiencyCause(
          category: 'dietary',
          description: 'Low intake of fortified foods and fatty fish',
          icon: '🐟',
        ),
        DeficiencyCause(
          category: 'medical',
          description: 'Kidney or liver disease affecting vitamin D conversion',
          icon: '🩺',
        ),
        DeficiencyCause(
          category: 'absorption',
          description: 'Dark skin reduces UV synthesis; obesity reduces availability',
          icon: '🔬',
        ),
      ],
      effects: [
        DeficiencyEffect(symptom: 'Bone pain and muscle weakness', severity: 'moderate', bodyPart: 'bones_muscles'),
        DeficiencyEffect(symptom: 'Frequent infections and low immunity', severity: 'moderate', bodyPart: 'immune'),
        DeficiencyEffect(symptom: 'Fatigue and mood changes', severity: 'mild', bodyPart: 'mental'),
        DeficiencyEffect(symptom: 'Hair loss', severity: 'mild', bodyPart: 'hair'),
        DeficiencyEffect(symptom: 'In children: rickets, delayed growth', severity: 'severe', bodyPart: 'bones'),
      ],
      fixes: [
        DeficiencyFix(
          type: 'lifestyle',
          recommendation: 'Get 15-20 minutes of morning sunlight daily',
          priority: 'high',
          foodSuggestions: [],
        ),
        DeficiencyFix(
          type: 'food',
          recommendation: 'Include vitamin D fortified foods',
          priority: 'high',
          foodSuggestions: ['Fortified milk', 'Egg yolks', 'Mushrooms (sun-exposed)', 'Fatty fish (salmon, mackerel)'],
        ),
        DeficiencyFix(
          type: 'supplement',
          recommendation: 'Vitamin D3 supplements if deficiency is severe',
          priority: 'medium',
          foodSuggestions: [],
        ),
      ],
      preventionTips: [
        'Expose arms and legs to sunlight 15-20 min daily (before 10 AM or after 4 PM)',
        'Include fortified dairy products regularly',
        'Eat fatty fish twice weekly',
        'Consider supplements in winter or if indoor-bound',
        'Check vitamin D levels annually',
      ],
      absorptionBoosters: ['Healthy fats', 'Magnesium', 'Vitamin K2'],
      absorptionInhibitors: ['Obesity', 'Dark skin pigmentation', 'Pollution blocking UV rays'],
      commonIn: 'Office workers, People in polluted cities, Dark-skinned individuals, Elderly',
      urgencyLevel: 'moderate',
    ),
    
    'Calcium': DeficiencyKnowledge(
      nutrient: 'Calcium',
      scientificName: 'Calcium (Ca)',
      category: 'mineral',
      causes: [
        DeficiencyCause(
          category: 'dietary',
          description: 'Low dairy intake or lactose intolerance',
          icon: '🥛',
        ),
        DeficiencyCause(
          category: 'lifestyle',
          description: 'Sedentary lifestyle and lack of weight-bearing exercise',
          icon: '🏃',
        ),
        DeficiencyCause(
          category: 'medical',
          description: 'Vitamin D deficiency (needed for calcium absorption)',
          icon: '☀️',
        ),
        DeficiencyCause(
          category: 'absorption',
          description: 'High salt, caffeine, or protein intake increases calcium loss',
          icon: '🧂',
        ),
      ],
      effects: [
        DeficiencyEffect(symptom: 'Muscle cramps and spasms', severity: 'moderate', bodyPart: 'muscles'),
        DeficiencyEffect(symptom: 'Brittle nails', severity: 'mild', bodyPart: 'nails'),
        DeficiencyEffect(symptom: 'Numbness and tingling', severity: 'mild', bodyPart: 'nerves'),
        DeficiencyEffect(symptom: 'Weak bones prone to fractures', severity: 'severe', bodyPart: 'bones'),
        DeficiencyEffect(symptom: 'Dental problems', severity: 'moderate', bodyPart: 'teeth'),
      ],
      fixes: [
        DeficiencyFix(
          type: 'food',
          recommendation: 'Consume 2-3 servings of calcium-rich foods daily',
          priority: 'high',
          foodSuggestions: ['Milk', 'Curd', 'Paneer', 'Cheese', 'Ragi (finger millet)', 'Sesame seeds', 'Almonds', 'Tofu'],
        ),
        DeficiencyFix(
          type: 'lifestyle',
          recommendation: 'Regular weight-bearing exercise strengthens bones',
          priority: 'medium',
          foodSuggestions: [],
        ),
        DeficiencyFix(
          type: 'food',
          recommendation: 'Ensure adequate vitamin D for calcium absorption',
          priority: 'high',
          foodSuggestions: ['Sunlight exposure', 'Fortified milk', 'Egg yolks'],
        ),
      ],
      preventionTips: [
        'Include dairy or fortified alternatives 2-3 times daily',
        'Add sesame seeds (til) or ragi to meals',
        'Get regular sunlight for vitamin D',
        'Reduce salt and caffeine intake',
        'Do weight-bearing exercises (walking, jogging, weights)',
      ],
      absorptionBoosters: ['Vitamin D', 'Vitamin K', 'Magnesium', 'Lactose'],
      absorptionInhibitors: ['Excess salt', 'Caffeine', 'High protein', 'Oxalates (spinach)', 'Phytates'],
      commonIn: 'Elderly, Postmenopausal women, Vegans, Lactose intolerant individuals',
      urgencyLevel: 'moderate',
    ),
    
    'Vitamin A': DeficiencyKnowledge(
      nutrient: 'Vitamin A',
      scientificName: 'Retinol',
      category: 'vitamin',
      causes: [
        DeficiencyCause(
          category: 'dietary',
          description: 'Low intake of colorful vegetables and fruits',
          icon: '🥕',
        ),
        DeficiencyCause(
          category: 'absorption',
          description: 'Fat malabsorption or liver disease',
          icon: '🔬',
        ),
        DeficiencyCause(
          category: 'medical',
          description: 'Chronic diarrhea or celiac disease',
          icon: '🩺',
        ),
      ],
      effects: [
        DeficiencyEffect(symptom: 'Night blindness and dry eyes', severity: 'moderate', bodyPart: 'eyes'),
        DeficiencyEffect(symptom: 'Dry, rough skin', severity: 'mild', bodyPart: 'skin'),
        DeficiencyEffect(symptom: 'Frequent infections', severity: 'moderate', bodyPart: 'immune'),
        DeficiencyEffect(symptom: 'Delayed wound healing', severity: 'mild', bodyPart: 'skin'),
      ],
      fixes: [
        DeficiencyFix(
          type: 'food',
          recommendation: 'Eat orange and green vegetables daily',
          priority: 'high',
          foodSuggestions: ['Carrots', 'Sweet potatoes', 'Spinach', 'Pumpkin', 'Mango', 'Papaya', 'Eggs', 'Liver'],
        ),
        DeficiencyFix(
          type: 'food',
          recommendation: 'Consume with healthy fats for absorption',
          priority: 'medium',
          foodSuggestions: ['Add ghee or oil when cooking vegetables'],
        ),
      ],
      preventionTips: [
        'Eat one orange or yellow vegetable daily',
        'Include dark leafy greens regularly',
        'Cook with small amounts of fat for better absorption',
        'Seasonal fruits like mangoes are excellent sources',
      ],
      absorptionBoosters: ['Dietary fats', 'Zinc', 'Protein'],
      absorptionInhibitors: ['Alcohol', 'Iron deficiency', 'Zinc deficiency'],
      commonIn: 'Children in developing countries, People with fat malabsorption',
      urgencyLevel: 'moderate',
    ),
  };

  /// Get knowledge for a specific nutrient
  static DeficiencyKnowledge? getKnowledge(String nutrient) {
    return knowledgeBase[nutrient];
  }

  /// Get all nutrients
  static List<String> getAllNutrients() {
    return knowledgeBase.keys.toList();
  }

  /// Find likely causes based on user profile
  static List<DeficiencyCause> predictCauses(
    String nutrient, {
    bool isVegetarian = false,
    bool isVegan = false,
    int age = 30,
    String lifestyle = 'moderate', // 'sedentary', 'moderate', 'active'
    bool indoorJob = false,
  }) {
    final knowledge = knowledgeBase[nutrient];
    if (knowledge == null) return [];

    List<DeficiencyCause> likelyCauses = [];

    // Smart cause prediction based on profile
    for (var cause in knowledge.causes) {
      bool isLikely = false;

      if (nutrient == 'Vitamin B12' && (isVegan || isVegetarian) && cause.category == 'dietary') {
        isLikely = true;
      }
      if (nutrient == 'Vitamin D' && indoorJob && cause.category == 'lifestyle') {
        isLikely = true;
      }
      if (nutrient == 'Iron' && isVegetarian && cause.description.contains('meat')) {
        isLikely = true;
      }
      if (lifestyle == 'sedentary' && cause.description.contains('exercise')) {
        isLikely = true;
      }

      if (isLikely || cause.category == 'dietary') {
        likelyCauses.add(cause);
      }
    }

    return likelyCauses.isNotEmpty ? likelyCauses : knowledge.causes;
  }
}
