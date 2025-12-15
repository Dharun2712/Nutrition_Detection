import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class ARFoodAnalyzerPage extends StatefulWidget {
  const ARFoodAnalyzerPage({Key? key}) : super(key: key);

  @override
  State<ARFoodAnalyzerPage> createState() => _ARFoodAnalyzerPageState();
}

class _ARFoodAnalyzerPageState extends State<ARFoodAnalyzerPage>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isInitialized = false;
  bool _isAnalyzing = false;
  bool _showResults = false;

  // Analysis mode
  bool _isLiveMode = false;
  Timer? _liveAnalysisTimer;

  // Food analysis results
  List<DetectedFood> _detectedFoods = [];
  double _mealScore = 0;
  String _healthAdvice = '';
  Map<String, NutrientData> _totalNutrition = {};

  // Animation controllers
  late AnimationController _scanController;
  late AnimationController _resultController;
  late AnimationController _nutrient3DController;
  late AnimationController _pulseController;
  late Animation<double> _scanAnimation;
  late Animation<double> _rotate3DAnimation;
  late Animation<double> _pulseAnimation;

  // AR overlay positions
  final List<Offset> _foodPositions = [];

  final String _groqApiKey = ''; // TODO: Add your GROQ API key here

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(_scanController);

    _resultController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // 3D rotation animation for nutrients (Reduced intensity for performance)
    _nutrient3DController = AnimationController(
      duration: const Duration(seconds: 10), // Slower rotation from 4s to 10s
      vsync: this,
    )..repeat();
    _rotate3DAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159 * 0.3, // Reduced rotation angle to 30% of full circle
    ).animate(_nutrient3DController);

    // Pulse animation for health indicators (Reduced intensity)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000), // Slower pulse from 1.5s to 2s
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate( // Reduced scale from 0.85-1.15 to 0.95-1.05
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.high,
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

  void _toggleLiveMode() {
    setState(() {
      _isLiveMode = !_isLiveMode;
      if (_isLiveMode) {
        _startLiveAnalysis();
      } else {
        _stopLiveAnalysis();
      }
    });
  }

  void _startLiveAnalysis() {
    _liveAnalysisTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && _isLiveMode && !_isAnalyzing) {
        _captureAndAnalyze();
      }
    });
  }

  void _stopLiveAnalysis() {
    _liveAnalysisTimer?.cancel();
  }

  Future<void> _captureAndAnalyze() async {
    if (_isAnalyzing || _cameraController == null) return;

    setState(() => _isAnalyzing = true);

    try {
      final image = await _cameraController!.takePicture();
      if (kIsWeb) {
        // On web, CameraController.takePicture returns an XFile; read bytes directly
        final bytes = await image.readAsBytes();
        await _analyzeFoodWithGroqBytes(bytes);
      } else {
        await _analyzeFoodWithGroq(File(image.path));
      }
    } catch (e) {
      debugPrint('Capture error: $e');
      setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _pickImageAndAnalyze() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _isAnalyzing = true);
      if (kIsWeb) {
        // On web, use bytes directly to avoid dart:io File
        final bytes = await pickedFile.readAsBytes();
        await _analyzeFoodWithGroqBytes(bytes);
      } else {
        await _analyzeFoodWithGroq(File(pickedFile.path));
      }
    }
  }

  /// Compress image to reduce size and stay within API limits
  Future<List<int>> _compressImage(List<int> bytes) async {
    try {
      // Decode image
      final image = img.decodeImage(Uint8List.fromList(bytes));
      if (image == null) {
        debugPrint('⚠️ Failed to decode image, using original');
        return bytes;
      }

      // Resize if too large (max 800px on longest side)
      img.Image resized = image;
      if (image.width > 800 || image.height > 800) {
        final ratio = image.width > image.height
            ? 800 / image.width
            : 800 / image.height;
        resized = img.copyResize(
          image,
          width: (image.width * ratio).round(),
          height: (image.height * ratio).round(),
        );
        debugPrint(
          '📐 Resized: ${image.width}x${image.height} → ${resized.width}x${resized.height}',
        );
      }

      // Compress as JPEG with quality 70
      final compressed = img.encodeJpg(resized, quality: 70);
      debugPrint(
        '📦 Compressed: ${bytes.length} → ${compressed.length} bytes (${((1 - compressed.length / bytes.length) * 100).toStringAsFixed(1)}% reduction)',
      );

      return compressed;
    } catch (e) {
      debugPrint('⚠️ Compression failed: $e, using original');
      return bytes;
    }
  }

  Future<void> _analyzeFoodWithGroq(File imageFile) async {
    try {
      // Convert image to base64
      List<int> bytes = await imageFile.readAsBytes();

      // Auto-compress if image is large
      if (bytes.length > 500 * 1024) {
        debugPrint('🔄 Image size: ${bytes.length} bytes, compressing...');
        bytes = await _compressImage(bytes);
      }

      // Check again after compression
      if (bytes.length > 500 * 1024) {
        debugPrint(
          '⚠️ Image still too large (${bytes.length} bytes) after compression',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '⚠️ Image too large. Please compress or use a smaller image (max 500KB).',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() => _isAnalyzing = false);
        return;
      }

      final base64Image = base64Encode(bytes);

      debugPrint('🔍 Starting Groq Vision analysis...');
      debugPrint('📦 Image size: ${bytes.length} bytes');
      debugPrint('🔑 API Key present: ${_groqApiKey.isNotEmpty}');

      // Use Llama 4 Scout vision model
      final models = ['meta-llama/llama-4-scout-17b-16e-instruct'];
      http.Response? recognitionResponse;

      for (String model in models) {
        try {
          debugPrint('📡 Trying model: $model');

          recognitionResponse = await http
              .post(
                Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
                headers: {
                  'Authorization': 'Bearer $_groqApiKey',
                  'Content-Type': 'application/json',
                },
                body: jsonEncode({
                  'model': model,
                  'messages': [
                    {
                      'role': 'user',
                      'content': [
                        {
                          'type': 'text',
                          'text':
                              '''Analyze this food image. List each food with name, portion (e.g. "150g"), calories, protein(g), carbs(g), fat(g), fiber(g). Return ONLY JSON array:
[{"name":"rice","portion":"150g","calories":200,"protein":4,"carbs":45,"fat":0.5,"fiber":1,"iron":1,"calcium":10,"vitaminC":0,"vitaminD":0,"vitaminB12":0,"confidence":0.9}]''',
                        },
                        {
                          'type': 'image_url',
                          'image_url': {
                            'url': 'data:image/jpeg;base64,$base64Image',
                          },
                        },
                      ],
                    },
                  ],
                  'temperature': 0.5,
                  'max_tokens': 800,
                }),
              )
              .timeout(const Duration(seconds: 45));

          if (recognitionResponse.statusCode == 200) {
            debugPrint('✅ Success with model: $model');
            break;
          } else {
            debugPrint(
              '⚠️ Model $model returned ${recognitionResponse.statusCode}',
            );
          }
        } catch (e) {
          debugPrint('❌ Model $model failed: $e');
          if (model == models.last) rethrow;
        }
      }

      if (recognitionResponse == null) {
        throw Exception('All models failed to respond');
      }

      debugPrint('📨 Response status: ${recognitionResponse.statusCode}');
      debugPrint('📄 Response body length: ${recognitionResponse.body.length}');

      if (recognitionResponse.statusCode == 200) {
        final recognitionData = jsonDecode(recognitionResponse.body);
        debugPrint('✅ Response parsed successfully');

        final foodText = recognitionData['choices'][0]['message']['content'];
        debugPrint(
          '🍽️ Food text response: ${foodText.substring(0, foodText.length > 200 ? 200 : foodText.length)}...',
        );

        // Extract JSON from response
        String jsonText = foodText.trim();

        // Handle markdown code blocks
        if (jsonText.contains('```json')) {
          jsonText = jsonText.substring(jsonText.indexOf('```json') + 7);
        } else if (jsonText.contains('```')) {
          jsonText = jsonText.substring(jsonText.indexOf('```') + 3);
        }

        if (jsonText.contains('```')) {
          jsonText = jsonText.substring(0, jsonText.indexOf('```'));
        }

        if (jsonText.contains('[')) {
          jsonText = jsonText.substring(jsonText.indexOf('['));
        }
        if (jsonText.contains(']')) {
          jsonText = jsonText.substring(0, jsonText.lastIndexOf(']') + 1);
        }

        debugPrint('📋 Extracted JSON: $jsonText');

        final List<dynamic> foodList = jsonDecode(jsonText);
        debugPrint('🎯 Detected ${foodList.length} food items');

        if (foodList.isEmpty) {
          throw Exception('No food items detected in the image');
        }

        // Step 2: Calculate total nutrition
        _calculateNutrition(foodList);

        // Step 3: Get AI health scoring and advice
        await _getHealthScoring(foodList);

        setState(() {
          _showResults = true;
          _isAnalyzing = false;
        });
        _resultController.forward(from: 0);

        debugPrint('✨ Analysis complete!');
      } else {
        final errorBody = recognitionResponse.body;
        debugPrint('❌ API Error: $errorBody');
        throw Exception(
          'Groq API error ${recognitionResponse.statusCode}: $errorBody',
        );
      }
    } on TimeoutException catch (e) {
      debugPrint('⏱️ Timeout error: $e');
      setState(() => _isAnalyzing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '⏱️ Request timeout. Check your internet connection.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Analysis error: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() => _isAnalyzing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ Analysis failed: ${e.toString().length > 100 ? e.toString().substring(0, 100) + '...' : e.toString()}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _analyzeFoodWithGroq(imageFile),
            ),
          ),
        );
      }
    }
  }

  // Web-friendly analyzer using raw image bytes (avoids dart:io File on web)
  Future<void> _analyzeFoodWithGroqBytes(Uint8List bytesUint8) async {
    try {
      List<int> bytes = bytesUint8;

      // Auto-compress if image is large
      if (bytes.length > 500 * 1024) {
        debugPrint('🔄 Image size: ${bytes.length} bytes, compressing...');
        bytes = await _compressImage(bytes);
      }

      // Check again after compression
      if (bytes.length > 500 * 1024) {
        debugPrint(
          '⚠️ Image still too large (${bytes.length} bytes) after compression',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '⚠️ Image too large. Please compress or use a smaller image (max 500KB).',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() => _isAnalyzing = false);
        return;
      }

      final base64Image = base64Encode(bytes);

      debugPrint('🔍 Starting Groq Vision analysis (bytes)...');
      debugPrint('📦 Image size: ${bytes.length} bytes');
      debugPrint('🔑 API Key present: ${_groqApiKey.isNotEmpty}');

      // Use Llama 4 Scout vision model
      final models = ['meta-llama/llama-4-scout-17b-16e-instruct'];
      http.Response? recognitionResponse;

      for (String model in models) {
        try {
          debugPrint('📡 Trying model: $model');

          recognitionResponse = await http
              .post(
                Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
                headers: {
                  'Authorization': 'Bearer $_groqApiKey',
                  'Content-Type': 'application/json',
                },
                body: jsonEncode({
                  'model': model,
                  'messages': [
                    {
                      'role': 'user',
                      'content': [
                        {
                          'type': 'text',
                          'text':
                              '''Analyze this food image. List each food with name, portion (e.g. "150g"), calories, protein(g), carbs(g), fat(g), fiber(g). Return ONLY JSON array:
[{"name":"rice","portion":"150g","calories":200,"protein":4,"carbs":45,"fat":0.5,"fiber":1,"iron":1,"calcium":10,"vitaminC":0,"vitaminD":0,"vitaminB12":0,"confidence":0.9}]''',
                        },
                        {
                          'type': 'image_url',
                          'image_url': {
                            'url': 'data:image/jpeg;base64,$base64Image',
                          },
                        },
                      ],
                    },
                  ],
                  'temperature': 0.5,
                  'max_tokens': 800,
                }),
              )
              .timeout(const Duration(seconds: 45));

          if (recognitionResponse.statusCode == 200) {
            debugPrint('✅ Success with model: $model');
            break;
          } else {
            debugPrint(
              '⚠️ Model $model returned ${recognitionResponse.statusCode}',
            );
          }
        } catch (e) {
          debugPrint('❌ Model $model failed: $e');
          if (model == models.last) rethrow;
        }
      }

      if (recognitionResponse == null) {
        throw Exception('All models failed to respond');
      }

      debugPrint('📨 Response status: ${recognitionResponse.statusCode}');
      debugPrint('📄 Response body length: ${recognitionResponse.body.length}');

      if (recognitionResponse.statusCode == 200) {
        final recognitionData = jsonDecode(recognitionResponse.body);
        debugPrint('✅ Response parsed successfully');

        final foodText = recognitionData['choices'][0]['message']['content'];
        debugPrint(
          '🍽️ Food text response: ${foodText.substring(0, foodText.length > 200 ? 200 : foodText.length)}...',
        );

        // Extract JSON from response
        String jsonText = foodText.trim();

        // Handle markdown code blocks
        if (jsonText.contains('```json')) {
          jsonText = jsonText.substring(jsonText.indexOf('```json') + 7);
        } else if (jsonText.contains('```')) {
          jsonText = jsonText.substring(jsonText.indexOf('```') + 3);
        }

        if (jsonText.contains('```')) {
          jsonText = jsonText.substring(0, jsonText.indexOf('```'));
        }

        if (jsonText.contains('[')) {
          jsonText = jsonText.substring(jsonText.indexOf('['));
        }
        if (jsonText.contains(']')) {
          jsonText = jsonText.substring(0, jsonText.lastIndexOf(']') + 1);
        }

        debugPrint('📋 Extracted JSON: $jsonText');

        final List<dynamic> foodList = jsonDecode(jsonText);
        debugPrint('🎯 Detected ${foodList.length} food items');

        if (foodList.isEmpty) {
          throw Exception('No food items detected in the image');
        }

        // Step 2: Calculate total nutrition
        _calculateNutrition(foodList);

        // Step 3: Get AI health scoring and advice
        await _getHealthScoring(foodList);

        setState(() {
          _showResults = true;
          _isAnalyzing = false;
        });
        _resultController.forward(from: 0);

        debugPrint('✨ Analysis complete!');
      } else {
        final errorBody = recognitionResponse.body;
        debugPrint('❌ API Error: $errorBody');
        throw Exception(
          'Groq API error ${recognitionResponse.statusCode}: $errorBody',
        );
      }
    } on TimeoutException catch (e) {
      debugPrint('⏱️ Timeout error: $e');
      setState(() => _isAnalyzing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '⏱️ Request timeout. Check your internet connection.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Analysis error: $e');
      debugPrint('Stack trace: $stackTrace');
      setState(() => _isAnalyzing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ Analysis failed: ${e.toString().length > 100 ? e.toString().substring(0, 100) + '...' : e.toString()}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _analyzeFoodWithGroqBytes(bytesUint8),
            ),
          ),
        );
      }
    }
  }

  void _calculateNutrition(List<dynamic> foodList) {
    _detectedFoods.clear();
    _totalNutrition.clear();

    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalFiber = 0;
    double totalIron = 0;
    double totalCalcium = 0;
    double totalVitaminC = 0;
    double totalVitaminD = 0;
    double totalVitaminB12 = 0;

    // Generate random positions for AR overlay
    _foodPositions.clear();
    for (int i = 0; i < foodList.length; i++) {
      final food = foodList[i];
      _detectedFoods.add(DetectedFood.fromJson(food));

      totalCalories += (food['calories'] ?? 0).toDouble();
      totalProtein += (food['protein'] ?? 0).toDouble();
      totalCarbs += (food['carbs'] ?? 0).toDouble();
      totalFat += (food['fat'] ?? 0).toDouble();
      totalFiber += (food['fiber'] ?? 0).toDouble();
      totalIron += (food['iron'] ?? 0).toDouble();
      totalCalcium += (food['calcium'] ?? 0).toDouble();
      totalVitaminC += (food['vitaminC'] ?? 0).toDouble();
      totalVitaminD += (food['vitaminD'] ?? 0).toDouble();
      totalVitaminB12 += (food['vitaminB12'] ?? 0).toDouble();

      // Improved AR positions - staggered layout for better visibility
      final row = i ~/ 2; // 2 items per row
      final col = i % 2;
      _foodPositions.add(
        Offset(
          0.1 + (col * 0.5), // Left or right column
          0.15 + (row * 0.25), // Vertical spacing
        ),
      );
    }

    _totalNutrition = {
      'Calories': NutrientData(
        totalCalories,
        'kcal',
        totalCalories > 700
            ? Colors.red
            : totalCalories > 400
            ? Colors.orange
            : Colors.green,
      ),
      'Protein': NutrientData(
        totalProtein,
        'g',
        totalProtein < 20 ? Colors.red : Colors.green,
      ),
      'Carbs': NutrientData(
        totalCarbs,
        'g',
        totalCarbs > 60 ? Colors.orange : Colors.green,
      ),
      'Fat': NutrientData(
        totalFat,
        'g',
        totalFat > 30 ? Colors.red : Colors.green,
      ),
      'Fiber': NutrientData(
        totalFiber,
        'g',
        totalFiber < 5 ? Colors.red : Colors.green,
      ),
      'Iron': NutrientData(
        totalIron,
        'mg',
        totalIron < 3 ? Colors.red : Colors.green,
      ),
      'Calcium': NutrientData(
        totalCalcium,
        'mg',
        totalCalcium < 200 ? Colors.orange : Colors.green,
      ),
      'Vitamin C': NutrientData(
        totalVitaminC,
        'mg',
        totalVitaminC < 30 ? Colors.red : Colors.green,
      ),
      'Vitamin D': NutrientData(
        totalVitaminD,
        'IU',
        totalVitaminD < 100 ? Colors.red : Colors.green,
      ),
      'Vitamin B12': NutrientData(
        totalVitaminB12,
        'mcg',
        totalVitaminB12 < 1 ? Colors.red : Colors.green,
      ),
    };
  }

  Future<void> _getHealthScoring(List<dynamic> foodList) async {
    try {
      final nutritionSummary = _totalNutrition.entries
          .map(
            (e) =>
                '${e.key}: ${e.value.value.toStringAsFixed(1)}${e.value.unit}',
          )
          .join(', ');

      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_groqApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.1-8b-instant',
          'messages': [
            {
              'role': 'user',
              'content': '''Given this meal nutrition profile: $nutritionSummary

Rate this meal from 0-100 and provide brief health advice in max 30 words.

Return ONLY JSON format:
{"meal_score": 78, "risk_level": "moderate", "suggestion": "Your advice here"}''',
            },
          ],
          'temperature': 0.7,
          'max_tokens': 150,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final scoreText = data['choices'][0]['message']['content'];

        // Extract JSON
        String jsonText = scoreText.trim();
        if (jsonText.contains('{')) {
          jsonText = jsonText.substring(jsonText.indexOf('{'));
        }
        if (jsonText.contains('}')) {
          jsonText = jsonText.substring(0, jsonText.lastIndexOf('}') + 1);
        }

        final scoreData = jsonDecode(jsonText);

        setState(() {
          _mealScore = (scoreData['meal_score'] ?? 70).toDouble();
          _healthAdvice = scoreData['suggestion'] ?? 'Balanced meal detected.';
        });
      }
    } catch (e) {
      debugPrint('Scoring error: $e');
      setState(() {
        _mealScore = 70;
        _healthAdvice =
            'Analysis complete. Review your nutrition details below.';
      });
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.lightGreen;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  String _getScoreGrade(double score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Needs Improvement';
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _scanController.dispose();
    _resultController.dispose();
    _nutrient3DController.dispose();
    _pulseController.dispose();
    _liveAnalysisTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview
            if (_isInitialized && _cameraController != null)
              SizedBox.expand(child: CameraPreview(_cameraController!))
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),

            // Scanning animation overlay
            if (_isAnalyzing)
              AnimatedBuilder(
                animation: _scanAnimation,
                builder: (context, child) {
                  return Positioned(
                    top:
                        MediaQuery.of(context).size.height *
                        _scanAnimation.value,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.cyan,
                            Colors.cyan,
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyan,
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            // Semi-transparent overlay for better label visibility
            if (_showResults && !_isAnalyzing)
              Container(color: Colors.black.withOpacity(0.3)),

            // AR Food Labels Overlay
            if (_showResults && !_isAnalyzing) ..._buildARFoodLabels(),

            // Top controls
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _isLiveMode
                          ? Colors.red.withOpacity(0.8)
                          : Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isLiveMode
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isLiveMode ? 'LIVE MODE' : 'CAPTURE MODE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isLiveMode
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: _toggleLiveMode,
                  ),
                ],
              ),
            ),

            // Analysis indicator
            if (_isAnalyzing)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.cyan),
                      const SizedBox(height: 16),
                      const Text(
                        '🧠 Analyzing with Groq AI...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isLiveMode ? 'Live scanning...' : 'Please wait',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Results panel
            if (_showResults && !_isAnalyzing) _buildResultsPanel(),

            // Bottom controls
            if (!_showResults && !_isAnalyzing)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Gallery button
                    GestureDetector(
                      onTap: _pickImageAndAnalyze,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.photo_library,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),

                    // Capture button
                    GestureDetector(
                      onTap: _captureAndAnalyze,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Colors.cyan, Colors.blue],
                          ),
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyan.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),

                    // Info button
                    GestureDetector(
                      onTap: () => _showInfoDialog(),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildARFoodLabels() {
    return _detectedFoods.asMap().entries.map((entry) {
      final index = entry.key;
      final food = entry.value;
      final position = _foodPositions[index];

      return Positioned(
        top: MediaQuery.of(context).size.height * position.dy,
        left: MediaQuery.of(context).size.width * position.dx,
        child: AnimatedBuilder(
          animation: Listenable.merge([_rotate3DAnimation, _pulseAnimation]),
          builder: (context, child) {
            // Simplified animation - light rotation and minimal pulse for better performance
            final rotation = (_rotate3DAnimation.value * 0.05) + (index * 0.1); // Reduced rotation multiplier
            final pulse = 0.98 + (_pulseAnimation.value - 1) * 0.05; // Reduced pulse effect

            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // Reduced perspective depth
                ..rotateY(rotation) // Only Y-axis rotation for better performance
                ..scale(pulse), // Integrated scale into matrix for simpler transform
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.all(12),
                constraints: const BoxConstraints(maxWidth: 180),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      food.getGradeColor().withOpacity(0.98),
                      food.getGradeColor().withOpacity(0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.8),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                    BoxShadow(
                      color: food.getGradeColor().withOpacity(0.8),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Animated emoji with scale
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value * 0.85,
                              child: Text(
                                food.getEmoji(),
                                style: const TextStyle(fontSize: 28),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                food.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  shadows: [
                                    Shadow(blurRadius: 4, color: Colors.black),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                food.portion,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // 3D styled nutrition bars - more compact
                    _buildMiniNutrientBar(
                      '🔥',
                      '${food.calories.toInt()}',
                      Colors.orange,
                    ),
                    _buildMiniNutrientBar(
                      '💪',
                      '${food.protein.toInt()}g',
                      Colors.blue,
                    ),
                    _buildMiniNutrientBar(
                      '🌾',
                      '${food.carbs.toInt()}g',
                      Colors.amber,
                    ),

                    const SizedBox(height: 6),

                    // Health tag with glow
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.4),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            food.getGradeIcon(),
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            food.getHealthTag(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }).toList();
  }

  Widget _buildMiniNutrientBar(String emoji, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              shadows: const [Shadow(blurRadius: 4, color: Colors.black)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsPanel() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.95), Colors.black],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag indicator
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Meal Score
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getScoreColor(_mealScore).withOpacity(0.3),
                      _getScoreColor(_mealScore).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getScoreColor(_mealScore),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Meal Score',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: _mealScore),
                          duration: const Duration(milliseconds: 1500),
                          builder: (context, value, child) {
                            return Text(
                              '${value.toInt()}/100',
                              style: TextStyle(
                                color: _getScoreColor(_mealScore),
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: _mealScore / 100),
                        duration: const Duration(milliseconds: 1500),
                        builder: (context, value, child) {
                          return LinearProgressIndicator(
                            value: value,
                            minHeight: 12,
                            backgroundColor: Colors.white24,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getScoreColor(_mealScore),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getScoreGrade(_mealScore),
                      style: TextStyle(
                        color: _getScoreColor(_mealScore),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),

              const SizedBox(height: 20),

              // AI Advice
              Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue, width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb,
                          color: Colors.amber,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _healthAdvice,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 200.ms)
                  .slideX(begin: -0.2),

              const SizedBox(height: 20),

              // Detected Foods
              const Text(
                'Detected Foods',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ..._detectedFoods.asMap().entries.map((entry) {
                final index = entry.key;
                final food = entry.value;
                return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            food.getEmoji(),
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  food.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${food.calories.toInt()} kcal • ${food.portion}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: food.getGradeColor(),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${(food.confidence * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(
                      duration: 400.ms,
                      delay: Duration(milliseconds: 300 + index * 100),
                    )
                    .slideX(begin: 0.3);
              }).toList(),

              const SizedBox(height: 20),

              // Total Nutrition with 3D Animated Visualization
              const Text(
                '🧬 3D Nutrition Molecules',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // 3D Animated Nutrient Grid
              ..._totalNutrition.entries.toList().asMap().entries.map((
                mapEntry,
              ) {
                final index = mapEntry.key;
                final entry = mapEntry.value;
                return _build3DNutrientCard(entry.key, entry.value, index);
              }).toList(),

              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showResults = false;
                          _detectedFoods.clear();
                        });
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Scan Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showVRMode(),
                      icon: const Icon(Icons.view_in_ar),
                      label: const Text('VR Lab'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 1);
  }

  IconData _getNutrientIcon(String nutrient) {
    switch (nutrient.toLowerCase()) {
      case 'calories':
        return Icons.local_fire_department;
      case 'protein':
        return Icons.fitness_center;
      case 'carbs':
        return Icons.grain;
      case 'fat':
        return Icons.opacity;
      case 'fiber':
        return Icons.eco;
      case 'iron':
        return Icons.science;
      case 'calcium':
        return Icons.view_module;
      case 'vitamin c':
        return Icons.sunny;
      case 'vitamin d':
        return Icons.wb_sunny;
      case 'vitamin b12':
        return Icons.energy_savings_leaf;
      default:
        return Icons.info;
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '🏗️ AR Food Analyzer',
          style: TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'How it works:',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '1. 📸 Capture your meal\n'
                '2. 🧠 Groq AI analyzes food\n'
                '3. ⚖️ Estimates portions & nutrition\n'
                '4. 🧮 Calculates health score\n'
                '5. 🪄 AR overlay shows results\n'
                '6. 🌀 Optional VR nutrition lab',
                style: TextStyle(color: Colors.white, height: 1.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Modes:',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '• Live Mode: Continuous scanning\n'
                '• Capture Mode: Single photo analysis',
                style: TextStyle(color: Colors.white, height: 1.5),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _testGroqConnection();
                },
                icon: const Icon(Icons.wifi_find),
                label: const Text('Test Groq Connection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!', style: TextStyle(color: Colors.cyan)),
          ),
        ],
      ),
    );
  }

  Future<void> _testGroqConnection() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Testing Groq API...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final response = await http
          .post(
            Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
            headers: {
              'Authorization': 'Bearer $_groqApiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': 'llama-3.1-8b-instant',
              'messages': [
                {
                  'role': 'user',
                  'content': 'Say "Connected" if you can read this.',
                },
              ],
              'max_tokens': 10,
            }),
          )
          .timeout(const Duration(seconds: 10));

      Navigator.pop(context); // Close loading dialog

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data['choices'][0]['message']['content'];

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Groq API Connected!\nResponse: $message'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        throw Exception(
          'API returned ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Connection Failed:\n${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'Details',
              textColor: Colors.white,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Connection Error'),
                    content: SingleChildScrollView(child: Text(e.toString())),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    }
  }

  void _showVRMode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.purple[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '🌀 VR Nutrition Lab',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter immersive VR mode to:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ...[
                  '🫀 See nutrient absorption in organs',
                  '🔄 Compare different meal options',
                  '👨‍🍳 Get guided by virtual nutritionist',
                  '📊 Simulate long-term effects',
                ]
                .map(
                  (text) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Coming Soon',
              style: TextStyle(color: Colors.amber),
            ),
          ),
        ],
      ),
    );
  }

  // 3D Animated Nutrient Card with rotating molecule effect
  Widget _build3DNutrientCard(
    String nutrientName,
    NutrientData data,
    int index,
  ) {
    return AnimatedBuilder(
          animation: _rotate3DAnimation,
          builder: (context, child) {
            final rotation = _rotate3DAnimation.value + (index * 0.5);
            final scale = 0.9 + (0.1 * (1 + math.sin(rotation)).abs());

            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // perspective
                ..rotateY(rotation * 0.3)
                ..scale(scale),
              alignment: Alignment.center,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      data.color.withOpacity(0.3),
                      data.color.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: data.color.withOpacity(0.6),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: data.color.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Animated 3D molecule icon
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: data.color.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: data.color.withOpacity(0.6),
                                      blurRadius: 15,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _getNutrientIcon(nutrientName),
                                  color: data.color,
                                  size: 32,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nutrientName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: data.value),
                                duration: Duration(
                                  milliseconds: 1500 + (index * 200),
                                ),
                                builder: (context, value, child) {
                                  return Text(
                                    '${value.toStringAsFixed(1)} ${data.unit}',
                                    style: TextStyle(
                                      color: data.color,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Animated progress bar with particle effect
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          // Background
                          Container(
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),

                          // Animated fill
                          TweenAnimationBuilder<double>(
                            tween: Tween(
                              begin: 0,
                              end: _getNutrientProgress(
                                nutrientName,
                                data.value,
                              ),
                            ),
                            duration: Duration(
                              milliseconds: 1500 + (index * 200),
                            ),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Container(
                                height: 16,
                                width:
                                    MediaQuery.of(context).size.width *
                                    value *
                                    0.85,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      data.color,
                                      data.color.withOpacity(0.6),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: data.color.withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          // Shimmer effect
                          AnimatedBuilder(
                            animation: _rotate3DAnimation,
                            builder: (context, child) {
                              return Positioned(
                                left:
                                    (MediaQuery.of(context).size.width * 0.85) *
                                        (_rotate3DAnimation.value /
                                            (2 * 3.14159)) -
                                    50,
                                child: Container(
                                  width: 100,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        Colors.white.withOpacity(0.4),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Health status indicator
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: data.color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: data.color,
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getNutrientStatus(nutrientName, data.value),
                          style: TextStyle(
                            color: data.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        )
        .animate()
        .fadeIn(
          duration: 600.ms,
          delay: Duration(milliseconds: index * 150),
        )
        .slideX(begin: 0.5, curve: Curves.easeOutCubic);
  }

  double _getNutrientProgress(String nutrient, double value) {
    switch (nutrient.toLowerCase()) {
      case 'calories':
        return (value / 2500).clamp(0.0, 1.0);
      case 'protein':
        return (value / 50).clamp(0.0, 1.0);
      case 'carbs':
        return (value / 300).clamp(0.0, 1.0);
      case 'fat':
        return (value / 70).clamp(0.0, 1.0);
      case 'fiber':
        return (value / 30).clamp(0.0, 1.0);
      case 'iron':
        return (value / 18).clamp(0.0, 1.0);
      case 'calcium':
        return (value / 1000).clamp(0.0, 1.0);
      case 'vitamin c':
        return (value / 90).clamp(0.0, 1.0);
      case 'vitamin d':
        return (value / 600).clamp(0.0, 1.0);
      case 'vitamin b12':
        return (value / 2.4).clamp(0.0, 1.0);
      default:
        return 0.5;
    }
  }

  String _getNutrientStatus(String nutrient, double value) {
    final progress = _getNutrientProgress(nutrient, value);
    if (progress >= 0.8) return 'Excellent';
    if (progress >= 0.5) return 'Good';
    if (progress >= 0.3) return 'Moderate';
    return 'Low';
  }
}

class DetectedFood {
  final String name;
  final double confidence;
  final String portion;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double iron;
  final double calcium;
  final double vitaminC;
  final double vitaminD;
  final double vitaminB12;

  DetectedFood({
    required this.name,
    required this.confidence,
    required this.portion,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.iron,
    required this.calcium,
    required this.vitaminC,
    required this.vitaminD,
    required this.vitaminB12,
  });

  factory DetectedFood.fromJson(Map<String, dynamic> json) {
    return DetectedFood(
      name: json['name'] ?? 'Unknown',
      confidence: (json['confidence'] ?? 0.5).toDouble(),
      portion: json['portion'] ?? '0g',
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      fiber: (json['fiber'] ?? 0).toDouble(),
      iron: (json['iron'] ?? 0).toDouble(),
      calcium: (json['calcium'] ?? 0).toDouble(),
      vitaminC: (json['vitaminC'] ?? 0).toDouble(),
      vitaminD: (json['vitaminD'] ?? 0).toDouble(),
      vitaminB12: (json['vitaminB12'] ?? 0).toDouble(),
    );
  }

  Color getGradeColor() {
    if (protein > 15 && fiber > 3) return Colors.green;
    if (fat > 20 || carbs > 50) return Colors.red;
    if (calories > 500) return Colors.orange;
    return Colors.lightGreen;
  }

  IconData getGradeIcon() {
    if (protein > 15 && fiber > 3) return Icons.check_circle;
    if (fat > 20 || carbs > 50) return Icons.warning;
    return Icons.info;
  }

  String getHealthTag() {
    if (protein > 15 && fiber > 3) return 'High Protein';
    if (fat > 20) return 'High Fat';
    if (carbs > 50) return 'High Carbs';
    if (fiber > 5) return 'High Fiber';
    if (iron > 3) return 'Iron Rich';
    return 'Balanced';
  }

  String getEmoji() {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('rice')) return '🍚';
    if (lowerName.contains('chicken')) return '🍗';
    if (lowerName.contains('curry')) return '🍛';
    if (lowerName.contains('salad')) return '🥗';
    if (lowerName.contains('bread')) return '🍞';
    if (lowerName.contains('egg')) return '🥚';
    if (lowerName.contains('fish')) return '🐟';
    if (lowerName.contains('meat')) return '🥩';
    if (lowerName.contains('vegetable')) return '🥬';
    if (lowerName.contains('fruit')) return '🍎';
    if (lowerName.contains('dal') || lowerName.contains('lentil')) return '🫘';
    if (lowerName.contains('roti') || lowerName.contains('chapati'))
      return '🫓';
    if (lowerName.contains('soup')) return '🍲';
    if (lowerName.contains('noodle') || lowerName.contains('pasta'))
      return '🍝';
    return '🍽️';
  }
}

class NutrientData {
  final double value;
  final String unit;
  final Color color;

  NutrientData(this.value, this.unit, this.color);
}
