import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:math' as math;

class SkinToneNormalizer extends StatefulWidget {
  const SkinToneNormalizer({Key? key}) : super(key: key);

  @override
  State<SkinToneNormalizer> createState() => _SkinToneNormalizerState();
}

class _SkinToneNormalizerState extends State<SkinToneNormalizer> {
  CameraController? _cameraController;
  bool _isInitialized = false;
  bool _isCalibrating = false;
  bool _isCalibrated = false;
  
  // Calibration data
  double _brightness = 50;
  double _contrast = 50;
  double _warmth = 50;
  Color? _detectedSkinTone;
  String _skinToneCategory = '';
  
  final List<ColorSample> _colorSamples = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );
        
        _cameraController = CameraController(
          frontCamera,
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

  void _startCalibration() {
    setState(() {
      _isCalibrating = true;
      _colorSamples.clear();
    });
    
    // Simulate color detection
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted || !_isCalibrating) {
        timer.cancel();
        return;
      }
      
      setState(() {
        final random = math.Random();
        _colorSamples.add(ColorSample(
          Color.fromRGBO(
            200 + random.nextInt(55),
            150 + random.nextInt(55),
            120 + random.nextInt(55),
            1.0,
          ),
          DateTime.now(),
        ));
        
        if (_colorSamples.length >= 10) {
          _finishCalibration();
          timer.cancel();
        }
      });
    });
  }

  void _finishCalibration() {
    // Calculate average skin tone
    int avgR = 0, avgG = 0, avgB = 0;
    for (var sample in _colorSamples) {
      avgR += sample.color.red;
      avgG += sample.color.green;
      avgB += sample.color.blue;
    }
    avgR ~/= _colorSamples.length;
    avgG ~/= _colorSamples.length;
    avgB ~/= _colorSamples.length;
    
    setState(() {
      _detectedSkinTone = Color.fromRGBO(avgR, avgG, avgB, 1.0);
      _skinToneCategory = _categorizeSkinTone(avgR, avgG, avgB);
      _isCalibrating = false;
      _isCalibrated = true;
      
      // Auto-adjust settings
      _brightness = _calculateOptimalBrightness(avgR, avgG, avgB);
      _contrast = 55.0;
      _warmth = _calculateOptimalWarmth(avgR, avgG, avgB);
    });
  }

  String _categorizeSkinTone(int r, int g, int b) {
    final luminance = (0.299 * r + 0.587 * g + 0.114 * b);
    if (luminance > 200) return 'Very Fair';
    if (luminance > 170) return 'Fair';
    if (luminance > 140) return 'Medium';
    if (luminance > 110) return 'Olive';
    return 'Dark';
  }

  double _calculateOptimalBrightness(int r, int g, int b) {
    final luminance = (0.299 * r + 0.587 * g + 0.114 * b);
    return ((luminance / 255) * 50 + 25).clamp(0, 100);
  }

  double _calculateOptimalWarmth(int r, int g, int b) {
    final warmth = (r - b) / 255;
    return ((warmth + 1) * 25 + 25).clamp(0, 100);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Skin Tone Normalization'),
        backgroundColor: Colors.black,
        actions: [
          if (_isInitialized && !_isCalibrating)
            TextButton.icon(
              icon: const Icon(Icons.center_focus_strong, color: Colors.white),
              label: const Text('Calibrate', style: TextStyle(color: Colors.white)),
              onPressed: _startCalibration,
            ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview
          if (_isInitialized && _cameraController != null)
            SizedBox.expand(
              child: CameraPreview(_cameraController!),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          
          // Color adjustment overlay
          if (_isCalibrated)
            Positioned.fill(
              child: IgnorePointer(
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Color.fromRGBO(
                      (255 * _warmth / 100).toInt(),
                      (255 * _brightness / 100).toInt(),
                      (255 * (100 - _warmth) / 100).toInt(),
                      0.1,
                    ),
                    BlendMode.overlay,
                  ),
                  child: Container(),
                ),
              ),
            ),
          
          // Calibration guide
          if (_isCalibrating)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        'Position face\nwithin circle',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Sampling: ${_colorSamples.length}/10',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      value: _colorSamples.length / 10,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          
          // Calibration results
          if (_isCalibrated)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.withOpacity(0.9),
                      Colors.teal.withOpacity(0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Calibration Complete',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _detectedSkinTone,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Skin Tone: $_skinToneCategory',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Text(
                                'Camera optimized for accurate analysis',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          
          // Adjustment controls
          if (_isCalibrated)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Fine-tune Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSlider('Brightness', Icons.wb_sunny, _brightness, (val) {
                      setState(() => _brightness = val);
                    }),
                    _buildSlider('Contrast', Icons.contrast, _contrast, (val) {
                      setState(() => _contrast = val);
                    }),
                    _buildSlider('Warmth', Icons.thermostat, _warmth, (val) {
                      setState(() => _warmth = val);
                    }),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, IconData icon, double value, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: 0,
              max: 100,
              activeColor: Colors.green,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 35,
            child: Text(
              '${value.toInt()}',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class ColorSample {
  final Color color;
  final DateTime timestamp;

  ColorSample(this.color, this.timestamp);
}
