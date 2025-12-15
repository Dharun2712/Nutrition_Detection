import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:math' as math;

class DiagnosticHeatmap extends StatefulWidget {
  const DiagnosticHeatmap({Key? key}) : super(key: key);

  @override
  State<DiagnosticHeatmap> createState() => _DiagnosticHeatmapState();
}

class _DiagnosticHeatmapState extends State<DiagnosticHeatmap> {
  CameraController? _cameraController;
  bool _isInitialized = false;
  bool _isScanning = false;
  
  // Problem zones detected
  List<ProblemZone> _problemZones = [];
  
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

  void _startScan() {
    setState(() {
      _isScanning = true;
      _problemZones.clear();
    });
    
    // Simulate AI analysis
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _problemZones = [
            ProblemZone('Under Eyes', 0.65, 'Dark circles detected - Possible iron deficiency', 0.3, 0.25, Colors.red),
            ProblemZone('Lips', 0.45, 'Pale coloration - Low hemoglobin indicator', 0.5, 0.45, Colors.orange),
            ProblemZone('Nails', 0.55, 'Brittle appearance - Calcium/Protein concerns', 0.7, 0.6, Colors.yellow),
            ProblemZone('Skin', 0.35, 'Dry patches - Vitamin D deficiency signs', 0.4, 0.35, Colors.amber),
          ];
          _isScanning = false;
        });
      }
    });
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
        title: const Text('Real-Time Diagnostic Heatmap'),
        backgroundColor: Colors.black,
        actions: [
          if (_isInitialized)
            IconButton(
              icon: Icon(_isScanning ? Icons.hourglass_empty : Icons.search),
              onPressed: _isScanning ? null : _startScan,
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
          
          // Heatmap overlays
          if (_problemZones.isNotEmpty)
            ..._problemZones.map((zone) => _buildHeatmapZone(zone)).toList(),
          
          // Scanning indicator
          if (_isScanning)
            Container(
              color: Colors.blue.withOpacity(0.2),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      'Analyzing health indicators...',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          
          // Legend
          if (_problemZones.isNotEmpty)
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Problem Zones Detected',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._problemZones.map((zone) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: zone.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${zone.name}: ${zone.description}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeatmapZone(ProblemZone zone) {
    return Positioned(
      top: MediaQuery.of(context).size.height * zone.top,
      left: MediaQuery.of(context).size.width * zone.left,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        builder: (context, value, child) {
          return Opacity(
            opacity: 0.6 * value,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    zone.color,
                    zone.color.withOpacity(0.1),
                  ],
                ),
                border: Border.all(color: zone.color, width: 2),
              ),
              child: Center(
                child: Text(
                  '${(zone.severity * 100).toInt()}%',
                  style: TextStyle(
                    color: zone.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    shadows: const [
                      Shadow(color: Colors.black, blurRadius: 2),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProblemZone {
  final String name;
  final double severity;
  final String description;
  final double top;
  final double left;
  final Color color;

  ProblemZone(this.name, this.severity, this.description, this.top, this.left, this.color);
}
