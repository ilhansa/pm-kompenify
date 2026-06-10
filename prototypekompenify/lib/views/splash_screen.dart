// lib/views/splash_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
// import '../utils/app_theme.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ─── ANIMATION CONTROLLERS ───
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late AnimationController _textController;
  late AnimationController _particleController;
  late AnimationController _shimmerController;

  // ─── LOGO ANIMATIONS ───
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  // late Animation<double> _logoBlur;

  // ─── PULSE RING ANIMATIONS ───
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  // ─── TEXT ANIMATIONS ───
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _titleSpacing;

  // ─── PARTICLE / SHIMMER ───
  late Animation<double> _particleRotation;
  late Animation<double> _shimmerPosition;

  // ─── GOOGLE CLEAN COLOR PALETTE (SINKRON AGAR TIDAK MATI LAMPU) ───
  static const Color _googleBlueAccent = Color(0xFF1A73E8); // Biru Google Utama

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    // Logo: scale up + fade in (0ms - 900ms)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    // _logoBlur = Tween<double>(begin: 20.0, end: 0.0).animate(
    //   CurvedAnimation(
    //     parent: _logoController,
    //     curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    //   ),
    // );

    // Pulse rings: repeating expand + fade out
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _pulseScale = Tween<double>(
      begin: 1.0,
      end: 2.2,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));
    _pulseOpacity = Tween<double>(
      begin: 0.5,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeIn));

    // Text: slide up + letter spacing expand
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
    _titleSpacing = Tween<double>(begin: 8.0, end: 1.5).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    // Orbiting particle
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();
    _particleRotation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    // Shimmer sweep
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
    _shimmerPosition = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _pulseController.repeat();

    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 3200));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, animation, __) => const LoginScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    _particleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            Brightness.dark, // Bar ikon hitam biar keliatan di layar putih
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ─── BACKGROUND RADIAL PUTIH BERSIH ───
          _buildBackground(),

          // ─── AMBIENT GLOW BLOBS (BIRU & KUNING TIPIS) ───
          _buildAmbientGlow(),

          // ─── MAIN CONTENT ───
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogoSection(),
                const SizedBox(height: 36),
                _buildTextSection(),
              ],
            ),
          ),

          // ─── BOTTOM TAGLINE ───
          _buildBottomTagline(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.0, -0.2),
          radius: 1.4,
          colors: [
            Colors.white,
            Color(0xFFF8F9FA), // Gradasi abu-abu tipis putih khas Google
          ],
        ),
      ),
    );
  }

  Widget _buildAmbientGlow() {
    return Stack(
      children: [
        Positioned(
          top: -80,
          left: -80,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _googleBlueAccent.withOpacity(0.06),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -60,
          right: -60,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(
                    0xFFFBBC05,
                  ).withOpacity(0.05), // Kuning Google tipis
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoSection() {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulse ring (outermost)
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) => Transform.scale(
              scale: _pulseScale.value,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _googleBlueAccent.withOpacity(
                      _pulseOpacity.value * 0.3,
                    ),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // Second pulse ring
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) {
              final offset = (_pulseController.value + 0.4) % 1.0;
              final scale = 1.0 + offset * 1.2;
              final opacity = (1.0 - offset) * 0.2;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _googleBlueAccent.withOpacity(opacity),
                      width: 1.0,
                    ),
                  ),
                ),
              );
            },
          ),

          // Orbiting particle dot
          AnimatedBuilder(
            animation: _particleController,
            builder: (_, __) {
              final angle = _particleRotation.value;
              const radius = 90.0;
              final x = radius * math.cos(angle);
              final y = radius * math.sin(angle);
              return Transform.translate(
                offset: Offset(x, y),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: _googleBlueAccent,
                    boxShadow: [
                      BoxShadow(
                        // color: _googleBlueThin,
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Counter-orbiting small dot
          AnimatedBuilder(
            animation: _particleController,
            builder: (_, __) {
              final angle = -_particleRotation.value + math.pi;
              const radius = 90.0;
              final x = radius * math.cos(angle);
              final y = radius * math.sin(angle);
              return Transform.translate(
                offset: Offset(x, y),
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(
                      0xFFFBBC05,
                    ).withOpacity(0.7), // Kuning Google
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFBBC05).withOpacity(0.4),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Inner glow ring
          Container(
            width: 152,
            height: 152,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _googleBlueAccent.withOpacity(0.04),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Logo with shimmer
          AnimatedBuilder(
            animation: Listenable.merge([_logoController, _shimmerController]),
            builder: (_, __) {
              return Opacity(
                opacity: _logoOpacity.value,
                child: Transform.scale(
                  scale: _logoScale.value,
                  child: ShaderMask(
                    blendMode: BlendMode.srcATop,
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        begin: Alignment(_shimmerPosition.value - 1, 0),
                        end: Alignment(_shimmerPosition.value + 1, 0),
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.4),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ).createShader(bounds);
                    },
                    child: _buildSvgLogo(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSvgLogo() {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32.5),
        child: CustomPaint(
          size: const Size(130, 130),
          painter: _KompenifyLogoPainter(),
        ),
      ),
    );
  }

  Widget _buildTextSection() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (_, __) {
        return SlideTransition(
          position: _titleSlide,
          child: Opacity(
            opacity: _titleOpacity.value,
            child: Column(
              children: [
                Text(
                  'Kompenify',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF202124), // Warna Hitam Google
                    letterSpacing: _titleSpacing.value,
                  ),
                ),
                const SizedBox(height: 8),
                // Divider accent
                Opacity(
                  opacity: _subtitleOpacity.value,
                  child: Container(
                    width: 40,
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1),
                      gradient: const LinearGradient(
                        colors: [_googleBlueAccent, Color(0xFF4285F4)],
                      ),
                    ),
                  ),
                ),
                // Subtitle
                Opacity(
                  opacity: _subtitleOpacity.value,
                  child: Text(
                    'Aplikasi Kompen Mahasiswa',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF5F6368), // Abu-abu Gelap Google
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomTagline() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _textController,
        builder: (_, __) => Opacity(
          opacity: _subtitleOpacity.value * 0.6,
          child: Column(
            children: [
              // Loading dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  return AnimatedBuilder(
                    animation: _particleController,
                    builder: (_, __) {
                      final phase =
                          (_particleController.value + i * 0.33) % 1.0;
                      final opacity = (math.sin(
                        phase * math.pi,
                      )).clamp(0.2, 1.0);
                      return Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _googleBlueAccent.withOpacity(opacity),
                        ),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 12),
              Text(
                'Politeknik Negeri Malang',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFF80868B), // Abu-abu Terang Google
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTER: Kompenify Logo (Disesuaikan Menjadi Aksen Google Bersih)
// ─────────────────────────────────────────────────────────────────────────────
class _KompenifyLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 200.0;
    final scaleY = size.height / 200.0;
    canvas.scale(scaleX, scaleY);

    // ── Background (Putih Bersih Flat) ──
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 200, 200),
        const Radius.circular(50),
      ),
      bgPaint,
    );

    // ── Ambient ellipses ──
    _drawEllipse(canvas, 98, 22.5, 100, 44.5, const Color(0x0A202124));
    _drawEllipse(canvas, 98, 36.5, 100, 44.5, const Color(0x0D202124));

    // ── Vertical stroke (Gradient Biru Google Modern) ──
    final strokePaint1 = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF6BA5FF), Color(0xFF1A73E8)],
      ).createShader(const Rect.fromLTWH(30, 27, 80, 140))
      ..strokeWidth = 25
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path1 = Path()
      ..moveTo(46.69, 153)
      ..cubicTo(38, 104, 55, 66, 93, 40);
    canvas.drawPath(path1, strokePaint1);

    // ── Horizontal stroke (Aksen Kuning Tipis Google) ──
    final strokePaint2 = Paint()
      ..color = const Color(0xFFFBBC05)
      ..strokeWidth = 17
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path2 = Path()
      ..moveTo(46.67, 153.33)
      ..cubicTo(84.44, 157.78, 118.89, 146.67, 150, 120);
    canvas.drawPath(path2, strokePaint2);

    // ── Top circle (outer) ──
    final circleOuterPaint = Paint()..color = const Color(0xFFE8F0FE);
    canvas.drawCircle(const Offset(90, 39.5), 24.5, circleOuterPaint);

    // ── Top circle (inner white) ──
    final circleInnerPaint = Paint()..color = const Color(0xFF1A73E8);
    canvas.drawCircle(const Offset(90, 40), 13.33, circleInnerPaint);

    // ── Bottom-right circle (outer) ──
    final dotOuterPaint = Paint()..color = const Color(0xFFFEEFC3);
    canvas.drawCircle(const Offset(150.5, 120), 15.5, dotOuterPaint);

    // ── Bottom-right circle (inner) ──
    final dotInnerPaint = Paint()..color = const Color(0xFFFBBC05);
    canvas.drawCircle(const Offset(150, 120), 8, dotInnerPaint);
  }

  void _drawEllipse(
    Canvas canvas,
    double cx,
    double cy,
    double rx,
    double ry,
    Color color,
  ) {
    final paint = Paint()..color = color;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
