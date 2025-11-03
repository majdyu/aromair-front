//ignore_for_file: unused_field, unused_local_variable
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class AssistantOrbMin extends StatefulWidget {
  const AssistantOrbMin({
    super.key,
    this.modelPath = 'assets/3d/businesswoman.glb',
    this.size = 88,
    this.initialRight = 18,
    this.initialBottom = 22,
    this.userName,
    this.yawAmplitudeDeg = 6, // tiny sway
    this.yawPeriodSec = 12, // slow and calm
    this.pitchDeg = 85,
    this.radius = 'auto',
    this.enableCaption = false, // <-- captions OFF by default
    this.captionInterval = const Duration(seconds: 18),
    this.captionDuration = const Duration(milliseconds: 2200),
    this.quotes,
  });

  final String modelPath;
  final double size;
  final double initialRight;
  final double initialBottom;
  final String? userName;

  final double yawAmplitudeDeg;
  final int yawPeriodSec;
  final double pitchDeg;
  final String radius;

  final bool enableCaption;
  final Duration captionInterval;
  final Duration captionDuration;

  final List<String>? quotes;

  @override
  State<AssistantOrbMin> createState() => _AssistantOrbMinState();
}

class _AssistantOrbMinState extends State<AssistantOrbMin>
    with TickerProviderStateMixin {
  late Offset _rb;
  Key _viewerKey = UniqueKey();
  bool _pressed = false;

  // Animations
  late final AnimationController _ringCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  )..repeat();
  late final AnimationController _breathCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);
  late final Animation<double> _breathScale = Tween<double>(
    begin: 0.994,
    end: 1.006,
  ).animate(CurvedAnimation(parent: _breathCtrl, curve: Curves.easeInOut));
  late final AnimationController _popCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
  );
  late final Animation<double> _popScale = Tween<double>(
    begin: 1.0,
    end: 0.985,
  ).animate(CurvedAnimation(parent: _popCtrl, curve: Curves.easeInOut));

  late final AnimationController _yawCtrl = AnimationController(
    vsync: this,
    duration: Duration(seconds: widget.yawPeriodSec.clamp(2, 30)),
  )..repeat();

  double get _yawDeg {
    final t = _yawCtrl.value; // 0..1
    final s = math.sin(2 * math.pi * t); // -1..1
    return s * widget.yawAmplitudeDeg; // ±deg
  }

  // Minimal caption strip (OFF by default)
  late final AnimationController _capCtrl = AnimationController(
    vsync: this,
    duration: widget.captionDuration,
  );
  late final Animation<double> _capOpacity = CurvedAnimation(
    parent: _capCtrl,
    curve: Curves.easeInOut,
  );

  Timer? _capTimer;
  int _q = 0;
  late String _caption;
  late final List<String> _quotes =
      widget.quotes ??
      const [
        "Un petit progrès chaque jour.",
        "La qualité se voit dans les détails.",
        "Mesurez. Apprenez. Améliorez.",
        "Chaque client compte.",
        "Simple. Clair. Efficace.",
      ];

  String _greet() {
    final h = DateTime.now().hour;
    final s = h < 12 ? "Bonjour" : (h < 18 ? "Bon après-midi" : "Bonsoir");
    final n = (widget.userName ?? '').trim();
    return n.isEmpty ? s : "$s, $n";
  }

  void _nextCaption({bool immediate = false}) {
    if (!widget.enableCaption) return;
    _q = (_q + 1) % _quotes.length;
    _caption = "${_greet()} • ${_quotes[_q]}";
    _capCtrl.forward(from: 0);
    if (!immediate) return;
  }

  @override
  void initState() {
    super.initState();
    _rb = Offset(widget.initialRight, widget.initialBottom);
    _caption = "${_greet()} • ${_quotes.first}";

    // Auto cycle captions (only if enabled)
    if (widget.enableCaption) {
      // show a first quick one then schedule
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _capCtrl.forward(from: 0);
      });
      _capCtrl.addStatusListener((st) {
        if (st == AnimationStatus.completed) _capCtrl.reverse();
      });
      _capTimer = Timer.periodic(widget.captionInterval, (_) => _nextCaption());
    }
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _breathCtrl.dispose();
    _popCtrl.dispose();
    _yawCtrl.dispose();
    _capCtrl.dispose();
    _capTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding;
    final size = MediaQuery.of(context).size;

    final right = _rb.dx.clamp(8, math.max(8.0, size.width - widget.size - 8));
    final bottom = _rb.dy.clamp(
      8,
      math.max(8.0, size.height - widget.size - pad.bottom - 8),
    );

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      right: right.toDouble(),
      bottom: bottom.toDouble(),
      child: GestureDetector(
        onPanUpdate: (d) => setState(() {
          _rb = Offset(_rb.dx + (-d.delta.dx), _rb.dy + (-d.delta.dy));
        }),
        onTapDown: (_) {
          setState(() => _pressed = true);
          _popCtrl.forward(from: 0);
        },
        onTapUp: (_) {
          _popCtrl.reverse();
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) setState(() => _pressed = false);
          });
        },
        onTapCancel: () {
          _popCtrl.reverse();
          setState(() => _pressed = false);
        },
        onLongPress: _openActions,
        onTap: () {
          // show a single caption on demand (still not a bubble)
          if (widget.enableCaption) {
            _caption = "${_greet()} • ${_quotes[_q]}";
            _capCtrl.forward(from: 0);
          }
        },

        child: AnimatedBuilder(
          animation: Listenable.merge([
            _ringCtrl,
            _breathCtrl,
            _popCtrl,
            _yawCtrl,
            _capCtrl,
          ]),
          builder: (_, __) {
            final scale = _breathScale.value * _popScale.value;
            final cameraOrbit =
                '${_yawDeg.toStringAsFixed(1)}deg ${widget.pitchDeg}deg ${widget.radius}';

            return Transform.scale(
              scale: scale,
              child: SizedBox(
                width: widget.size,
                height: widget.size,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // soft halo
                    _SoftHalo(size: widget.size),

                    // thin animated ring
                    _RotatingRing(size: widget.size, progress: _ringCtrl.value),

                    // 3D avatar with subtle sway
                    ClipOval(
                      child: SizedBox(
                        width: widget.size - 6,
                        height: widget.size - 6,
                        child: ModelViewer(
                          key: _viewerKey,
                          src: widget.modelPath,
                          alt: 'Assistant',
                          autoRotate: false, // no full rotation
                          cameraControls: false,
                          backgroundColor: Colors.transparent,
                          cameraOrbit: cameraOrbit, // micro yaw sway
                          minCameraOrbit:
                              '-${widget.yawAmplitudeDeg}deg ${widget.pitchDeg}deg ${widget.radius}',
                          maxCameraOrbit:
                              '${widget.yawAmplitudeDeg}deg ${widget.pitchDeg}deg ${widget.radius}',
                          disableZoom: true,
                        ),
                      ),
                    ),

                    if (widget.enableCaption)
                      Positioned(
                        top: 0,
                        bottom: 0,
                        right: widget.size + 10,
                        child: IgnorePointer(
                          ignoring: true,
                          child: Opacity(
                            opacity: _capOpacity.value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              constraints: const BoxConstraints(maxWidth: 260),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surface.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 14,
                                    spreadRadius: -6,
                                    offset: const Offset(0, 6),
                                    color: Theme.of(
                                      context,
                                    ).shadowColor.withOpacity(0.16),
                                  ),
                                ],
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outline.withOpacity(0.08),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _caption, // e.g. "Bonjour, Ali • Mesurez. Apprenez. Améliorez."
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      height: 1.2,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.92),
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openActions() {
    final t = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: t.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 26,
              spreadRadius: -8,
              offset: const Offset(0, 10),
              color: t.shadowColor.withOpacity(0.28),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: t.colorScheme.outline.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.replay_circle_filled,
                  color: t.colorScheme.primary,
                ),
                title: const Text('Réinitialiser la vue'),
                subtitle: const Text('Angle par défaut'),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _viewerKey = UniqueKey());
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftHalo extends StatelessWidget {
  const _SoftHalo({required this.size});
  final double size;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          radius: 0.75,
          colors: [t.colorScheme.primary.withOpacity(0.10), Colors.transparent],
        ),
      ),
    );
  }
}

class _RotatingRing extends StatelessWidget {
  const _RotatingRing({required this.size, required this.progress});
  final double size;
  final double progress;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final angle = progress * 2 * math.pi;
    return Transform.rotate(
      angle: angle,
      child: CustomPaint(
        size: Size.square(size),
        painter: _RingPainter(
          color1: t.colorScheme.primary,
          color2: t.colorScheme.secondary,
          thickness: 2.0,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.color1,
    required this.color2,
    required this.thickness,
  });
  final Color color1, color2;
  final double thickness;
  @override
  void paint(Canvas canvas, Size size) {
    final r = (size.shortestSide / 2) - 1.0;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: r);

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..color = color1.withOpacity(0.10);
    canvas.drawArc(rect, 0, 2 * math.pi, false, bg);

    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = thickness
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        colors: [
          color1.withOpacity(0.00),
          color1.withOpacity(0.85),
          color2.withOpacity(0.85),
          color2.withOpacity(0.00),
        ],
        stops: const [0.00, 0.08, 0.18, 0.30],
      ).createShader(rect);
    canvas.drawArc(rect, 0, 2 * math.pi, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.color1 != color1 ||
      old.color2 != color2 ||
      old.thickness != thickness;
}
