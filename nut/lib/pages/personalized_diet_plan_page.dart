/// Personalized Diet Plan Page
/// Provides weekly meal plans based on user's deficiencies and BMI
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/user_profile.dart';
import '../utils/south_indian_diet_planner.dart';

class PersonalizedDietPlanPage extends StatefulWidget {
  final UserProfile? userProfile;
  final List<String> deficiencies;

  const PersonalizedDietPlanPage({
    super.key,
    this.userProfile,
    required this.deficiencies,
  });

  @override
  State<PersonalizedDietPlanPage> createState() => _PersonalizedDietPlanPageState();
}

class _PersonalizedDietPlanPageState extends State<PersonalizedDietPlanPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedDay = 0;

  final List<String> _days = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _selectedDay = DateTime.now().weekday % 7;
    _tabController.index = _selectedDay;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Animated App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.restaurant_menu, color: Colors.white, size: 40)
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .scale(begin: const Offset(0.5, 0.5)),
                        const SizedBox(height: 12),
                        const Text(
                          'Your Personalized',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideX(begin: -0.2),
                        const Text(
                          '7-Day South Indian Diet Plan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideX(begin: -0.2),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Summary Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange[400]!, Colors.orange[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.info_outline, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Tailored For You',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (widget.userProfile != null) ...[
                      _buildInfoRow(Icons.person, 'BMI: ${widget.userProfile!.bmi.toStringAsFixed(1)} (${widget.userProfile!.bmiCategory})'),
                      const SizedBox(height: 8),
                    ],
                    if (widget.deficiencies.isNotEmpty)
                      _buildInfoRow(Icons.warning_amber, 'Addressing: ${widget.deficiencies.join(", ")}'),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.3),
            ),
          ),
          // Day Tabs
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicator: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[600],
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                unselectedLabelStyle: const TextStyle(fontSize: 14),
                onTap: (index) {
                  setState(() {
                    _selectedDay = index;
                  });
                },
                tabs: _days.map((day) {
                  return Tab(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text(day),
                    ),
                  );
                }).toList(),
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.2),
          ),
          // Meal Plans
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildMealPlan(_days[_selectedDay]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMealPlan(String day) {
    final meals = _getMealsForDay(day);
    
    return Column(
      children: [
        _buildMealCard(
          'Breakfast',
          Icons.wb_sunny_rounded,
          Colors.orange,
          meals['breakfast']!,
          0,
        ),
        const SizedBox(height: 16),
        _buildMealCard(
          'Lunch',
          Icons.lunch_dining_rounded,
          Colors.green,
          meals['lunch']!,
          1,
        ),
        const SizedBox(height: 16),
        _buildMealCard(
          'Dinner',
          Icons.dinner_dining_rounded,
          Colors.indigo,
          meals['dinner']!,
          2,
        ),
        const SizedBox(height: 20),
        // Daily Tips
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[50]!, Colors.purple[50]!],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue[200]!, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  const Text(
                    'Daily Tip',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _getDailyTip(),
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 900.ms).slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildMealCard(String title, IconData icon, Color color, List<String> items, int index) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.8), color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: items.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: Duration(milliseconds: 500 + (index * 100))).slideX(begin: 0.2);
  }

  Map<String, List<String>> _getMealsForDay(String day) {
    // Use South Indian Diet Planner
    final deficiencies = widget.deficiencies.toSet();
    
    // Determine age group based on user profile (default to adult if not available)
    String ageGroup = SouthIndianDietPlanner.ageAdult;
    if (widget.userProfile != null) {
      final age = widget.userProfile!.age;
      if (age <= 12) {
        ageGroup = SouthIndianDietPlanner.ageChild;
      } else if (age <= 19) {
        ageGroup = SouthIndianDietPlanner.ageTeen;
      } else if (age >= 60) {
        ageGroup = SouthIndianDietPlanner.ageSenior;
      }
    }
    
    // Generate 7-day South Indian meal plan
    final weekPlan = SouthIndianDietPlanner.generateWeekPlan(
      ageGroup: ageGroup,
      deficientNutrients: deficiencies,
    );
    
    // Convert the day meals to the expected format
    final dayMeals = weekPlan[day];
    if (dayMeals == null) return {};
    
    Map<String, List<String>> meals = {};
    for (var mealEntry in dayMeals) {
      final mealType = mealEntry['meal']!.toLowerCase();
      final food = mealEntry['food']!;
      final benefits = mealEntry['benefits']!;
      
      if (!meals.containsKey(mealType)) {
        meals[mealType] = [];
      }
      meals[mealType]!.add('$food\n💡 $benefits');
    }
    
    return meals;
  }

  String _getDailyTip() {
    final tips = [
      'Stay hydrated! Drink at least 8-10 glasses of water throughout the day.',
      'Take a 10-minute walk after meals to aid digestion and improve nutrient absorption.',
      'Eat slowly and chew your food thoroughly for better nutrient absorption.',
      'Include a variety of colorful vegetables in your meals for diverse nutrients.',
      'Avoid processed foods and opt for fresh, whole ingredients whenever possible.',
      'Get 7-8 hours of quality sleep to support your body\'s nutritional needs.',
      'Practice portion control - use smaller plates to manage serving sizes.',
    ];
    return tips[_selectedDay % tips.length];
  }
}
