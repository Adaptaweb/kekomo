import 'dart:math' as math;

import 'package:flutter/material.dart';

class WaveProgressIndicator extends StatefulWidget {
  final double percentage;
  final Color color;
  final double width;
  final double height;

  const WaveProgressIndicator({
    super.key,
    required this.percentage,
    required this.color,
    this.width = 80,
    this.height = 140,
  });

  @override
  State<WaveProgressIndicator> createState() => _WaveProgressIndicatorState();
}

class _WaveProgressIndicatorState extends State<WaveProgressIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final AnimationController _waveController;
  final Offset _bottleOffset1 = Offset.zero;
  final Offset _bottleOffset2 = const Offset(60, 0);
  List<Offset> _animList1 = [];
  List<Offset> _animList2 = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _animationController.forward();
        }
      });
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _waveController.addListener(_onWaveTick);
    _waveController.repeat();
    _animationController.forward();
  }

  void _onWaveTick() {
    setState(() {
      _animList1 = _computeWave(_bottleOffset1);
      _animList2 = _computeWave(_bottleOffset2);
    });
  }

  List<Offset> _computeWave(Offset offset) {
    final w = widget.width;
    final h = widget.height;
    final p = widget.percentage * 100;
    final result = <Offset>[];
    for (int i = -2 - offset.dx.toInt(); i <= w + 2; i++) {
      final x = i.toDouble() + offset.dx;
      final angle = (_waveController.value * 360 - i) % 360;
      final y = math.sin(angle * math.pi / 180) * 4 +
          ((100 - p) * h / 100);
      result.add(Offset(x, y));
    }
    return result;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  BorderRadius get _pillRadius => const BorderRadius.only(
        topLeft: Radius.circular(80),
        bottomLeft: Radius.circular(80),
        bottomRight: Radius.circular(80),
        topRight: Radius.circular(80),
      );

  @override
  Widget build(BuildContext context) {
    final color = widget.color;
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: _pillRadius,
            ),
          ),
          ClipPath(
            clipper: _WaveClipper(_animList1),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.2),
                    color.withValues(alpha: 0.5),
                  ],
                ),
                borderRadius: _pillRadius,
              ),
            ),
          ),
          ClipPath(
            clipper: _WaveClipper(_animList2),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.4),
                    color,
                  ],
                ),
                borderRadius: _pillRadius,
              ),
            ),
          ),
          _buildBubble(
            top: 0,
            left: 6,
            bottom: 8,
            size: 2,
            interval: const Interval(0.0, 1.0, curve: Curves.fastOutSlowIn),
            controller: _animationController,
          ),
          _buildBubble(
            left: 24,
            right: 0,
            bottom: 16,
            size: 4,
            interval: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
            controller: _animationController,
          ),
          _buildBubble(
            left: 0,
            right: 24,
            bottom: 32,
            size: 3,
            interval: const Interval(0.6, 0.8, curve: Curves.fastOutSlowIn),
            controller: _animationController,
          ),
          _buildFloatingDot(
            controller: _animationController,
            right: 20,
            top: 0,
            bottom: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildBubble({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double size,
    required Interval interval,
    required AnimationController controller,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: controller, curve: interval),
        ),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingDot({
    required AnimationController controller,
    double? right,
    double? top,
    double? bottom,
  }) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      child: Transform(
        transform: Matrix4.translationValues(
            0.0, 16 * (1.0 - controller.value), 0.0),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final alpha = controller.status == AnimationStatus.reverse
                ? 0.0
                : 0.4;
            return Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: alpha),
                shape: BoxShape.circle,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  final List<Offset> waveList;

  _WaveClipper(this.waveList);

  @override
  Path getClip(Size size) {
    final path = Path();
    if (waveList.isNotEmpty) {
      path.addPolygon(waveList, false);
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _WaveClipper oldClipper) =>
      oldClipper.waveList.length != waveList.length ||
      !_listEquals(oldClipper.waveList, waveList);

  bool _listEquals(List<Offset> a, List<Offset> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
