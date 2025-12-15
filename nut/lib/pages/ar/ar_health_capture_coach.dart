import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:math' as math;

class ARHealthCaptureCoach extends StatefulWidget {
  const ARHealthCaptureCoach({Key? key}) : super(key: key);

  @override
  State<ARHealthCaptureCoach> createState() => _ARHealthCaptureCoachState();
}

class _ARHealthCaptureCoachState extends State<ARHealthCaptureCoach>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  
  // AR Guidance state
  String _guidance = 'Initializing camera...';
  double _brightness = 0.0;
  double _distance = 0.0;
  double _stability = 0.0;
  bool _isOptimalPosition = false;
  
  // Animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // Scan zones
  List<ScanZone> _scanZones = [];
  int _currentZoneIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _scanZones = [
      ScanZone('Face', 'Center your face in the frame', Icons.face, Colors.blue),
      ScanZone('Eyes', 'Look directly at the camera', Icons.remove_red_eye, Colors.green),
      ScanZone('Nails', 'Show your fingernails clearly', Icons.back_hand, Colors.orange),
      ScanZone('Palm', 'Show your palm lines', Icons.pan_tool, Colors.purple),
    ];
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        // Use front camera
        final frontCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras!.first,
        );
        
        _cameraController = CameraController(
          frontCamera,
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        
        if (mounted) {
          setState(() {
            _isInitialized = true;
            _guidance = 'Position yourself in the frame';
          });
          _startGuidance();
        }
      }
    } catch (e) {
      setState(() {
        _guidance = 'Camera error: $e';
      });
    }
  }

  void _startGuidance() {
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        // Simulate real-time analysis
        _brightness = 50 + math.Random().nextDouble() * 50;
        _distance = 0.3 + math.Random().nextDouble() * 0.4;
        _stability = 0.7 + math.Random().nextDouble() * 0.3;
        
        _updateGuidance();
      });
    });
  }

  void _updateGuidance() {
    List<String> issues = [];
    
    if (_brightness < 60) {
      issues.add('More light needed');
    } else if (_brightness > 90) {
      issues.add('Too bright');
    }
    
    if (_distance < 0.4) {
      issues.add('Move closer');
    } else if (_distance > 0.7) {
      issues.add('Move back');
    }
    
    if (_stability < 0.8) {
      issues.add('Hold steady');
    }
    
    if (issues.isEmpty) {
      _isOptimalPosition = true;
      final zone = _scanZones[_currentZoneIndex];
      _guidance = '✓ Perfect! ${zone.instruction}';
    } else {
      _isOptimalPosition = false;
      _guidance = issues.join(' • ');
    }
  }

  void _captureZone() {
    if (_isOptimalPosition) {
      setState(() {
        if (_currentZoneIndex < _scanZones.length - 1) {
          _currentZoneIndex++;
          _guidance = 'Great! Next: ${_scanZones[_currentZoneIndex].instruction}';
        } else {
          _guidance = '✓ Scan complete! Analyzing...';
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Health scan completed successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _pulseController.dispose();
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
              SizedBox.expand(
                child: CameraPreview(_cameraController!),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            
            // AR Overlay
            if (_isInitialized) ...[
              // Guide frame
              Center(
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 300 * _pulseAnimation.value,
                      height: 400 * _pulseAnimation.value,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _isOptimalPosition ? Colors.green : Colors.white,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  },
                ),
              ),
              
              // Corner markers
              ..._buildCornerMarkers(),
              
              // Zone indicators
              Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _scanZones.asMap().entries.map((entry) {
                    final index = entry.key;
                    final zone = entry.value;
                    final isActive = index == _currentZoneIndex;
                    final isComplete = index < _currentZoneIndex;
                    
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isComplete
                            ? Colors.green.withOpacity(0.8)
                            : isActive
                                ? zone.color.withOpacity(0.8)
                                : Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isComplete ? Icons.check : zone.icon,
                        color: Colors.white,
                        size: 20,
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              // Metrics display
              Positioned(
                top: 150,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMetric('Lighting', _brightness, 100, Icons.wb_sunny),
                      const SizedBox(height: 8),
                      _buildMetric('Distance', _distance * 100, 100, Icons.straighten),
                      const SizedBox(height: 8),
                      _buildMetric('Stability', _stability * 100, 100, Icons.center_focus_strong),
                    ],
                  ),
                ),
              ),
              
              // Guidance text
              Positioned(
                bottom: 180,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isOptimalPosition
                          ? [Colors.green.withOpacity(0.9), Colors.teal.withOpacity(0.9)]
                          : [Colors.orange.withOpacity(0.9), Colors.deepOrange.withOpacity(0.9)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isOptimalPosition ? Icons.check_circle : Icons.info,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _guidance,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Capture button
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _captureZone,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isOptimalPosition
                            ? Colors.green
                            : Colors.white.withOpacity(0.5),
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isOptimalPosition ? Icons.camera : Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Progress indicator
              Positioned(
                bottom: 140,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Zone ${_currentZoneIndex + 1}/${_scanZones.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            
            // Close button
            Positioned(
              top: 20,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCornerMarkers() {
    const markerSize = 30.0;
    const markerThickness = 4.0;
    final color = _isOptimalPosition ? Colors.green : Colors.white;
    
    return [
      // Top-left
      Positioned(
        top: MediaQuery.of(context).size.height / 2 - 200,
        left: MediaQuery.of(context).size.width / 2 - 150,
        child: _buildCornerMarker(color, markerSize, markerThickness, true, true),
      ),
      // Top-right
      Positioned(
        top: MediaQuery.of(context).size.height / 2 - 200,
        right: MediaQuery.of(context).size.width / 2 - 150,
        child: _buildCornerMarker(color, markerSize, markerThickness, true, false),
      ),
      // Bottom-left
      Positioned(
        bottom: MediaQuery.of(context).size.height / 2 - 200,
        left: MediaQuery.of(context).size.width / 2 - 150,
        child: _buildCornerMarker(color, markerSize, markerThickness, false, true),
      ),
      // Bottom-right
      Positioned(
        bottom: MediaQuery.of(context).size.height / 2 - 200,
        right: MediaQuery.of(context).size.width / 2 - 150,
        child: _buildCornerMarker(color, markerSize, markerThickness, false, false),
      ),
    ];
  }

  Widget _buildCornerMarker(Color color, double size, double thickness, bool top, bool left) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: CornerMarkerPainter(color, thickness, top, left),
      ),
    );
  }

  Widget _buildMetric(String label, double value, double max, IconData icon) {
    final percentage = (value / max * 100).clamp(0, 100);
    final isGood = percentage >= 60 && percentage <= 90;
    
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  width: 100,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percentage / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isGood ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${percentage.toInt()}%',
                  style: TextStyle(
                    color: isGood ? Colors.green : Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class ScanZone {
  final String name;
  final String instruction;
  final IconData icon;
  final Color color;

  ScanZone(this.name, this.instruction, this.icon, this.color);
}

class CornerMarkerPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final bool top;
  final bool left;

  CornerMarkerPainter(this.color, this.thickness, this.top, this.left);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    if (top && left) {
      path.moveTo(size.width, 0);
      path.lineTo(0, 0);
      path.lineTo(0, size.height);
    } else if (top && !left) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!top && left) {
      path.moveTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.lineTo(0, 0);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
