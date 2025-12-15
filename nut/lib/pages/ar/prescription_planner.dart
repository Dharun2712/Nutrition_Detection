import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class PrescriptionPlanner extends StatefulWidget {
  const PrescriptionPlanner({Key? key}) : super(key: key);

  @override
  State<PrescriptionPlanner> createState() => _PrescriptionPlannerState();
}

class _PrescriptionPlannerState extends State<PrescriptionPlanner>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isInitialized = false;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;
  
  final List<HealthTask> _tasks = [
    HealthTask(
      'Morning Iron Supplement',
      TimeOfDay(hour: 8, minute: 0),
      Icons.medication,
      Colors.red,
      'Take with vitamin C for better absorption',
    ),
    HealthTask(
      'Breakfast - High Protein',
      TimeOfDay(hour: 9, minute: 0),
      Icons.breakfast_dining,
      Colors.orange,
      'Eggs, Greek yogurt, or oatmeal',
    ),
    HealthTask(
      'Hydration Check',
      TimeOfDay(hour: 12, minute: 0),
      Icons.water_drop,
      Colors.blue,
      'Drink at least 2 glasses of water',
    ),
    HealthTask(
      'Lunch - Balanced Meal',
      TimeOfDay(hour: 13, minute: 0),
      Icons.lunch_dining,
      Colors.green,
      'Include vegetables, protein, and whole grains',
    ),
    HealthTask(
      'Afternoon Vitamin D',
      TimeOfDay(hour: 15, minute: 0),
      Icons.wb_sunny,
      Colors.amber,
      'Take with fatty food or after meal',
    ),
    HealthTask(
      'Evening Walk',
      TimeOfDay(hour: 18, minute: 0),
      Icons.directions_walk,
      Colors.teal,
      '20-30 minutes outdoor activity',
    ),
    HealthTask(
      'Dinner - Light & Nutritious',
      TimeOfDay(hour: 19, minute: 30),
      Icons.dinner_dining,
      Colors.purple,
      'Lean protein with vegetables',
    ),
    HealthTask(
      'Calcium Supplement',
      TimeOfDay(hour: 21, minute: 0),
      Icons.local_pharmacy,
      Colors.indigo,
      'Best absorbed before bedtime',
    ),
  ];
  
  Timer? _clockTimer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
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

  bool _isTaskDue(HealthTask task) {
    final now = _currentTime;
    final taskTime = DateTime(
      now.year,
      now.month,
      now.day,
      task.time.hour,
      task.time.minute,
    );
    final difference = taskTime.difference(now).inMinutes;
    return difference >= -30 && difference <= 30; // Within 30 minutes
  }

  bool _isTaskUpcoming(HealthTask task) {
    final now = _currentTime;
    final taskTime = DateTime(
      now.year,
      now.month,
      now.day,
      task.time.hour,
      task.time.minute,
    );
    final difference = taskTime.difference(now).inMinutes;
    return difference > 0 && difference <= 60; // Within next hour
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _floatController.dispose();
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTask = _tasks.firstWhere(
      (task) => _isTaskDue(task),
      orElse: () => _tasks.firstWhere(
        (task) => _isTaskUpcoming(task),
        orElse: () => _tasks.first,
      ),
    );
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Daily Health Planner'),
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
              // Digital clock
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.8),
                      Colors.purple.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('hh:mm a').format(_currentTime),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      DateFormat('EEEE, MMMM d').format(_currentTime),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Current/Upcoming task billboard
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatAnimation.value),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              currentTask.color.withOpacity(0.9),
                              currentTask.color.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: currentTask.color.withOpacity(0.6),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    currentTask.icon,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _isTaskDue(currentTask)
                                            ? 'NOW'
                                            : 'UPCOMING',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        currentTask.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    currentTask.time.format(context),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              currentTask.description,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
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
              
              const SizedBox(height: 20),
              
              // Today's schedule
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Today\'s Schedule',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _tasks.length,
                          itemBuilder: (context, index) {
                            final task = _tasks[index];
                            final isDue = _isTaskDue(task);
                            final isUpcoming = _isTaskUpcoming(task);
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDue
                                    ? task.color.withOpacity(0.3)
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDue || isUpcoming
                                      ? task.color
                                      : Colors.white.withOpacity(0.1),
                                  width: isDue ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    task.icon,
                                    color: task.color,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          task.title,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: isDue
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        Text(
                                          task.time.format(context),
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isDue)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: task.color,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'NOW',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class HealthTask {
  final String title;
  final TimeOfDay time;
  final IconData icon;
  final Color color;
  final String description;

  HealthTask(this.title, this.time, this.icon, this.color, this.description);
}
