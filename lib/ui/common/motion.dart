import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/app_scope.dart';

/// Shared timing and curves. Enter is a touch slower than exit, and springy
/// curves are kept for small, playful things (buttons, checks), never for
/// whole pages.
abstract final class Motion {
  static const quick = 160;
  static const base = 260;
  static const slow = 420;

  static const enter = Curves.easeOutCubic;
  static const exit = Curves.easeInCubic;
  static const pop = Curves.easeOutBack;

  /// Critically damped spring, good for things that settle into place.
  static const settle = Cubic(0.2, 0.9, 0.25, 1.0);
}

/// Shrinks a little while pressed and springs back on release, so every tap
/// feels physical. Purely visual: the child still handles the tap itself.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.scale = 0.97, this.enabled = true});

  final Widget child;
  final double scale;
  final bool enabled;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v && mounted) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: context.motion(_down ? 90 : 320),
        curve: _down ? Curves.easeOut : Motion.pop,
        child: widget.child,
      ),
    );
  }
}

/// Marks the moment a screen (or a day's list) appeared. [Reveal]s inside it
/// only animate during the first moments, so scrolling back later never
/// replays the entrance.
class RevealScope extends StatefulWidget {
  const RevealScope({super.key, required this.child});

  final Widget child;

  static const window = Duration(milliseconds: 1100);

  @override
  State<RevealScope> createState() => _RevealScopeState();
}

class _RevealScopeState extends State<RevealScope> {
  final _born = DateTime.now();

  @override
  Widget build(BuildContext context) => _RevealClock(born: _born, child: widget.child);
}

class _RevealClock extends InheritedWidget {
  const _RevealClock({required this.born, required super.child});

  final DateTime born;

  @override
  bool updateShouldNotify(_RevealClock old) => old.born != born;
}

/// Fades and lifts its child into place. Give each item in a list its own
/// [index] for a gentle stagger.
class Reveal extends StatefulWidget {
  const Reveal({super.key, required this.child, this.index = 0, this.offset = 18});

  final Widget child;
  final int index;
  final double offset;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this);
  late final Animation<double> _t = CurvedAnimation(parent: _c, curve: Motion.settle);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final duration = context.motion(Motion.slow + 60);
    final born = context.dependOnInheritedWidgetOfExactType<_RevealClock>()?.born ?? _routeBirth(context);
    final fresh = born == null || DateTime.now().difference(born) < RevealScope.window;
    if (duration == Duration.zero || !fresh) {
      _c.value = 1;
      return;
    }
    _c.duration = duration;
    final delay = Duration(milliseconds: 45 * math.min(widget.index, 8));
    Future.delayed(delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) {
        final v = _t.value;
        if (v >= 1) return child!;
        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.translate(offset: Offset(0, widget.offset * (1 - v)), child: child),
        );
      },
    );
  }
}

final _routeBorn = Expando<DateTime>();

/// When no [RevealScope] is around, the first reveal on a page marks its birth.
DateTime? _routeBirth(BuildContext context) {
  final route = ModalRoute.of(context);
  if (route == null) return null;
  return _routeBorn[route] ??= DateTime.now();
}

/// Wraps each child in a [Reveal] with increasing delay.
List<Widget> staggered(List<Widget> children, {int from = 0}) => [
  for (var i = 0; i < children.length; i++) Reveal(key: children[i].key, index: from + i, child: children[i]),
];

/// Counts smoothly from the old number to the new one.
class AnimatedNumber extends StatelessWidget {
  const AnimatedNumber({super.key, required this.value, this.style, this.format});

  final num value;
  final TextStyle? style;
  final String Function(num v)? format;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.toDouble()),
      duration: context.motion(Motion.slow),
      curve: Motion.enter,
      builder: (context, v, _) {
        final shown = value is int ? v.round() : v;
        return Text(format?.call(shown) ?? '$shown', style: style);
      },
    );
  }
}

/// A burst of small dots flying outward. Plays once each time [trigger]
/// changes to a new value. Draws outside its own box and ignores touches.
class Burst extends StatefulWidget {
  const Burst({
    super.key,
    required this.trigger,
    required this.colors,
    required this.child,
    this.count = 14,
    this.radius = 46,
  });

