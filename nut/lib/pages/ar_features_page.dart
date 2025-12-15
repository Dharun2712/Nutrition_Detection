/// AR Features Page - Innovative Augmented Reality Health Features
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'ar/ar_health_capture_coach.dart';
import 'ar/diagnostic_heatmap.dart';
import 'ar/deficiency_simulation.dart';
import 'ar/food_recommendation_ar.dart';
import 'ar/nutrient_plate_builder.dart';
import 'ar/progress_timeline_ar.dart';
import 'ar/skin_tone_normalizer.dart';
import 'ar/hydration_estimator.dart';
import 'ar/voice_interactive_doctor.dart';
import 'ar/prescription_planner.dart';
import 'ar_food_analyzer_page.dart';

class ARFeaturesPage extends StatefulWidget {
  const ARFeaturesPage({super.key});

  @override
  State<ARFeaturesPage> createState() => _ARFeaturesPageState();
}

class _ARFeaturesPageState extends State<ARFeaturesPage> {
  int? _expandedIndex;

  final List<ARFeature> _features = [
    ARFeature(
      title: '🧠 AR Food Analyzer',
      subtitle: 'Groq AI-Powered Nutrition Vision',
      icon: Icons.restaurant_rounded,
      color: const Color(0xFF00d2ff),
      description: 'Point your camera at any meal and get instant AI-powered nutrition analysis with AR overlays. Features live scanning mode, portion estimation, health scoring, and immersive VR nutrition lab.',
      features: [
        'Groq Vision AI food recognition',
        'AR portion estimation with depth sensing',
        'Real-time floating nutrition tags',
        'Live scan & capture modes',
        'AI health scoring (0-100)',
        'Macro & micronutrient breakdown',
        'Optional VR immersive mode',
      ],
      page: const ARFoodAnalyzerPage(),
    ),
    ARFeature(
      title: 'AR Health Capture Coach',
      subtitle: 'Smart Guidance with Real-time Instructions',
      icon: Icons.person_pin_rounded,
      color: const Color(0xFF667eea),
      description: 'A real-time AR avatar or holographic guide that shows correct finger, lip, eye, and tongue poses. Gives LIVE instructions like "Rotate hand slightly — ridges not visible" using pose estimation + depth to ensure perfect scan.',
      features: [
        'Live AR pose guidance',
        'Real-time feedback on positioning',
        'Depth sensing for accuracy',
        'Similar to Apple FaceID calibration',
      ],
      page: const ARHealthCaptureCoach(),
    ),
    ARFeature(
      title: 'AR Diagnostic Heatmap',
      subtitle: 'Live Overlay Problem Detection',
      icon: Icons.health_and_safety_rounded,
      color: const Color(0xFFf093fb),
      description: 'After capturing, see a live AR overlay heatmap where problems are detected. Red zones = concern (pale, cracked, smooth, cyanotic), Yellow zones = borderline, Green = normal. Rotate and zoom in AR like MRI visualization.',
      features: [
        'Color-coded health zones',
        'Red: Concern areas',
        'Yellow: Borderline',
        'Green: Normal',
        '3D rotation and zoom',
      ],
      page: const DiagnosticHeatmap(),
    ),
    ARFeature(
      title: 'Deficiency Simulation Preview',
      subtitle: 'See Future Symptoms in AR',
      icon: Icons.preview_rounded,
      color: const Color(0xFFfa709a),
      description: 'See how future symptoms may look if deficiency is not corrected. Example: "If iron deficiency continues for 3 months → nails may bend inward (koilonychia)" visually applied on user finger through AR.',
      features: [
        'Future symptom visualization',
        'Timeline-based progression',
        'Interactive 3D simulations',
        'Health awareness through immersion',
      ],
      page: const DeficiencySimulation(),
    ),
    ARFeature(
      title: 'AR Food Recommendation',
      subtitle: 'Floating 3D Nutritious Foods',
      icon: Icons.restaurant_menu_rounded,
      color: const Color(0xFF38ef7d),
      description: 'Place 3D nutritious foods around you like floating cards. Detected: Low B12? AR pops up 3D models of eggs, salmon, chicken, and fortified cereal. Tap to see why, how much, and recipe suggestions.',
      features: [
        '3D food models in AR space',
        'Interactive tap for details',
        'Nutritional information overlay',
        'Recipe suggestions',
        'Portion recommendations',
      ],
      page: const FoodRecommendationAR(),
    ),
    ARFeature(
      title: 'AR Nutrient Plate Builder',
      subtitle: 'Gamified Nutrition Planning',
      icon: Icons.playlist_add_check_circle_rounded,
      color: const Color(0xFFfeca57),
      description: 'Point camera at real food, and AR builds a nutrient score circle showing Protein %, Iron %, Vitamins, and Minerals. Suggests replacements by dragging AR food objects.',
      features: [
        'Real-time food scanning',
        'Nutrient composition analysis',
        'Interactive plate building',
        'Drag-and-drop AR objects',
        'Score visualization',
      ],
      page: const NutrientPlateBuilder(),
    ),
    ARFeature(
      title: 'AR Progress Timeline',
      subtitle: 'Before & After Ghost Overlay',
      icon: Icons.timeline_rounded,
      color: const Color(0xFF5f27cd),
      description: 'Show historical scan data in AR. Past scan → semi-transparent overlay, Present scan → full color, Change → marked visually. Track chronic improvement over 6-8 weeks.',
      features: [
        'Historical comparison overlay',
        'Ghost image of past scans',
        'Visual change markers',
        'Progress tracking',
        'Weekly/monthly views',
      ],
      page: const ProgressTimelineAR(),
    ),
    ARFeature(
      title: 'Skin Tone Normalization',
      subtitle: 'AR Calibration for Accuracy',
      icon: Icons.palette_rounded,
      color: const Color(0xFFff6348),
      description: 'Apply AR calibrators (Macbeth color chart concept). Calibrate white point & exposure via AR marker. Neutralizes lighting & skin tone bias using reference color card or AR virtual swatch.',
      features: [
        'Automatic color calibration',
        'Lighting compensation',
        'Skin tone bias removal',
        'Reference card system',
        'Enhanced accuracy',
      ],
      page: const SkinToneNormalizer(),
    ),
    ARFeature(
      title: 'Hydration Estimator',
      subtitle: 'Capillary Refill AR Timer',
      icon: Icons.water_drop_rounded,
      color: const Color(0xFF0abde3),
      description: 'Using capillary refill + nailbed response animations. Shows how hydration affects color with AR timer to detect refill duration (AI-assisted).',
      features: [
        'Real-time capillary refill test',
        'Hydration level indicator',
        'Interactive timing animations',
        'Color change detection',
        'AI-assisted analysis',
      ],
      page: const HydrationEstimator(),
    ),
    ARFeature(
      title: 'AR Interactive Doctor',
      subtitle: 'Voice-Based 3D Avatar',
      icon: Icons.medical_information_rounded,
      color: const Color(0xFFc44569),
      description: '3D doctor avatar that asks medical questions conversationally, explains findings in simple animation, and mentally comforts users.',
      features: [
        'Conversational AI doctor',
        'Medical questions & answers',
        'Animated explanations',
        'Emotional support',
        'Multi-language support',
      ],
      page: const VoiceInteractiveDoctor(),
    ),
    ARFeature(
      title: 'AR Habit Planner Billboard',
      subtitle: 'Daily Routine Overlay',
      icon: Icons.calendar_today_rounded,
      color: const Color(0xFF00d2d3),
      description: 'Overlay daily routine in AR on desk or wall. "Morning: 1 bowl oats + banana, Afternoon: spinach dal + jaggery water, Night: curd + soaked raisins". View anytime with camera.',
      features: [
        'AR routine placement',
        'Meal schedule overlay',
        'Room anchoring',
        'Always-visible reminders',
        'Customizable layout',
      ],
      page: const PrescriptionPlanner(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Gradient
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF667eea),
                      const Color(0xFF764ba2),
                      Colors.purple[900]!,
                    ],
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
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.view_in_ar_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.5, 0.5)),
                        const SizedBox(height: 16),
                        const Text(
                          'Augmented Reality',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideX(begin: -0.2),
                        const Text(
                          'Health Features',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
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
          // Info Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.orange[400]!, Colors.deepOrange[600]!],
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
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.stars_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next Generation Features',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Experience the future of health technology',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.3),
            ),
          ),
          // Features List
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildFeatureCard(_features[index], index);
                },
                childCount: _features.length,
              ),
            ),
          ),
          // Footer
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[50]!, Colors.purple[50]!],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue[200]!, width: 2),
                ),
                child: Column(
                  children: [
                    Icon(Icons.construction_rounded, color: Colors.blue[700], size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'Coming Soon',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'These innovative AR features are currently under development. Stay tuned for updates!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 1000.ms).scale(begin: const Offset(0.9, 0.9)),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(ARFeature feature, int index) {
    final isExpanded = _expandedIndex == index;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: feature.color.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: feature.color.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            // Header
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (feature.page != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => feature.page!),
                    );
                  } else {
                    setState(() {
                      _expandedIndex = isExpanded ? null : index;
                    });
                  }
                },
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [feature.color.withOpacity(0.8), feature.color],
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
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(feature.icon, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feature.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              feature.subtitle,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.white,
                        size: 28,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Expanded Content
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.description,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Key Features:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...feature.features.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: feature.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              f,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1),
          ],
        ),
      ).animate().fadeIn(
        duration: 600.ms,
        delay: Duration(milliseconds: 400 + (index * 50)),
      ).slideX(begin: 0.2),
    );
  }
}

class ARFeature {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String description;
  final List<String> features;
  final bool comingSoon;
  final Widget? page;

  ARFeature({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.description,
    required this.features,
    this.comingSoon = false,
    this.page,
  });
}
