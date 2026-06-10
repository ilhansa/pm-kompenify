// lib/views/auth/login_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';
import '../admin/admin_shell.dart';
import '../mahasiswa/mahasiswa_shell.dart';
import '../dosen/dosen_shell.dart';
import '../kaprodi/kaprodi_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _nimCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;
  late AnimationController _blobCtrl;
  late Animation<double> _blobAnim;
  late AnimationController _logoGlowCtrl;
  late Animation<double> _logoGlow;

  @override
  void initState() {
    super.initState();
    _blobCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _blobAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _blobCtrl, curve: Curves.easeInOut),
    );

    _logoGlowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _logoGlow = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoGlowCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _blobCtrl.dispose();
    _logoGlowCtrl.dispose();
    _nimCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = _nimCtrl.text.trim();
    final password = _passCtrl.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = 'NIM/NIP dan password tidak boleh kosong.');
      return;
    }
    setState(() { _loading = true; _error = null; });

    final dataSvc = context.read<AuthController>();
    final String? errorResult = await dataSvc.loginRestApi(username, password);

    if (!mounted) return;
    setState(() => _loading = false);

    if (errorResult == null) {
      final user = dataSvc.currentUser;
      if (user != null) {
        final roleName = user.role.name.toLowerCase();
        if (roleName == 'mhs' || roleName == 'mahasiswa') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const MahasiswaShell()));
        } else if (roleName == 'dosen') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const DosenShell()));
        } else if (roleName == 'kaprodi') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const KaprodiShell()));
        } else if (roleName == 'admin') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const AdminShell()));
        } else {
          setState(() => _error =
              'Hak akses tidak dikenali oleh sistem (Role: $roleName).');
        }
      }
    } else {
      setState(() => _error = errorResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _blobAnim,
              builder: (_, __) => Positioned(
                top: -60 + (_blobAnim.value * 20),
                left: -40,
                child: _Blob(size: 280, color: AppTheme.primaryLight.withOpacity(0.3)),
              ),
            ),
            AnimatedBuilder(
              animation: _blobAnim,
              builder: (_, __) => Positioned(
                top: -30 + (_blobAnim.value * -15),
                right: -60,
                child: _Blob(size: 220, color: AppTheme.accent.withOpacity(0.2)),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // ─── LOGO KOMPENIFY ───
                    AnimatedBuilder(
                      animation: _logoGlow,
                      builder: (_, __) => Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7B5CE8)
                                  .withOpacity(_logoGlow.value * 0.6),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                            BoxShadow(
                              color: const Color(0xFF26235C).withOpacity(0.8),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: CustomPaint(
                            size: const Size(88, 88),
                            painter: _KompenifyLogoPainter(),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      'Kompenify',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Smart Kompen Mahasiswa',
                      style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 48),

                    // ─── FORM CARD ───
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppTheme.cardGradient,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Masuk',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          const Text('Gunakan NIM/NIP dan password Anda',
                              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _nimCtrl,
                            keyboardType: TextInputType.text,
                            style: const TextStyle(color: AppTheme.textPrimary),
                            decoration: const InputDecoration(
                              labelText: 'NIM / NIP',
                              prefixIcon: Icon(Icons.badge_outlined, color: AppTheme.accent),
                              hintText: 'Masukkan NIM atau NIP',
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscure,
                            style: const TextStyle(color: AppTheme.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.accent),
                              hintText: 'Masukkan password',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppTheme.textMuted,
                                ),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.accentRed.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.accentRed.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: AppTheme.accentRed, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(_error!,
                                        style: const TextStyle(color: AppTheme.accentRed, fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          PrimaryButton(
                            label: 'Masuk',
                            onTap: _login,
                            loading: _loading,
                            icon: Icons.login_rounded,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── DEMO ACCOUNTS ───
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Demo Akun (password: password123)',
                            style: TextStyle(
                                fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          _demoRow('Admin', 'ADMIN001'),
                          _demoRow('Mahasiswa', '244107060072'),
                          _demoRow('Dosen', 'NIP001'),
                          _demoRow('Kaprodi', 'KAPRODI01'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _demoRow(String role, String nim) {
    return GestureDetector(
      onTap: () => setState(() => _nimCtrl.text = nim),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Text('$role: ',
                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            Text(nim,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            const Icon(Icons.touch_app, size: 10, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM PAINTER: Kompenify Logo
// ─────────────────────────────────────────────────────────────────────────────
class _KompenifyLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 200.0;
    final scaleY = size.height / 200.0;
    canvas.scale(scaleX, scaleY);

    // Background
    final bgPaint = Paint()..color = const Color(0xFF26235C);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, 200, 200), const Radius.circular(50)),
      bgPaint,
    );

    // Ambient ellipses
    _drawEllipse(canvas, 98, 22.5, 100, 44.5, const Color(0xFFD9D9D9).withOpacity(0.05));
    _drawEllipse(canvas, 98, 36.5, 100, 44.5, const Color(0xFFD9D9D9).withOpacity(0.10));

    // Vertical stroke (gradient lavender)
    final strokePaint1 = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFD7D2FF), Color(0xFFAFA8FF)],
      ).createShader(const Rect.fromLTWH(30, 27, 80, 140))
      ..strokeWidth = 25
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(Path()..moveTo(46.69, 153)..cubicTo(38, 104, 55, 66, 93, 40), strokePaint1);

    // Horizontal stroke (purple)
    final strokePaint2 = Paint()
      ..color = const Color(0xFF9491E0)
      ..strokeWidth = 17
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
        Path()..moveTo(46.67, 153.33)..cubicTo(84.44, 157.78, 118.89, 146.67, 150, 120),
        strokePaint2);

    // Top circle outer
    canvas.drawCircle(const Offset(90, 39.5), 24.5, Paint()..color = const Color(0xFFC4C2F2));
    // Top circle inner white
    canvas.drawCircle(const Offset(90, 40), 13.33, Paint()..color = Colors.white);
    // Bottom-right circle outer
    canvas.drawCircle(const Offset(150.5, 120), 15.5, Paint()..color = const Color(0xFF5754B8));
    // Bottom-right circle inner
    canvas.drawCircle(const Offset(150, 120), 8, Paint()..color = const Color(0xFF9491E0));

    // Shimmer blob top-left
    final blobPaint = Paint()
      ..color = const Color(0xFFF0EEFF).withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7.5);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(32, 22.5), width: 26, height: 19),
      blobPaint,
    );
  }

  void _drawEllipse(Canvas canvas, double cx, double cy, double rx, double ry, Color color) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// BLOB WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}