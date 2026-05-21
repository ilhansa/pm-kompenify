import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/data_service.dart';
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';
import '../../models/models.dart';
import '../admin/admin_shell.dart';
import '../mahasiswa/mahasiswa_shell.dart';
import '../dosen/dosen_shell.dart';
import '../kaprodi/kaprodi_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _nimCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;
  late AnimationController _blobCtrl;
  late Animation<double> _blobAnim;

  @override
  void initState() {
    super.initState();
    _blobCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _blobAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _blobCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _blobCtrl.dispose();
    _nimCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 800));
    final svc = context.read<DataService>();
    final ok = svc.login(_nimCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      final role = svc.currentUser!.role;
      Widget dest;
      switch (role) {
        case UserRole.admin: dest = const AdminShell(); break;
        case UserRole.mahasiswa: dest = const MahasiswaShell(); break;
        case UserRole.dosen: dest = const DosenShell(); break;
        case UserRole.kaprodi: dest = const KaprodiShell(); break;
      }
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => dest));
    } else {
      setState(() => _error = 'NIM/NIP atau password salah. Coba lagi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Stack(children: [
          // Animated blob top
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
              child: Column(children: [
                const SizedBox(height: 60),
                // Logo
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: const Icon(Icons.school_rounded, size: 44, color: Colors.white),
                ),
                const SizedBox(height: 24),
                const Text('Kompenify', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                const SizedBox(height: 6),
                const Text('Smart Kompen Mahasiswa', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                const SizedBox(height: 48),
                // Form card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.cardGradient,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Masuk', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    const Text('Gunakan NIM/NIP dan password Anda', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nimCtrl,
                      keyboardType: TextInputType.number,
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
                          icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.textMuted),
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
                        child: Row(children: [
                          const Icon(Icons.error_outline, color: AppTheme.accentRed, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_error!, style: const TextStyle(color: AppTheme.accentRed, fontSize: 12))),
                        ]),
                      ),
                    ],
                    const SizedBox(height: 24),
                    PrimaryButton(label: 'Masuk', onTap: _login, loading: _loading, icon: Icons.login_rounded),
                  ]),
                ),
                const SizedBox(height: 24),
                // Demo accounts hint
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Demo Akun (password: password123)', style: TextStyle(fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _demoRow('Admin', 'ADMIN001'),
                    _demoRow('Mahasiswa', '244107060072'),
                    _demoRow('Dosen', 'NIP001'),
                    _demoRow('Kaprodi', 'KAPRODI01'),
                  ]),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _demoRow(String role, String nim) {
    return GestureDetector(
      onTap: () => setState(() => _nimCtrl.text = nim),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [
          Text('$role: ', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          Text(nim, style: const TextStyle(fontSize: 11, color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          const Icon(Icons.touch_app, size: 10, color: AppTheme.textMuted),
        ]),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  const _Blob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}