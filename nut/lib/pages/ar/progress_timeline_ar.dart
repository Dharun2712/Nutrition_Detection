import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';

class ProgressTimelineAR extends StatefulWidget {
  const ProgressTimelineAR({Key? key}) : super(key: key);

  @override
  State<ProgressTimelineAR> createState() => _ProgressTimelineARState();
}

class _ProgressTimelineARState extends State<ProgressTimelineAR> {
  CameraController? _cameraController;
  bool _isInitialized = false;
  double _overlayOpacity = 0.5;
  int _selectedTimeline = 0; // 0: 1 month ago, 1: 2 months ago, 2: 3 months ago
  
  final List<HealthSnapshot> _timeline = [
    HealthSnapshot(
      DateTime.now().subtract(const Duration(days: 90)),
      'Starting Point',
      {'Iron': 0.3, 'Calcium': 0.4, 'Vitamin D': 0.5},
      Colors.red,
    ),
    HealthSnapshot(
      DateTime.now().subtract(const Duration(days: 60)),
      'Improvement Phase',
      {'Iron': 0.5, 'Calcium': 0.6, 'Vitamin D': 0.6},
      Colors.orange,
    ),
    HealthSnapshot(
      DateTime.now().subtract(const Duration(days: 30)),
      'Good Progress',
      {'Iron': 0.7, 'Calcium': 0.75, 'Vitamin D': 0.8},
      Colors.lightGreen,
    ),
    HealthSnapshot(
      DateTime.now(),
      'Current State',
      {'Iron': 0.9, 'Calcium': 0.85, 'Vitamin D': 0.9},
      Colors.green,
    ),
  ];

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
    final currentSnapshot = _timeline[_selectedTimeline];
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Progress Timeline AR'),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          // Current camera preview
          if (_isInitialized && _cameraController != null)
            SizedBox.expand(
              child: CameraPreview(_cameraController!),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          
          // Ghost overlay (representing past state)
          if (_selectedTimeline < _timeline.length - 1)
            Positioned.fill(
              child: Opacity(
                opacity: _overlayOpacity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.transparent,
                        currentSnapshot.color.withOpacity(0.3),
                        currentSnapshot.color.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          
          // Timeline selector
          Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(12),
                itemCount: _timeline.length,
                itemBuilder: (context, index) {
                  final snapshot = _timeline[index];
                  final isSelected = index == _selectedTimeline;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedTimeline = index);
                    },
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? snapshot.color
                            : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: snapshot.color,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('MMM dd').format(snapshot.date),
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            snapshot.label,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white60,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Health metrics comparison
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    currentSnapshot.color.withOpacity(0.9),
                    currentSnapshot.color.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentSnapshot.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...currentSnapshot.healthLevels.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${(entry.value * 100).toInt()}%',
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
                              value: entry.value,
                              minHeight: 10,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  if (_selectedTimeline > 0) ...[
                    const SizedBox(height: 16),
                    _buildComparison(),
                  ],
                ],
              ),
            ),
          ),
          
          // Opacity slider
          Positioned(
            top: 240,
            right: 20,
            child: RotatedBox(
              quarterTurns: 3,
              child: Container(
                width: 150,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.opacity, color: Colors.white, size: 16),
                    Expanded(
                      child: Slider(
                        value: _overlayOpacity,
                        min: 0.0,
                        max: 1.0,
                        activeColor: Colors.white,
                        onChanged: (value) {
                          setState(() => _overlayOpacity = value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparison() {
    final current = _timeline[_selectedTimeline];
    final previous = _timeline[_selectedTimeline - 1];
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Improvement Since Last Check:',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...current.healthLevels.entries.map((entry) {
            final improvement = entry.value - (previous.healthLevels[entry.key] ?? 0);
            final percentage = (improvement * 100).toInt();
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    improvement > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${entry.key}: ${improvement > 0 ? '+' : ''}$percentage%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class HealthSnapshot {
  final DateTime date;
  final String label;
  final Map<String, double> healthLevels;
  final Color color;

  HealthSnapshot(this.date, this.label, this.healthLevels, this.color);
}
