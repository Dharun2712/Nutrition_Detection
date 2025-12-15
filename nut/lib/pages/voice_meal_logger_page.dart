/// Voice-Based Nutrition Input
/// Speech-to-text for meal logging with AI food identification
library;

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VoiceMealLoggerPage extends StatefulWidget {
  const VoiceMealLoggerPage({super.key});

  @override
  State<VoiceMealLoggerPage> createState() => _VoiceMealLoggerPageState();
}

class _VoiceMealLoggerPageState extends State<VoiceMealLoggerPage>
    with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  late AnimationController _pulseController;
  
  bool _isListening = false;
  bool _isProcessing = false;
  String _spokenText = '';
  List<String> _identifiedFoods = [];
  Map<String, dynamic>? _nutritionAnalysis;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _initializeSpeech();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _initializeSpeech() async {
    await _speech.initialize(
      onError: (error) => _showError('Speech recognition error: ${error.errorMsg}'),
      onStatus: (status) => debugPrint('Speech status: $status'),
    );
    
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      if (_spokenText.isNotEmpty) {
        await _processMealDescription(_spokenText);
      }
    } else {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
          _spokenText = '';
          _identifiedFoods = [];
          _nutritionAnalysis = null;
        });
        
        await _tts.speak('Tell me what you ate');
        
        await _speech.listen(
          onResult: (result) {
            setState(() {
              _spokenText = result.recognizedWords;
            });
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 5),
        );
      } else {
        _showError('Speech recognition not available');
      }
    }
  }

  Future<void> _processMealDescription(String description) async {
    setState(() => _isProcessing = true);

    try {
      // Use GROQ API with efficient llama-3.3-70b-versatile model
      const groqApiKey = ''; // TODO: Add your GROQ API key here

      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $groqApiKey',
        },
        body: json.encode({
          'model': 'llama-3.3-70b-versatile', // Faster and more efficient
          'messages': [
            {
              'role': 'system',
              'content': '''You are a professional nutrition expert. Analyze the user's meal description and provide detailed nutritional information.

IMPORTANT: Respond ONLY with valid JSON. No markdown, no code blocks, just pure JSON.

Format:
{
  "foods": ["food1", "food2", "food3"],
  "nutrition": {
    "iron_mg": 5.2,
    "vitamin_b12_mcg": 2.1,
    "vitamin_d_mcg": 1.5,
    "calcium_mg": 300,
    "vitamin_a_mcg": 450,
    "vitamin_c_mg": 15,
    "protein_g": 25,
    "calories": 450
  },
  "analysis": "Concise nutritional analysis highlighting key benefits and any deficiencies"
}'''
            },
            {
              'role': 'user',
              'content': 'Analyze this meal: $description'
            }
          ],
          'temperature': 0.5,
          'max_tokens': 800,
          'top_p': 0.95,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'].toString().trim();
        
        // Remove markdown code blocks if present
        String cleanedContent = content
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        
        // Extract JSON from response
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(cleanedContent);
        if (jsonMatch != null) {
          try {
            final result = json.decode(jsonMatch.group(0)!);
            setState(() {
              _identifiedFoods = List<String>.from(result['foods'] ?? []);
              _nutritionAnalysis = result;
            });
            
            final foodCount = _identifiedFoods.length;
            final summary = result['analysis'] ?? 'Nutritional analysis complete';
            await _tts.speak('I identified $foodCount food items. $summary');
          } catch (e) {
            _showError('Failed to parse analysis results');
          }
        } else {
          _showError('Invalid response format from AI');
        }
      } else {
        _showError('Failed to analyze meal: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Meal Logger'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // Microphone button
            GestureDetector(
              onTap: _toggleListening,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 150 + (_isListening ? _pulseController.value * 20 : 0),
                    height: 150 + (_isListening ? _pulseController.value * 20 : 0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: _isListening
                            ? [Colors.red.shade300, Colors.red.shade600]
                            : [Colors.purple.shade300, Colors.purple.shade600],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening ? Colors.red : Colors.purple).withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      size: 70,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Status text
            Text(
              _isListening ? 'Listening...' : _isProcessing ? 'Analyzing...' : 'Tap to speak',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade700,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Spoken text
            if (_spokenText.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'You said:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _spokenText,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 20),
            
            // Identified foods
            if (_identifiedFoods.isNotEmpty)
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      'Identified Foods:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._identifiedFoods.map((food) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.restaurant, color: Colors.green),
                            title: Text(food),
                          ),
                        )),
                    
                    if (_nutritionAnalysis != null) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'Nutritional Analysis:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildNutrientCard('Iron', 
                          _nutritionAnalysis!['nutrition']['iron_mg'], 'mg', Icons.favorite),
                      _buildNutrientCard('Vitamin B12', 
                          _nutritionAnalysis!['nutrition']['vitamin_b12_mcg'], 'mcg', Icons.energy_savings_leaf),
                      _buildNutrientCard('Vitamin D', 
                          _nutritionAnalysis!['nutrition']['vitamin_d_mcg'], 'mcg', Icons.wb_sunny),
                      _buildNutrientCard('Calcium', 
                          _nutritionAnalysis!['nutrition']['calcium_mg'], 'mg', Icons.hardware),
                      _buildNutrientCard('Vitamin A', 
                          _nutritionAnalysis!['nutrition']['vitamin_a_mcg'], 'mcg', Icons.visibility),
                      
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _nutritionAnalysis!['analysis'] ?? '',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            
            // Example prompts
            if (!_isListening && _spokenText.isEmpty)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Try saying:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...[
                        '"I ate dosa with chutney and tea"',
                        '"I had chicken curry with rice"',
                        '"I ate spinach salad with eggs"',
                        '"I had milk and banana"',
                      ].map((example) => Card(
                            child: ListTile(
                              leading: const Icon(Icons.mic, color: Colors.purple),
                              title: Text(example),
                              dense: true,
                            ),
                          )),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientCard(String name, dynamic value, String unit, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(name),
        trailing: Text(
          '${value?.toStringAsFixed(1) ?? '0'} $unit',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
