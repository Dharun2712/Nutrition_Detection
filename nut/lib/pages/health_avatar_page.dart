/// Personalized Health Avatar
/// Gamified 3D avatar that changes based on health status
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/health_database.dart';
import '../models/health_data.dart';
import 'dart:math' as math;

class HealthAvatarPage extends StatefulWidget {
  const HealthAvatarPage({super.key});

  @override
  State<HealthAvatarPage> createState() => _HealthAvatarPageState();
}

class _HealthAvatarPageState extends State<HealthAvatarPage> with TickerProviderStateMixin {
  final _db = HealthDatabase.instance;
  int _healthScore = 0;
  int _level = 1;
  int _experience = 0;
  List<String> _activeDeficiencies = [];
  List<String> _achievements = [];

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    final deficiencies = await _db.getRecentDeficiencies(days: 30);
    final meals = await _db.getRecentMeals(days: 7);

    // Calculate health score (0-100)
    int score = 100;
    
    // Reduce score for deficiencies
    final severeCount = deficiencies.where((d) => d.severity == DeficiencySeverity.severe).length;
    final moderateCount = deficiencies.where((d) => d.severity == DeficiencySeverity.moderate).length;
    final mildCount = deficiencies.where((d) => d.severity == DeficiencySeverity.mild).length;
    
    score -= (severeCount * 20);
    score -= (moderateCount * 10);
    score -= (mildCount * 5);
    score = math.max(0, score);

    // Add points for healthy meals
    score += math.min(20, meals.length * 2);
    score = math.min(100, score);

    // Calculate level and experience
    final level = (score ~/ 20) + 1;
    final experience = (score % 20) * 5;

    // Get active deficiency types
    final activeDeficiencies = deficiencies
        .where((d) => d.severity != DeficiencySeverity.normal)
        .map((d) => d.nutrient)
        .toSet()
        .toList();

    // Calculate achievements
    final achievements = <String>[];
    if (meals.length >= 7) achievements.add('7 Day Streak');
    if (score >= 80) achievements.add('Health Champion');
    if (deficiencies.isEmpty) achievements.add('Perfect Health');
    if (meals.length >= 30) achievements.add('Monthly Warrior');

    setState(() {
      _healthScore = score;
      _level = level;
      _experience = experience;
      _activeDeficiencies = activeDeficiencies;
      _achievements = achievements;
    });
  }

  Color _getAvatarColor() {
    if (_healthScore >= 80) return Colors.green;
    if (_healthScore >= 60) return Colors.yellow;
    if (_healthScore >= 40) return Colors.orange;
    return Colors.red;
  }

  String _getHealthStatus() {
    if (_healthScore >= 80) return 'Vibrant & Healthy';
    if (_healthScore >= 60) return 'Good Health';
    if (_healthScore >= 40) return 'Needs Attention';
    return 'Critical - See Doctor';
  }

  IconData _getAvatarEmoji() {
    if (_healthScore >= 80) return Icons.sentiment_very_satisfied;
    if (_healthScore >= 60) return Icons.sentiment_satisfied;
    if (_healthScore >= 40) return Icons.sentiment_neutral;
    return Icons.sentiment_very_dissatisfied;
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = _getAvatarColor();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Health Avatar'),
        backgroundColor: avatarColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHealthData,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [avatarColor.withValues(alpha: 0.1), Colors.white],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Avatar Card
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [avatarColor.withValues(alpha: 0.3), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    // Animated Avatar
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            avatarColor.withValues(alpha: 0.6),
                            avatarColor,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: avatarColor.withValues(alpha: 0.5),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        _getAvatarEmoji(),
                        size: 100,
                        color: Colors.white,
                      ),
                    )
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(duration: 2000.ms, color: Colors.white.withValues(alpha: 0.5))
                        .scale(
                          duration: 2000.ms,
                          begin: const Offset(0.98, 0.98),
                          end: const Offset(1.02, 1.02),
                        ),
                    
                    const SizedBox(height: 24),
                    
                    // Health Status
                    Text(
                      _getHealthStatus(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: avatarColor,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Health Score
                    Text(
                      'Health Score: $_healthScore/100',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Level & Experience
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Level',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: avatarColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$_level',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Experience to Next Level',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _experience / 100,
                        minHeight: 20,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(avatarColor),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_experience / 100 XP',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Active Deficiencies
            if (_activeDeficiencies.isNotEmpty) ...[
              const Text(
                'Active Health Challenges',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ..._activeDeficiencies.map((deficiency) => Card(
                    color: Colors.red.shade50,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.warning, color: Colors.red),
                      title: Text('$deficiency Deficiency'),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        // Navigate to deficiency details
                      },
                    ),
                  )),
              const SizedBox(height: 20),
            ],

            // Achievements
            const Text(
              'Achievements',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_achievements.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'Complete challenges to earn achievements!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _achievements.map((achievement) {
                  return Chip(
                    avatar: const Icon(Icons.emoji_events, color: Colors.amber),
                    label: Text(achievement),
                    backgroundColor: Colors.amber.shade100,
                  );
                }).toList(),
              ),

            const SizedBox(height: 20),

            // Tips to Level Up
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Level Up Tips',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTip('📱 Log meals daily to earn 2 XP per meal'),
                    _buildTip('🥗 Fix deficiencies to gain 10-20 points'),
                    _buildTip('⏰ Maintain a 7-day streak for bonus'),
                    _buildTip('🎯 Reach health score 80+ to unlock champion status'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Health Stats
            const Text(
              'Health Stats',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Score',
                    '$_healthScore',
                    Icons.favorite,
                    avatarColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Level',
                    '$_level',
                    Icons.arrow_upward,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Issues',
                    '${_activeDeficiencies.length}',
                    Icons.warning,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Achievements',
                    '${_achievements.length}',
                    Icons.emoji_events,
                    Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
