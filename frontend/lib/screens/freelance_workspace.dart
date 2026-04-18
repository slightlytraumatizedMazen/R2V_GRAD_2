import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'widgets/workspace_chat_pane.dart';
import 'widgets/workspace_milestones.dart';

class FreelanceWorkspaceScreen extends StatelessWidget {
  const FreelanceWorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0414) : const Color(0xFFF8FAFC),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Layers
          Positioned.fill(child: MeshyParticleBackground(isDark: isDark)),
          Positioned.fill(child: _ReactHeroBackground(isDark: isDark)),
          
          // Foreground Content
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Graceful degradation for non-desktop sizes
                if (constraints.maxWidth < 1000) {
                  return Column(
                    children: [
                      // Glassmorphic header for mobile fallback
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black.withOpacity(0.35) : Colors.white.withOpacity(0.85),
                              border: Border(bottom: BorderSide(color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.05))),
                            ),
                            child: SafeArea(
                              bottom: false,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Workspace",
                                    style: TextStyle(
                                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Only render Chat on Mobile/Tablet for now
                      const Expanded(child: WorkspaceChatPane()),
                    ],
                  );
                }

                // Full 2-Column Desktop Layout
                return Row(
                  children: [
                    // Column 1: Chat Pane (60%)
                    const Expanded(
                      flex: 60,
                      child: WorkspaceChatPane(),
                    ),

                    VerticalDivider(width: 1, thickness: 1, color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),

                    // Column 2: Milestones & Tracker (40%)
                    const Expanded(
                      flex: 40,
                      child: WorkspaceMilestones(),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// BACKGROUND LAYERS
// ==========================================
class _ReactHeroBackground extends StatelessWidget {
  final bool isDark;
  const _ReactHeroBackground({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
        child: Stack(
          children: [
            Positioned(
              top: -150,
              right: -50,
              child: Transform.rotate(
                angle: -0.35,
                child: Row(
                  children: [
                    _GradientBlob(isDark: isDark),
                    const SizedBox(width: 50),
                    _GradientBlob(isDark: isDark),
                    const SizedBox(width: 50),
                    _GradientBlob(isDark: isDark),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -50,
              right: -150,
              child: Transform.rotate(
                angle: -0.35, 
                child: Row(
                  children: [
                    _GradientBlob(isDark: isDark),
                    const SizedBox(width: 50),
                    _GradientBlob(isDark: isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientBlob extends StatelessWidget {
  final bool isDark;
  const _GradientBlob({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.skewY(-0.7),
      child: Container(
        width: 140,
        height: 400,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark 
                ? [Colors.white.withOpacity(0.15), Colors.blue.shade300.withOpacity(0.35)]
                : [const Color(0xFFBC70FF).withOpacity(0.25), const Color(0xFF4895EF).withOpacity(0.25)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
    );
  }
}

class MeshyParticleBackground extends StatelessWidget {
  final bool isDark;
  const MeshyParticleBackground({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) => RepaintBoundary(child: _MeshyBgCore(isDark: isDark));
}

class _MeshyBgCore extends StatefulWidget {
  final bool isDark;
  const _MeshyBgCore({required this.isDark});

  @override
  State<_MeshyBgCore> createState() => _MeshyBgCoreState();
}

class _MeshyBgCoreState extends State<_MeshyBgCore> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final Random _rng = Random(42);
  Size _size = Size.zero;
  Offset _mouse = Offset.zero;
  bool _hasMouse = false;
  late List<_Particle> _ps;
  double _t = 0;

  @override
  void initState() {
    super.initState();
    _ps = <_Particle>[];
    _ticker = createTicker((elapsed) {
      _t = elapsed.inMilliseconds / 1000.0;
      if (!mounted) return;
      if (_size == Size.zero) return;
      const dt = 1 / 60;
      for (final p in _ps) {
        p.pos = p.pos + p.vel * dt;
        if (p.pos.dx < 0 || p.pos.dx > _size.width) p.vel = Offset(-p.vel.dx, p.vel.dy);
        if (p.pos.dy < 0 || p.pos.dy > _size.height) p.vel = Offset(p.vel.dx, -p.vel.dy);
        p.pos = Offset(p.pos.dx.clamp(0.0, _size.width), p.pos.dy.clamp(0.0, _size.height));
      }
      setState(() {});
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _ensureParticles(Size s) {
    if (s == Size.zero) return;
    final area = s.width * s.height;
    int target = (area / 18000).round();
    target = target.clamp(35, 95);
    if (_ps.length == target) return;
    _ps = List.generate(target, (i) {
      final pos = Offset(_rng.nextDouble() * s.width, _rng.nextDouble() * s.height);
      final speed = 8 + _rng.nextDouble() * 18;
      final ang = _rng.nextDouble() * pi * 2;
      final vel = Offset(cos(ang), sin(ang)) * speed;
      final r = 1.2 + _rng.nextDouble() * 1.9;
      return _Particle(pos: pos, vel: vel, radius: r);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final s = Size(c.maxWidth, c.maxHeight);
      if (_size != s) {
        _size = s;
        _ensureParticles(s);
      }
      return MouseRegion(
        onHover: (e) {
          _hasMouse = true;
          _mouse = e.localPosition;
        },
        onExit: (_) => _hasMouse = false,
        child: CustomPaint(
          painter: _MeshPainter(
            particles: _ps, time: _t, size: s, mouse: _mouse, hasMouse: _hasMouse, isDark: widget.isDark,
          ),
        ),
      );
    });
  }
}

class _Particle {
  Offset pos;
  Offset vel;
  final double radius;
  _Particle({required this.pos, required this.vel, required this.radius});
}

class _MeshPainter extends CustomPainter {
  final List<_Particle> particles;
  final double time;
  final Size size;
  final Offset mouse;
  final bool hasMouse;
  final bool isDark;

  _MeshPainter({
    required this.particles, required this.time, required this.size, 
    required this.mouse, required this.hasMouse, required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size _) {
    final rect = Offset.zero & size;
    final bgColors = isDark 
        ? const [Color(0xFF0F1118), Color(0xFF141625), Color(0xFF0B0D14)]
        : const [Color(0xFFF8FAFC), Color(0xFFF1F5F9), Color(0xFFE2E8F0)];

    final bg = Paint()
      ..shader = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: bgColors, stops: const [0.0, 0.55, 1.0]).createShader(rect);
    canvas.drawRect(rect, bg);

    void glowBlob(Offset c, double r, Color col, double a) {
      final p = Paint()..color = col.withOpacity(a)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90);
      canvas.drawCircle(c, r, p);
    }

    final center = Offset(size.width * 0.55, size.height * 0.35);
    final wobble = Offset(sin(time * 0.5) * 40, cos(time * 0.45) * 30);

    glowBlob(center + wobble, 280, isDark ? const Color(0xFF8A4FFF) : const Color(0xFFA855F7), isDark ? 0.18 : 0.12);
    glowBlob(
      Offset(size.width * 0.25, size.height * 0.70) + Offset(cos(time * 0.35) * 35, sin(time * 0.32) * 28),
      240, isDark ? const Color(0xFF4895EF) : const Color(0xFF38BDF8), isDark ? 0.14 : 0.10,
    );

    Offset parallax = Offset.zero;
    if (hasMouse) {
      final dx = (mouse.dx / max(1.0, size.width) - 0.5) * 18;
      final dy = (mouse.dy / max(1.0, size.height) - 0.5) * 18;
      parallax = Offset(dx, dy);
    }

    final connectDist = min(size.width, size.height) * 0.15;
    final connectDist2 = connectDist * connectDist;

    final linePaint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1;

    for (int i = 0; i < particles.length; i++) {
      final a = particles[i];
      final ap = a.pos + parallax * 0.25;
      for (int j = i + 1; j < particles.length; j++) {
        final b = particles[j];
        final bp = b.pos + parallax * 0.25;
        final dx = ap.dx - bp.dx;
        final dy = ap.dy - bp.dy;
        final d2 = dx * dx + dy * dy;
        if (d2 < connectDist2) {
          final t = 1.0 - (sqrt(d2) / connectDist);
          linePaint.color = isDark 
              ? Colors.white.withOpacity(0.06 * t)
              : const Color(0xFF8A4FFF).withOpacity(0.15 * t);
          canvas.drawLine(ap, bp, linePaint);
        }
      }
    }

    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      final pos = p.pos + parallax * 0.6;
      dotPaint.color = isDark ? Colors.white.withOpacity(0.12) : const Color(0xFF8A4FFF).withOpacity(0.25);
      canvas.drawCircle(pos, p.radius, dotPaint);
    }

    final vignetteColors = isDark
        ? [Colors.transparent, Colors.black.withOpacity(0.55)]
        : [Colors.transparent, Colors.white.withOpacity(0.4)];
        
    final vignette = Paint()
      ..shader = RadialGradient(center: Alignment.center, radius: 1.15, colors: vignetteColors, stops: const [0.55, 1.0]).createShader(rect);
    canvas.drawRect(rect, vignette);
  }

  @override
  bool shouldRepaint(covariant _MeshPainter oldDelegate) => true;
}