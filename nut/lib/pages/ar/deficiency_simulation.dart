import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:ui' as ui;

class DeficiencySimulation extends StatefulWidget {
  const DeficiencySimulation({Key? key}) : super(key: key);

  @override
  State<DeficiencySimulation> createState() => _DeficiencySimulationState();
}

class _DeficiencySimulationState extends State<DeficiencySimulation> {
  CameraController? _cameraController;
  bool _isInitialized = false;
  String _selectedDeficiency = 'Iron';
  int _timelineMonths = 0;
  
  final Map<String, Map<String, dynamic>> _deficiencyEffects = {
    'Iron': {
      'color': Colors.red,
      'symptoms': ['Pale skin', 'Dark under-eyes', 'Brittle nails', 'Hair thinning'],
      'severity': [0.2, 0.4, 0.6, 0.8],
    },
    'Vitamin D': {
      'color': Colors.orange,
      'symptoms': ['Dull skin', 'Weak bones', 'Muscle pain', 'Fatigue signs'],
      'severity': [0.15, 0.35, 0.55, 0.75],
    },
    'Calcium': {
      'color': Colors.blue,
      'symptoms': ['Tooth issues', 'Nail problems', 'Dry skin', 'Joint concerns'],
      'severity': [0.18, 0.38, 0.58, 0.78],
    },
    'Vitamin B12': {
      'color': Colors.purple,
      'symptoms': ['Yellowing skin', 'Mouth sores', 'Numbness', 'Memory issues'],
      'severity': [0.22, 0.42, 0.62, 0.82],
    },
  };

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

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effects = _deficiencyEffects[_selectedDeficiency]!;
    final currentSeverity = _timelineMonths >= 0 && _timelineMonths < effects['severity'].length
        ? effects['severity'][_timelineMonths]
        : 0.0;
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Deficiency Simulation'),
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
          
          // Deficiency overlay effect
          if (_timelineMonths > 0)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.0,
                      colors: [
                        Colors.transparent,
                        effects['color'].withOpacity(currentSeverity * 0.3),
                      ],
                    ),
                  ),
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(
                      sigmaX: currentSeverity * 2,
                      sigmaY: currentSeverity * 2,
                    ),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
            ),
          
          // Controls
          Column(
            children: [
              const Spacer(),
              // Deficiency selector
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Select Deficiency',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: _deficiencyEffects.keys.map((def) {
                        final isSelected = def == _selectedDeficiency;
                        return ChoiceChip(
                          label: Text(def),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedDeficiency = def;
                              _timelineMonths = 0;
                            });
                          },
                          selectedColor: _deficiencyEffects[def]!['color'],
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Future Timeline',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          'Now',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Expanded(
                          child: Slider(
                            value: _timelineMonths.toDouble(),
                            min: 0,
                            max: 3,
                            divisions: 3,
                            label: _timelineMonths == 0
                                ? 'Current'
                                : '${_timelineMonths * 3} months',
                            activeColor: effects['color'],
                            onChanged: (value) {
                              setState(() {
                                _timelineMonths = value.toInt();
                              });
                            },
                          ),
                        ),
                        const Text(
                          '9 mo',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    if (_timelineMonths > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: effects['color'].withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: effects['color'],
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Predicted Symptoms (${_timelineMonths * 3} months):',
                              style: TextStyle(
                                color: effects['color'],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              effects['symptoms'][_timelineMonths],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
