/// Deficiency Explanation & Education Page
/// Shows causes, effects, fixes, and prevention strategies
library;

import 'package:flutter/material.dart';
import '../models/deficiency_knowledge.dart';

class DeficiencyExplanationPage extends StatelessWidget {
  final String nutrient;
  final String? detectedFrom; // 'tongue', 'lips', 'nails', 'eyes'
  final String severity; // 'mild', 'moderate', 'severe'

  const DeficiencyExplanationPage({
    super.key,
    required this.nutrient,
    this.detectedFrom,
    this.severity = 'moderate',
  });

  Color _getSeverityColor() {
    switch (severity.toLowerCase()) {
      case 'severe':
        return Colors.red;
      case 'moderate':
        return Colors.orange;
      case 'mild':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final knowledge = DeficiencyKnowledgeDatabase.getKnowledge(nutrient);

    if (knowledge == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Deficiency Info'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Information not available for this nutrient.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('$nutrient Deficiency'),
        backgroundColor: _getSeverityColor(),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_getSeverityColor(), _getSeverityColor().withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        severity == 'severe'
                            ? Icons.warning_amber_rounded
                            : Icons.info_outline_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nutrient,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              knowledge.scientificName,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Severity: ${severity.toUpperCase()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (detectedFrom != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Detected from: ${detectedFrom!.toUpperCase()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Possible Causes Section
            _buildSection(
              context,
              icon: Icons.search_rounded,
              title: '🔍 Possible Causes',
              subtitle: 'Why this deficiency might have occurred',
              color: Colors.blue,
              child: Column(
                children: knowledge.causes.map((cause) {
                  return _buildCauseCard(cause);
                }).toList(),
              ),
            ),

            // Effects on Body Section
            _buildSection(
              context,
              icon: Icons.health_and_safety_rounded,
              title: '⚠️ Effects on Your Body',
              subtitle: 'How this deficiency affects your health',
              color: Colors.red,
              child: Column(
                children: knowledge.effects.map((effect) {
                  return _buildEffectCard(effect);
                }).toList(),
              ),
            ),

            // Fix & Solutions Section
            _buildSection(
              context,
              icon: Icons.medical_services_rounded,
              title: '💊 How to Fix This',
              subtitle: 'Recommended actions to overcome deficiency',
              color: Colors.green,
              child: Column(
                children: knowledge.fixes.map((fix) {
                  return _buildFixCard(fix);
                }).toList(),
              ),
            ),

            // Prevention Tips Section
            _buildSection(
              context,
              icon: Icons.shield_rounded,
              title: '🛡️ Prevention Tips',
              subtitle: 'How to prevent this deficiency in future',
              color: Colors.purple,
              child: Column(
                children: knowledge.preventionTips.map((tip) {
                  return _buildTipCard(tip);
                }).toList(),
              ),
            ),

            // Absorption Info Section
            _buildAbsorptionCard(knowledge),

            // Demographics Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.people_outline, color: Colors.amber),
                        SizedBox(width: 8),
                        Text(
                          'Common In',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      knowledge.commonIn,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            // Urgency Level
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: knowledge.urgencyLevel == 'urgent'
                      ? Colors.red[50]
                      : Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: knowledge.urgencyLevel == 'urgent'
                        ? Colors.red[200]!
                        : Colors.blue[200]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      knowledge.urgencyLevel == 'urgent'
                          ? Icons.priority_high_rounded
                          : Icons.info_outline,
                      color: knowledge.urgencyLevel == 'urgent'
                          ? Colors.red
                          : Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Action Required',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            knowledge.urgencyLevel == 'urgent'
                                ? 'Start treatment immediately. Consider consulting a doctor if symptoms persist.'
                                : 'Address through diet changes. Monitor progress over 2-4 weeks.',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
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

  Widget _buildCauseCard(DeficiencyCause cause) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
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
          Text(
            cause.icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cause.category.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cause.description,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEffectCard(DeficiencyEffect effect) {
    Color severityColor;
    switch (effect.severity) {
      case 'severe':
        severityColor = Colors.red;
        break;
      case 'moderate':
        severityColor = Colors.orange;
        break;
      default:
        severityColor = Colors.amber;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: severityColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: severityColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: severityColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  effect.symptom,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Severity: ${effect.severity} | Affects: ${effect.bodyPart.replaceAll('_', ' ')}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixCard(DeficiencyFix fix) {
    IconData fixIcon;
    Color fixColor;

    switch (fix.type) {
      case 'food':
        fixIcon = Icons.restaurant_menu;
        fixColor = Colors.green;
        break;
      case 'lifestyle':
        fixIcon = Icons.directions_run;
        fixColor = Colors.blue;
        break;
      case 'supplement':
        fixIcon = Icons.medication;
        fixColor = Colors.purple;
        break;
      case 'medical':
        fixIcon = Icons.local_hospital;
        fixColor = Colors.red;
        break;
      default:
        fixIcon = Icons.lightbulb;
        fixColor = Colors.amber;
    }

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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: fixColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(fixIcon, color: fixColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fix.recommendation,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Priority: ${fix.priority.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 10,
                        color: fix.priority == 'high' ? Colors.red : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (fix.foodSuggestions.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Food Suggestions:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: fix.foodSuggestions.map((food) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: fixColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: fixColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    food,
                    style: TextStyle(
                      fontSize: 12,
                      color: fixColor.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTipCard(String tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
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
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbsorptionCard(DeficiencyKnowledge knowledge) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo[50]!, Colors.blue[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.indigo[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.science_outlined, color: Colors.indigo),
                SizedBox(width: 8),
                Text(
                  'Absorption Science',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Boosters
            const Text(
              '✅ Absorption Boosters:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: knowledge.absorptionBoosters.map((booster) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Text(
                    booster,
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 12),
            
            // Inhibitors
            const Text(
              '❌ Absorption Inhibitors:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: knowledge.absorptionInhibitors.map((inhibitor) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    inhibitor,
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
