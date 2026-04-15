import 'package:flutter/material.dart';
import 'app_theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildStatRow(),
                  const SizedBox(height: 20),
                  _buildInfoCard(),
                  const SizedBox(height: 20),
                  _buildMenuSection(context),
                  const SizedBox(height: 20),
                  _buildLogoutButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 3,
        onTap: (i) {
          if (i == 0) Navigator.pushReplacementNamed(context, '/dashboard');
        },
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return GradientHeader(
      bottomPadding: 32,
      child: Column(
        children: [
          // Back + title row
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 12),
              const Text("Profil Saya",
                  style: TextStyle(color: Colors.white,
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),

          const SizedBox(height: 24),

          // Avatar + name
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                ),
                child: const Center(
                  child: Text("KS",
                      style: TextStyle(color: Colors.white,
                          fontSize: 26, fontWeight: FontWeight.w700)),
                ),
              ),
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFFCD34D),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(Icons.edit_rounded, size: 12, color: Colors.white),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Text("Krisna Saputra",
              style: TextStyle(color: Colors.white,
                  fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text("Teknik Informatika — Angkatan 2022",
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
        ],
      ),
    );
  }

  // ── Stat row ───────────────────────────────────────────────────────────────
  Widget _buildStatRow() {
    return Row(
      children: [
        _StatCard(label: "Total Kompen", value: "120", unit: "Jam",
            icon: Icons.access_time_rounded, color: AppColors.primary),
        const SizedBox(width: 10),
        _StatCard(label: "Selesai", value: "8", unit: "Tugas",
            icon: Icons.check_circle_rounded, color: const Color(0xFF16A34A)),
        const SizedBox(width: 10),
        _StatCard(label: "Menunggu", value: "3", unit: "Tugas",
            icon: Icons.hourglass_top_rounded, color: const Color(0xFFD97706)),
      ],
    );
  }

  // ── Info card ──────────────────────────────────────────────────────────────
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Informasi Akademik", style: AppTextStyle.h3),
          const SizedBox(height: 16),
          _infoRow(Icons.badge_outlined,        "NIM",          "22.11.5555"),
          _divider(),
          _infoRow(Icons.email_outlined,        "Email",        "krisna@student.ac.id"),
          _divider(),
          _infoRow(Icons.school_outlined,       "Program Studi","Teknik Informatika"),
          _divider(),
          _infoRow(Icons.calendar_today_outlined,"Semester",    "Genap 2024/2025"),
          _divider(),
          _infoRow(Icons.person_outline_rounded, "Dosen PA",    "Dr. Budi Santoso"),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: AppColors.menuIndigoBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 17, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: AppTextStyle.caption),
          ),
          Text(value, style: AppTextStyle.body.copyWith(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _divider() => Divider(color: Colors.black.withOpacity(0.05), height: 1);

  // ── Menu section ───────────────────────────────────────────────────────────
  Widget _buildMenuSection(BuildContext context) {
    final items = [
      (Icons.history_rounded,         AppColors.menuIndigoBg, AppColors.menuIndigoFg, "Riwayat Kompen",   "Lihat semua aktivitas"),
      (Icons.upload_file_rounded,     AppColors.menuGreenBg,  AppColors.menuGreenFg,  "Upload Bukti",     "Unggah dokumen kompen"),
      (Icons.notifications_outlined,  AppColors.menuAmberBg,  AppColors.menuAmberFg,  "Notifikasi",       "Kelola preferensi notif"),
      (Icons.lock_outline_rounded,    AppColors.menuPinkBg,   AppColors.menuPinkFg,   "Ubah Password",    "Keamanan akun"),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          return Column(
            children: [
              GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: item.$2,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.$1, color: item.$3, size: 19),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.$4,
                                style: AppTextStyle.body.copyWith(fontWeight: FontWeight.w500)),
                            Text(item.$5, style: AppTextStyle.caption),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: AppColors.textHint, size: 20),
                    ],
                  ),
                ),
              ),
              if (i < items.length - 1) _divider(),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Logout button ──────────────────────────────────────────────────────────
  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            title: const Text("Keluar?", style: AppTextStyle.h2),
            content: const Text(
              "Apakah Anda yakin ingin keluar dari aplikasi?",
              style: AppTextStyle.body,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal",
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: const Text("Keluar"),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: const Color(0xFFFCA5A5)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 18),
            SizedBox(width: 8),
            Text("Keluar dari Akun",
                style: TextStyle(color: Color(0xFFDC2626),
                    fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ── Stat card ──────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label, value, unit;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label, required this.value, required this.unit,
    required this.icon, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: value,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  TextSpan(text: " $unit",
                      style: const TextStyle(fontSize: 11,
                          color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyle.caption),
          ],
        ),
      ),
    );
  }
}