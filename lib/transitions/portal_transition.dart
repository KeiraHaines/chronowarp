import 'dart:math' as math;
import 'package:flutter/material.dart';

const portalDuration = Duration(milliseconds: 1000);

class PortalPageRoute<T> extends PageRouteBuilder<T> {
  PortalPageRoute({
    required WidgetBuilder builder,
    Color primary = const Color(0xFFE86D1F),
    Color secondary = const Color(0xFFFFB703),
  }) : super(
         transitionDuration: portalDuration,
         reverseTransitionDuration: const Duration(milliseconds: 350),
         pageBuilder: (context, animation, secondaryAnimation) =>
             builder(context),
         transitionsBuilder: (context, animation, secondaryAnimation, child) =>
             PortalReveal(
               animation: animation,
               primary: primary,
               secondary: secondary,
               child: child,
             ),
       );
}

/// Keeps the destination mounted throughout the reveal: no auth/page-state reset
/// when the animation reaches its end.
class PortalReveal extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final Color primary, secondary;
  const PortalReveal({
    super.key,
    required this.animation,
    required this.child,
    this.primary = const Color(0xFFE86D1F),
    this.secondary = const Color(0xFFFFB703),
  });
  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedBuilder(
      animation: animation,
      child: RepaintBoundary(child: child),
      builder: (context, page) {
        final progress = reduceMotion ? 1.0 : animation.value;
        return IgnorePointer(
          ignoring: progress < 1,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipPath(clipper: _PortalClipper(progress), child: page),
              IgnorePointer(
                child: CustomPaint(
                  painter: _PortalRim(progress, primary, secondary),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PortalClipper extends CustomClipper<Path> {
  final double progress;
  _PortalClipper(this.progress);
  @override
  Path getClip(Size size) {
    final radius =
        math.sqrt(size.width * size.width + size.height * size.height) / 2 + 20;
    return Path()..addOval(
      Rect.fromCircle(
        center: size.center(Offset.zero),
        radius: radius * Curves.easeInOutCubic.transform(progress),
      ),
    );
  }

  @override
  bool shouldReclip(_PortalClipper oldClipper) =>
      progress != oldClipper.progress;
}

class _PortalRim extends CustomPainter {
  final double progress;
  final Color primary, secondary;
  _PortalRim(this.progress, this.primary, this.secondary);
  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final center = size.center(Offset.zero);
    final radius =
        (math.sqrt(size.width * size.width + size.height * size.height) / 2 +
            20) *
        Curves.easeInOutCubic.transform(progress);
    final opacity =
        (progress * 9).clamp(0.0, 1.0) *
        (1 - Curves.easeIn.transform(((progress - 0.8) / 0.2).clamp(0.0, 1.0)));
    final ring = Rect.fromCircle(center: center, radius: math.max(radius, 1));
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..color = primary.withValues(alpha: opacity * 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..shader = SweepGradient(
          colors: [primary, secondary, const Color(0xFFFFF1CF), primary],
          transform: GradientRotation(progress * math.pi * 2),
        ).createShader(ring)
        ..color = Colors.white.withValues(alpha: opacity),
    );
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..color = secondary.withValues(alpha: opacity * 0.8);
    for (var i = 0; i < 9; i++) {
      final angle = i * math.pi * 2 / 9 + progress * math.pi * 1.5;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius + 8),
        angle,
        0.28,
        false,
        arcPaint,
      );
      final point =
          center + Offset(math.cos(angle), math.sin(angle)) * (radius + 15);
      canvas.drawCircle(
        point,
        1.5,
        Paint()..color = secondary.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(_PortalRim old) =>
      progress != old.progress ||
      primary != old.primary ||
      secondary != old.secondary;
}

/// Auth changes replace the root page rather than pushing a route. Retain the
/// signed-out page only while revealing Home; sign-out removes Home immediately.
class AuthPortalTransition extends StatefulWidget {
  final bool signedIn;
  final Widget child;
  const AuthPortalTransition({
    super.key,
    required this.signedIn,
    required this.child,
  });
  @override
  State<AuthPortalTransition> createState() => _AuthPortalTransitionState();
}

class _AuthPortalTransitionState extends State<AuthPortalTransition>
    with SingleTickerProviderStateMixin {
  late final _controller =
      AnimationController(
        vsync: this,
        duration: portalDuration,
        value: 1,
      )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted && _previous != null)
          setState(() => _previous = null);
      });
  Widget? _previous;
  @override
  void didUpdateWidget(AuthPortalTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.signedIn &&
        widget.signedIn &&
        !MediaQuery.disableAnimationsOf(context)) {
      _previous = oldWidget.child;
      _controller.forward(from: 0);
    } else if (!widget.signedIn) {
      _previous = null;
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      if (_previous != null)
        Positioned.fill(
          key: const ValueKey('auth-background'),
          child: IgnorePointer(child: _previous),
        ),
      Positioned.fill(
        key: const ValueKey('auth-foreground'),
        child: PortalReveal(animation: _controller, child: widget.child),
      ),
    ],
  );
}
