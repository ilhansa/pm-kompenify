// lib/views/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';
import '../admin/admin_shell.dart';
import '../dosen/dosen_shell.dart';
import '../mahasiswa/mahasiswa_shell.dart';
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

  // Variabel Animasi Background Blob
  late AnimationController _blobCtrl;
  late Animation<double> _blobAnim;

  // Variabel Animasi Logo Glow
  late AnimationController _logoGlowCtrl;
  late Animation<double> _logoGlow;

  // Kode Warna Google (Versi Tipis / Pastel)
  static const Color _googleBlueThin = Color(
    0x0F4285F4,
  ); // Biru tipis banget (~6% opacity)
  static const Color _googleYellowThin = Color(
    0x12FBBC05,
  ); // Kuning tipis banget (~7% opacity)
  static const Color _googleBlueAccent = Color(
    0xFF1A73E8,
  ); // Biru Google asli untuk aksen

  @override
  void initState() {
    super.initState();

    // Inisialisasi Animasi Blob Latar Belakang
    _blobCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _blobAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _blobCtrl, curve: Curves.easeInOut));

    // Inisialisasi Animasi Logo Glow
    _logoGlowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _logoGlow = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoGlowCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _blobCtrl.dispose();
    _logoGlowCtrl.dispose();
    _nimCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ─── LOGIKA LOGIN REST API ───
  Future<void> _login() async {
    final username = _nimCtrl.text.trim();
    final password = _passCtrl.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = 'NIM/NIP dan password tidak boleh kosong.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final dataSvc = context.read<AuthController>();
    final String? errorResult = await dataSvc.loginRestApi(username, password);

    if (!mounted) return;
    setState(() => _loading = false);

    if (errorResult == null) {
      final user = dataSvc.currentUser;
      if (user != null) {
        final roleName = user.role.name.toLowerCase();
        if (roleName == 'mhs' || roleName == 'mahasiswa') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MahasiswaShell()),
          );
        } else if (roleName == 'dosen') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DosenShell()),
          );
        } else if (roleName == 'kaprodi') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const KaprodiShell()),
          );
        } else if (roleName == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminShell()),
          );
        } else {
          setState(
            () => _error =
                'Hak akses tidak dikenali oleh sistem (Role: $roleName).',
          );
        }
      }
    } else {
      setState(() => _error = errorResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 🔵 Blob Kiri Atas
          AnimatedBuilder(
            animation: _blobAnim,
            builder: (_, __) => Positioned(
              top: -80 + (_blobAnim.value * 25),
              left: -50,
              child: _Blob(size: 300, color: _googleBlueThin),
            ),
          ),
          // 🟡 Blob Kanan Atas
          AnimatedBuilder(
            animation: _blobAnim,
            builder: (_, __) => Positioned(
              top: -40 + (_blobAnim.value * -20),
              right: -70,
              child: _Blob(size: 260, color: _googleYellowThin),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      const SizedBox(height: 50),

                      // ✅ PERBAIKAN: LOGO ASLI KOMPENIFY DARI ASSETS (DENGAN EFEK GLOW)
                      AnimatedBuilder(
                        animation: _logoGlow,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _logoGlow.value,
                            child: child,
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(
                                  'assets/images/logo.png', // ⚠️ Pastikan filenya sudah ditaruh di folder assets dan pubspec.yaml kamu ya!
                                  fit: BoxFit.cover,
                                  // errorBuilder: (context, error, stackTrace) {
                                  //   // Fallback widget jika file gambar belum di-setup di project
                                  //   return const Icon(
                                  //     Icons.school_rounded,
                                  //     size: 32,
                                  //     color: _googleBlueAccent,
                                  //   );
                                  // },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Kompenify',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.5,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Smart Kompen Mahasiswa',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 40),

                      // CARD UTAMA FLAT Putih Bersih
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w400,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Gunakan akun institusi Anda',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Input NIM / NIP
                            TextFormField(
                              controller: _nimCtrl,
                              keyboardType: TextInputType.text,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'NIM atau NIP',
                                labelStyle: TextStyle(color: Colors.black54),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: _googleBlueAccent,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black12),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Input Password
                            TextFormField(
                              controller: _passCtrl,
                              obscureText: _obscure,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: const TextStyle(
                                  color: Colors.black54,
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: _googleBlueAccent,
                                    width: 2,
                                  ),
                                ),
                                enabledBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: Colors.black45,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),
                            ),

                            if (_error != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentRed.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppTheme.accentRed.withOpacity(0.15),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: AppTheme.accentRed,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        _error!,
                                        style: const TextStyle(
                                          color: AppTheme.accentRed,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 32),

                            // PRIMARY BUTTON KELOMPOK
                            PrimaryButton(
                              label: 'Berikutnya',
                              onTap: _login,
                              loading: _loading,
                              icon: Icons.login_rounded,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // KOTAK DEMO ACCOUNTS
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.18),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Akses Cepat Uji Coba',
                              style: TextStyle(
                                fontSize: 12,
                                color: _googleBlueAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _demoRow('Mahasiswa', '244107060072'),
                            _demoRow('Dosen', 'NIP001'),
                            _demoRow('Kaprodi', 'KAPRODI01'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _demoRow(String role, String nim) {
    return GestureDetector(
      onTap: () => setState(() => _nimCtrl.text = nim),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Text(
              '$role: ',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              nim,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_forward_outlined,
              size: 12,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
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
