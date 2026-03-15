import 'dart:math';
import 'package:flutter/material.dart';

class SpaceBackground extends StatefulWidget {
  const SpaceBackground({super.key});
  @override
  State<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 60))
      ..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, __) => CustomPaint(
      painter: _SpacePainter(_ctrl.value),
      size: Size.infinite,
    ),
  );
}

class _SpacePainter extends CustomPainter {
  final double t;
  _SpacePainter(this.t);

  static final _rng   = Random(42);
  static final _stars = List.generate(280, (_) => _Star(_rng));
  static final _planets = [
    _Planet(orbitR: 0.08, size: 0.010, speed: 0.009,  angle: 0.5,  color: const Color(0xFFB5B5B5), name: 'mercury'),
    _Planet(orbitR: 0.13, size: 0.018, speed: 0.006,  angle: 2.1,  color: const Color(0xFFE8C87A), name: 'venus'),
    _Planet(orbitR: 0.19, size: 0.022, speed: 0.0045, angle: 4.0,  color: const Color(0xFF4B9EFF), name: 'earth'),
    _Planet(orbitR: 0.25, size: 0.016, speed: 0.003,  angle: 1.3,  color: const Color(0xFFD45B2E), name: 'mars'),
    _Planet(orbitR: 0.36, size: 0.052, speed: 0.0019, angle: 0.9,  color: const Color(0xFFC8A870), name: 'jupiter'),
    _Planet(orbitR: 0.47, size: 0.044, speed: 0.0013, angle: 3.5,  color: const Color(0xFFE8D898), name: 'saturn', hasRings: true),
    _Planet(orbitR: 0.56, size: 0.030, speed: 0.0008, angle: 5.8,  color: const Color(0xFF7DE8E8), name: 'uranus'),
    _Planet(orbitR: 0.65, size: 0.028, speed: 0.0005, angle: 2.7,  color: const Color(0xFF3040E0), name: 'neptune'),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final W = size.width;
    final H = size.height;

    // ── Fond ────────────────────────────────────────────────────────────────
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 1.4,
        colors: const [Color(0xFF04061A), Color(0xFF010208), Color(0xFF000005)],
      ).createShader(Rect.fromLTWH(0, 0, W, H));
    canvas.drawRect(Rect.fromLTWH(0, 0, W, H), bgPaint);