  /// Change this (e.g. a counter) to fire the burst.
  final Object? trigger;
  final List<Color> colors;
  final Widget child;
  final int count;
  final double radius;

  @override
  State<Burst> createState() => _BurstState();
}

class _BurstState extends State<Burst> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this);
  int _seed = 0;

  @override
  void didUpdateWidget(Burst old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger && widget.trigger != null) {
      final d = context.motion(720);
      if (d == Duration.zero) return;
      _seed++;
      _c
        ..duration = d
        ..forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) => _c.isAnimating
                  ? CustomPaint(
                      painter: _BurstPainter(
                        t: _c.value,
                        seed: _seed,
                        count: widget.count,
                        radius: widget.radius,
                        colors: widget.colors,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({required this.t, required this.seed, required this.count, required this.radius, required this.colors});

  final double t;
  final int seed;
  final int count;
  final double radius;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final rnd = math.Random(seed);
    final travel = Curves.easeOutCubic.transform(t);
    final fade = 1 - Curves.easeIn.transform(t);
    final paint = Paint();

    // Soft ring that expands and fades.
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * fade
      ..color = colors.first.withValues(alpha: 0.35 * fade);
    canvas.drawCircle(center, size.shortestSide / 2 + radius * 0.35 * travel, paint);

    paint.style = PaintingStyle.fill;
    for (var i = 0; i < count; i++) {
      final angle = (i / count) * math.pi * 2 + rnd.nextDouble() * 0.5;
      final dist = size.shortestSide / 2 + radius * (0.55 + rnd.nextDouble() * 0.45) * travel;
      final p = center + Offset(math.cos(angle), math.sin(angle)) * dist;
      final r = (2.0 + rnd.nextDouble() * 2.5) * (0.4 + 0.6 * fade);
      paint.color = colors[i % colors.length].withValues(alpha: fade);
      if (i.isEven) {
        canvas.drawCircle(p, r, paint);
      } else {
        canvas.save();
        canvas.translate(p.dx, p.dy);
        canvas.rotate(angle + t * 4);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: r * 2.6, height: r * 1.2),
            Radius.circular(r),
          ),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.t != t || old.seed != seed;
}

/// Slow breathing glow behind important visuals. Breathes a few times when
/// it appears, then rests, so it never drains battery. Static when motion is
/// off.
class Breathing extends StatefulWidget {
  const Breathing({super.key, required this.builder});

  /// Receives a value that drifts between 0 and 1.
  final Widget Function(BuildContext context, double t) builder;

  @override
  State<Breathing> createState() => _BreathingState();
}

class _BreathingState extends State<Breathing> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 4));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final on = context.motion(1) != Duration.zero;
    if (on && !_c.isAnimating) {
      _c.repeat(reverse: true, count: 4);
    } else if (!on) {
      _c
        ..stop()
        ..value = 0.5;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (context, _) => widget.builder(context, Curves.easeInOut.transform(_c.value)),
  );
}

/// Page transition: the new page fades in while gently scaling up from 94%,
/// the old one fades back slightly. Calm and direction-free, so it suits
/// both push and modal-style screens.
class OvvasPageTransitionsBuilder extends PageTransitionsBuilder {
  const OvvasPageTransitionsBuilder();

  @override
  Duration get transitionDuration => const Duration(milliseconds: 380);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 280);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (context.motion(1) == Duration.zero) return child;
    final inT = CurvedAnimation(parent: animation, curve: Motion.settle, reverseCurve: Motion.exit);
    final outT = CurvedAnimation(parent: secondaryAnimation, curve: Motion.enter);
    return AnimatedBuilder(
      animation: Listenable.merge([inT, outT]),
      child: child,
      builder: (context, child) {
        final scale = (0.94 + 0.06 * inT.value) * (1 - 0.03 * outT.value);
        return Opacity(
          opacity: (inT.value * (1 - 0.35 * outT.value)).clamp(0.0, 1.0),
          child: Transform.scale(scale: scale, child: child),
        );
      },
    );
  }
}
