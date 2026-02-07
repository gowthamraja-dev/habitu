import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habitu/models/habit.dart';

class OrbitHabitCard extends StatefulWidget {
  final Habit habit;
  final VoidCallback onComplete;

  const OrbitHabitCard({super.key, required this.habit, required this.onComplete});

  @override
  State<OrbitHabitCard> createState() => _OrbitHabitCardState();
}

class _OrbitHabitCardState extends State<OrbitHabitCard> with SingleTickerProviderStateMixin {
  late AnimationController _fillController;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // Time to fill
    )..addListener(() {
        if (_fillController.value > 0 && _fillController.value < 1) {
          // Subtle ticking haptic while filling
          HapticFeedback.selectionClick();
        }
      });

    _fillController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _triggerSuccess();
      }
    });
  }

  void _triggerSuccess() {
    setState(() => _isCompleted = true);
    HapticFeedback.heavyImpact();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _isCompleted ? null : _fillController.forward(),
      onLongPressEnd: (_) => _isCompleted ? null : _fillController.reverse(),
      child: AnimatedScale(
        scale: _fillController.isAnimating ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: double.infinity,
          height: 240,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Stack(
                children: [
                  // Liquid Fill Layer
                  AnimatedBuilder(
                    animation: _fillController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: LiquidPainter(
                          fillLevel: _fillController.value,
                          color: Colors.blueAccent.withValues(alpha: 0.3),
                        ),
                        child: Container(),
                      );
                    },
                  ),
                  // Content Layer
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "CURRENT HABIT",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.habit.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w200,
                            fontFamily: 'Satoshi',
                          ),
                        ),
                        const Spacer(),
                        _isCompleted
                            ? const Icon(Icons.check_circle, color: Colors.white, size: 32)
                            : Text(
                                "HOLD TO COMPLETE",
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.3),
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
          ),
        ),
      ),
    );
  }
}

class LiquidPainter extends CustomPainter {
  final double fillLevel;
  final Color color;

  LiquidPainter({required this.fillLevel, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = color;
    var path = Path();

    double highPoint = size.height - (size.height * fillLevel);

    path.moveTo(0, size.height);
    path.lineTo(0, highPoint);

    // Create wave effect
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        highPoint +
            (fillLevel > 0 && fillLevel < 1
                ? sin((i / size.width * 2 * pi) + (fillLevel * 10)) * 5
                : 0),
      );
    }

    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant LiquidPainter oldDelegate) =>
      oldDelegate.fillLevel != fillLevel;
}
