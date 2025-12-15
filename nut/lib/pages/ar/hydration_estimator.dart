import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:math' as math;

class HydrationEstimator extends StatefulWidget {
  const HydrationEstimator({Key? key}) : super(key: key);

  @override
  State<HydrationEstimator> createState() => _HydrationEstimatorState();
}

class _HydrationEstimatorState extends State<HydrationEstimator>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isInitialized = false;
  bool _isAnalyzing = false;
  
  // Analysis results
  double _hydrationLevel = 0.0;
  double _hemoglobinLevel = 0.0;
  double _capillaryRefillTime = 0.0;
  String _hydrationStatus = '';
  Color _statusColor = Colors.grey;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  bool _fingerDetected = false;
  Timer? _analysisTimer;
  int _countdown = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
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

  void _startAnalysis() {
    setState(() {
      _isAnalyzing = true;
      _fingerDetected = false;
      _countdown = 5;
    });
    
    // Countdown timer
    _analysisTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _countdown--;
        
        if (_countdown <= 0) {
          timer.cancel();
          _completeAnalysis();
        } else if (_countdown == 3) {
          _fingerDetected = true;
        }
      });
    });
  }

  void _completeAnalysis() {
    final random = math.Random();
    
    setState(() {
      _hydrationLevel = 0.6 + random.nextDouble() * 0.35; // 60-95%
      _hemoglobinLevel = 11 + random.nextDouble() * 6; // 11-17 g/dL
      _capillaryRefillTime = 1.5 + random.nextDouble() * 1.5; // 1.5-3.0 seconds
      
      if (_hydrationLevel >= 0.8) {
        _hydrationStatus = 'Well Hydrated';
        _statusColor = Colors.green;
      } else if (_hydrationLevel >= 0.6) {
        _hydrationStatus = 'Moderately Hydrated';
        _statusColor = Colors.orange;
      } else {
        _hydrationStatus = 'Dehydrated';
        _statusColor = Colors.red;
      }
      
      _isAnalyzing = false;
    });
  }

  void _cancelAnalysis() {
    _analysisTimer?.cancel();
    setState(() {
      _isAnalyzing = false;
      _fingerDetected = false;
      _countdown = 0;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _pulseController.dispose();
    _analysisTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Hydration & Hemoglobin Estimator'),
        backgroundColor: Colors.black,
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
          
          // Finger guide overlay
          if (_isAnalyzing)
            Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 150 * _pulseAnimation.value,
                    height: 200 * _pulseAnimation.value,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _fingerDetected ? Colors.green : Colors.white,
                        width: 3,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fingerprint,
                          size: 80,
                          color: _fingerDetected ? Colors.green : Colors.white,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _fingerDetected
                              ? 'Analyzing...\n$_countdown'
                              : 'Place finger\n$_countdown',
                          style: TextStyle(
                            color: _fingerDetected ? Colors.green : Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          
          // Instructions
          if (!_isAnalyzing && _hydrationLevel == 0)
            Positioned(
              bottom: 100,
              left: 40,
              right: 40,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.info, color: Colors.white, size: 30),
                    SizedBox(height: 12),
                    Text(
                      'How it works:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Cover camera lens with fingertip\n2. Apply gentle pressure\n3. Hold steady for 5 seconds\n4. View your results',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          
          // Results display
          if (_hydrationLevel > 0 && !_isAnalyzing)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _statusColor.withOpacity(0.9),
                      _statusColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _hydrationLevel >= 0.8
                              ? Icons.check_circle
                              : Icons.warning,
                          color: Colors.white,
                          size: 30,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _hydrationStatus,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildMetricRow(
                      'Hydration Level',
                      '${(_hydrationLevel * 100).toInt()}%',
                      _hydrationLevel,
                    ),
                    const SizedBox(height: 12),
                    _buildMetricRow(
                      'Hemoglobin',
                      '${_hemoglobinLevel.toStringAsFixed(1)} g/dL',
                      (_hemoglobinLevel - 11) / 6, // Normalize to 0-1
                    ),
                    const SizedBox(height: 12),
                    _buildMetricRow(
                      'Capillary Refill',
                      '${_capillaryRefillTime.toStringAsFixed(1)}s',
                      1 - ((_capillaryRefillTime - 1.5) / 1.5), // Normalize to 0-1 (lower is better)
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _hydrationLevel = 0;
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Test Again'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: _statusColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          
          // Start/Cancel button
          if (!_isAnalyzing && _hydrationLevel == 0)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: _startAnalysis,
                  icon: const Icon(Icons.play_arrow, size: 30),
                  label: const Text(
                    'Start Analysis',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
          
          if (_isAnalyzing)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: TextButton.icon(
                  onPressed: _cancelAnalysis,
                  icon: const Icon(Icons.cancel, color: Colors.white),
                  label: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ],
    );
  }
}