    // ── Voie Lactée ─────────────────────────────────────────────────────────
    canvas.save();
    canvas.translate(W * 0.5, H * 0.5);
    canvas.rotate(-0.18);
    final mwPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF8090B8).withOpacity(0.04),
          const Color(0xFFB0C0FF).withOpacity(0.08),
          const Color(0xFFD0E0FF).withOpacity(0.1),
          const Color(0xFFB0C0FF).withOpacity(0.06),
          const Color(0xFF8090B8).withOpacity(0.03),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(-W * 1.5, -H * 0.12, W * 3, H * 0.24));
    canvas.drawRect(Rect.fromLTWH(-W * 1.5, -H * 0.12, W * 3, H * 0.24), mwPaint);
    canvas.restore();

    // ── Étoiles ──────────────────────────────────────────────────────────────
    for (final s in _stars) {
      final tw = 0.55 + 0.45 * sin(s.twPhase + t * s.twSpeed * 60 * 2 * pi);
      final paint = Paint()
        ..color = s.color.withOpacity((s.alpha * tw).clamp(0.0, 1.0))
        ..maskFilter = s.size > 1.2 ? MaskFilter.blur(BlurStyle.normal, s.size * 0.8) : null;
      canvas.drawCircle(Offset(s.x * W, s.y * H), s.size * tw, paint);
    }

    // ── Centre du système solaire (bas-gauche) ───────────────────────────────
    final sunX = W * 0.06;
    final sunY = H * 0.55;
    final sunR = W * 0.038;

    // Halo soleil
    for (int i = 4; i >= 1; i--) {
      final r = sunR * (1 + i * 0.8);
      final opacity = 0.04 / i;
      canvas.drawCircle(Offset(sunX, sunY), r,
          Paint()..color = const Color(0xFFFFC832).withOpacity(opacity)
                 ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.5));
    }

    // Soleil
    final sunPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        colors: const [Color(0xFFFFFDE0), Color(0xFFFFE060), Color(0xFFFF9A00), Color(0xFFE05000)],
      ).createShader(Rect.fromCircle(center: Offset(sunX, sunY), radius: sunR));
    canvas.drawCircle(Offset(sunX, sunY), sunR, sunPaint);

    // Orbites
    final orbitPaint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    for (final p in _planets) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(sunX, sunY),
            width: p.orbitR * W * 2, height: p.orbitR * W * 2 * 0.36),
        orbitPaint,
      );
    }

    // Planètes
    for (final p in _planets) {
      final angle = p.angle + t * 60 * p.speed * 2 * pi;
      final px = sunX + cos(angle) * p.orbitR * W;
      final py = sunY + sin(angle) * p.orbitR * W * 0.36;
      final r  = p.size * W;

      // Anneaux Saturne (derrière)
      if (p.hasRings) _drawRings(canvas, px, py, r, true);

      // Planète
      _drawPlanet(canvas, px, py, r, p.color, t * p.speed * 30);

      // Anneaux Saturne (devant)
      if (p.hasRings) _drawRings(canvas, px, py, r, false);
    }
  }

  void _drawPlanet(Canvas canvas, double x, double y, double r, Color color, double rot) {
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: Offset(x, y), radius: r)));

    // Texture simulée avec gradient
    final base = Paint()
      ..shader = LinearGradient(
        colors: [color.withOpacity(0.7), color, color.withOpacity(0.6)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: r));
    canvas.drawCircle(Offset(x, y), r, base);

    canvas.restore();

    // Reflet spéculaire
    canvas.drawCircle(
      Offset(x - r * 0.35, y - r * 0.35), r * 0.3,
      Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Ombre (côté nuit)
    canvas.drawCircle(
      Offset(x + r * 0.4, y + r * 0.3), r,
      Paint()
        ..color = Colors.black.withOpacity(0.45)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.5),
    );
  }

  void _drawRings(Canvas canvas, double x, double y, double r, bool behind) {
    canvas.save();
    canvas.scale(1, 0.35);
    final yn = y / 0.35;
    for (int i = 0; i < 3; i++) {
      final ri = r * (1.25 + i * 0.25);
      final ro = r * (1.48 + i * 0.25);
      final opacity = 0.2 - i * 0.05;
      final path = Path();
      if (behind) {
        path.addOval(Rect.fromCircle(center: Offset(x, yn), radius: ro));
        path.addOval(Rect.fromCircle(center: Offset(x, yn), radius: ri));
        path.fillType = PathFillType.evenOdd;
        // Seulement la moitié "derrière" (arc supérieur)
        canvas.save();
        canvas.clipRect(Rect.fromLTRB(x - ro - 5, yn - ro - 5, x + ro + 5, yn));
      } else {
        path.addOval(Rect.fromCircle(center: Offset(x, yn), radius: ro));
        path.addOval(Rect.fromCircle(center: Offset(x, yn), radius: ri));
        path.fillType = PathFillType.evenOdd;
        canvas.save();
        canvas.clipRect(Rect.fromLTRB(x - ro - 5, yn, x + ro + 5, yn + ro + 5));
      }
      canvas.drawPath(path, Paint()..color = const Color(0xFFD2B982).withOpacity(opacity));
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SpacePainter old) => old.t != t;
}

class _Star {
  final double x, y, size, alpha, twPhase, twSpeed;
  final Color color;

  _Star(Random rng)
      : x       = rng.nextDouble(),
        y       = rng.nextDouble(),
        size    = rng.nextDouble() < 0.08 ? rng.nextDouble() * 1.8 + 0.8 : rng.nextDouble() * 0.8 + 0.2,
        alpha   = rng.nextDouble() * 0.85 + 0.15,
        twPhase = rng.nextDouble() * pi * 2,
        twSpeed = rng.nextDouble() * 0.02 + 0.003,
        color   = rng.nextDouble() < 0.1
            ? (rng.nextBool() ? const Color(0xFF90C0FF) : const Color(0xFFFFD080))
            : Colors.white;
}

class _Planet {
  final double orbitR, size, speed, angle;
  final Color color;
  final String name;
  final bool hasRings;

  const _Planet({
    required this.orbitR, required this.size, required this.speed,
    required this.angle,  required this.color, required this.name,
    this.hasRings = false,
  });
}
