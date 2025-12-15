import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:math' as math;

class VoiceInteractiveDoctor extends StatefulWidget {
  const VoiceInteractiveDoctor({Key? key}) : super(key: key);

  @override
  State<VoiceInteractiveDoctor> createState() => _VoiceInteractiveDoctorState();
}

class _VoiceInteractiveDoctorState extends State<VoiceInteractiveDoctor>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isInitialized = false;
  
  late FlutterTts _flutterTts;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _userInput = '';
  String _doctorResponse = '';
  
  late AnimationController _avatarController;
  late Animation<double> _avatarAnimation;
  late AnimationController _pulseController;
  
  final List<ChatMessage> _conversation = [];
  
  final Map<String, String> _responses = {
    'iron': 'Iron deficiency can cause fatigue and pale skin. I recommend eating more spinach, red meat, and beans. Also consider taking an iron supplement.',
    'tired': 'Fatigue can be caused by several deficiencies. Let\'s check your iron, vitamin D, and B12 levels. Make sure you\'re getting enough sleep too.',
    'calcium': 'Calcium is essential for strong bones. Include dairy products, leafy greens, and fortified foods in your diet. Aim for 1000-1200mg daily.',
    'vitamin d': 'Vitamin D deficiency is common. Get 15-20 minutes of sunlight daily and eat fatty fish, eggs, and fortified milk. A supplement may help.',
    'protein': 'Protein is crucial for muscle health. Include lean meats, fish, eggs, legumes, and nuts in every meal. Aim for 0.8g per kg of body weight.',
    'diet': 'A balanced diet should include vegetables, fruits, whole grains, lean proteins, and healthy fats. Eat a variety of colorful foods daily.',
  };

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeSpeech();
    
    _avatarController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _avatarAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.easeInOut),
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _greetUser();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        
        if (mounted) {
          setState(() => _isInitialized = true);
        }
      }
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  Future<void> _initializeSpeech() async {
    _flutterTts = FlutterTts();
    _speech = stt.SpeechToText();
    await _speech.initialize();
    
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
  }

  void _greetUser() {
    final greeting = 'Hello! I\'m Dr. AI, your virtual nutrition assistant. How can I help you today?';
    setState(() {
      _doctorResponse = greeting;
      _conversation.add(ChatMessage(greeting, true));
    });
    _speak(greeting);
  }

  void _speak(String text) async {
    await _flutterTts.speak(text);
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _userInput = result.recognizedWords;
              if (result.finalResult) {
                _processInput(_userInput);
                _isListening = false;
              }
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _processInput(String input) {
    if (input.isEmpty) return;
    
    setState(() {
      _conversation.add(ChatMessage(input, false));
    });
    
    final lowerInput = input.toLowerCase();
    String response = 'I understand you\'re asking about nutrition. ';
    
    bool foundMatch = false;
    _responses.forEach((key, value) {
      if (lowerInput.contains(key)) {
        response = value;
        foundMatch = true;
      }
    });
    
    if (!foundMatch) {
      response += 'Could you please be more specific about your symptoms or nutritional concerns?';
    }
    
    setState(() {
      _doctorResponse = response;
      _conversation.add(ChatMessage(response, true));
    });
    _speak(response);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _avatarController.dispose();
    _pulseController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('AI Doctor'),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          // Camera background
          if (_isInitialized && _cameraController != null)
            SizedBox.expand(
              child: Opacity(
                opacity: 0.3,
                child: CameraPreview(_cameraController!),
              ),
            ),
          
          Column(
            children: [
              // 3D Avatar
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _avatarAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _avatarAnimation.value),
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          const Center(
                            child: Icon(
                              Icons.medical_services,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          // Speaking indicator
                          if (_isListening)
                            Center(
                              child: AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Container(
                                    width: 170 + (_pulseController.value * 20),
                                    height: 170 + (_pulseController.value * 20),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.green,
                                        width: 3,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Dr. AI - Nutrition Specialist',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Conversation display
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.builder(
                    itemCount: _conversation.length,
                    itemBuilder: (context, index) {
                      final message = _conversation[index];
                      return Align(
                        alignment: message.isDoctor
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: message.isDoctor
                                  ? [Colors.blue.withOpacity(0.8), Colors.purple.withOpacity(0.8)]
                                  : [Colors.green.withOpacity(0.8), Colors.teal.withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          child: Text(
                            message.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Voice input indicator
              if (_isListening)
                Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.mic, color: Colors.white),
                      const SizedBox(width: 12),
                      Text(
                        _userInput.isEmpty ? 'Listening...' : _userInput,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Voice button
              Container(
                margin: const EdgeInsets.all(20),
                child: GestureDetector(
                  onTap: _listen,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _isListening ? 90 : 80,
                    height: _isListening ? 90 : 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _isListening
                            ? [Colors.red, Colors.deepOrange]
                            : [Colors.green, Colors.teal],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening ? Colors.red : Colors.green)
                              .withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isDoctor;

  ChatMessage(this.text, this.isDoctor);
}
