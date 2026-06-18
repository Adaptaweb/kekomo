import 'dart:math' as math;
import 'package:flutter/material.dart';

class CircleData {
  final double radius;
  final double centerX;
  final double centerY;
  final double orbitRadius;
  final Color color;

  const CircleData({
    required this.radius,
    required this.centerX,
    required this.centerY,
    required this.orbitRadius,
    required this.color,
  });
}

class AnimatedCirclesPainter extends CustomPainter {
  final List<Animation<double>> animations;
  final List<CircleData> circles;

  AnimatedCirclesPainter(this.animations, this.circles);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < circles.length; i++) {
      final circle = circles[i];
      final animation = animations[i];

      final centerX = size.width * circle.centerX;
      final centerY = size.height * circle.centerY;

      final x = centerX + circle.orbitRadius * math.cos(animation.value);
      final y = centerY + circle.orbitRadius * math.sin(animation.value);

      final paint = Paint()
        ..color = circle.color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

      canvas.drawCircle(Offset(x, y), circle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(AnimatedCirclesPainter oldDelegate) => true;
}

class AnimatedBackground extends StatefulWidget {
  final Brightness brightness;

  const AnimatedBackground({super.key, required this.brightness});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  late List<CircleData> _circles;

  @override
  void initState() {
    super.initState();
    _initializeCircles(widget.brightness);
  }

  @override
  void didUpdateWidget(AnimatedBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.brightness != widget.brightness) {
      for (var c in _controllers) {
        c.dispose();
      }
      _initializeCircles(widget.brightness);
    }
  }

  void _initializeCircles(Brightness brightness) {
    _controllers = [];
    _animations = [];
    _circles = [];

    final bool isLight = brightness == Brightness.light;

    final colors = isLight
        ? [
            const Color(0xFFB3D4FC),
            const Color(0xFF90C2FA),
            const Color(0xFF4A90E2),
            const Color(0xFF1A73E8),
            const Color(0xFFB3D4FC),
            const Color(0xFF90C2FA),
          ]
        : [
            const Color(0xFF4A90E2),
            const Color(0xFF5AC8FA),
            const Color(0xFF0E4D92),
            const Color(0xFF6B5BFF),
            const Color(0xFF4A90E2),
            const Color(0xFF5AC8FA),
          ];

    final alphas = isLight
        ? [0.14, 0.12, 0.10, 0.08, 0.09, 0.11]
        : [0.30, 0.25, 0.35, 0.20, 0.28, 0.22];

    final specs = [
      (90.0, 0.15, 0.20, 40.0),
      (110.0, 0.80, 0.30, 50.0),
      (75.0, 0.30, 0.70, 35.0),
      (95.0, 0.75, 0.80, 45.0),
      (60.0, 0.55, 0.45, 30.0),
      (80.0, 0.10, 0.85, 38.0),
    ];

    for (int i = 0; i < specs.length; i++) {
      final spec = specs[i];
      final controller = AnimationController(
        duration: Duration(seconds: 8 + i * 2),
        vsync: this,
      );
      final animation = Tween<double>(begin: 0, end: 2 * math.pi)
          .animate(CurvedAnimation(parent: controller, curve: Curves.linear));
      _controllers.add(controller);
      _animations.add(animation);
      _circles.add(CircleData(
        radius: spec.$1,
        centerX: spec.$2,
        centerY: spec.$3,
        orbitRadius: spec.$4,
        color: colors[i].withValues(alpha: alphas[i]),
      ));
      controller.repeat();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(_animations),
      builder: (context, child) {
        return CustomPaint(
          painter: AnimatedCirclesPainter(_animations, _circles),
          size: Size.infinite,
        );
      },
    );
  }
}

class GradientBackground extends StatelessWidget {
  final Brightness brightness;

  const GradientBackground({super.key, required this.brightness});

  @override
  Widget build(BuildContext context) {
    final isLight = brightness == Brightness.light;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLight
              ? const [
                  Color(0xFFFFFFFF),
                  Color(0xFFF0F4FA),
                  Color(0xFFE8F0FE),
                  Color(0xFFD6E6F6),
                ]
              : const [
                  Color(0xFF0A1929),
                  Color(0xFF0F2236),
                  Color(0xFF0A1F33),
                  Color(0xFF050E1A),
                ],
          stops: const [0.0, 0.35, 0.7, 1.0],
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}

class AppBackground extends StatelessWidget {
  final Brightness brightness;

  const AppBackground({super.key, required this.brightness});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GradientBackground(brightness: brightness),
        AnimatedBackground(brightness: brightness),
      ],
    );
  }
}
