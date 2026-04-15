import 'package:flutter/material.dart';
import 'app_theme.dart';

class DashboardMahasiswaPage extends StatelessWidget {
  const DashboardMahasiswaPage({super.key});

  static const _avatars = [
    ('A', 'Andi', AppColors.menuIndigoFg),
    ('B', 'Budi', Color(0xFFEC4899)),
    ('C', 'Citra', Color(0xFF14B8A6)),
    ('D', 'Dani', Color(0xFFF59E0B)),
  ];

  static const _tasks = [
    (
      'Mengisi Presensi Lab',
      'Deadline: Hari ini',
      'Belum',
      AppColors.redBg,
      AppColors.redText,
      Icons.task_alt_rounded,
    ),
    (
      'Upload Bukti Kompen',
      'Dikumpulkan kemarin',
      'Menunggu',
      AppColors.yellowBg,
      AppColors.yellowText,
      Icons.upload_file_rounded,
    ),
    (
      'Validasi Kaprodi',
      'Dikirim 2 hari lalu',
      'Diproses',
      AppColors.blueBg,
      AppColors.blueText,
      Icons.verified_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildMenuRow(context),
                  const SizedBox(height: 24),
                  const SectionHeader(
                    title: "Teman / Tim",
                    action: "Lihat semua",
                  ),
                  const SizedBox(height: 12),
                  _buildAvatarRow(),
                  const SizedBox(height: 24),
                  const SectionHeader(
                    title: "Tugas Aktif",
                    action: "Lihat semua",
                  ),
                  const SizedBox(height: 12),
                  ..._tasks.map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TaskCard(
                        title: t.$1,
                        meta: t.$2,
                        status: t.$3,
                        statusBg: t.$4,
                        statusFg: t.$5,
                        icon: t.$6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (i) {
          if (i == 0) return;
          if (i == 1) {
            Navigator.pushNamed(context, '/available_jobs');
          } else if (i == 2) {
            Navigator.pushNamed(context, '/notifications');
          } else if (i == 3) {
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
    );
  }

  Widget _buildHeader() {
    return GradientHeader(
      child: Column(
        children: [
          // Greeting row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Selamat pagi,",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Krisna 👋",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Stack(
                  children: [
                    const Icon(
                      Icons.notifications_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFCD34D),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Kompen card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "TOTAL KOMPEN",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "120 Jam",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Semester Genap 2024/2025",
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: const Text(
                          "3 tugas aktif",
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

Widget _buildMenuRow(BuildContext context) {
    return Row(
      children: [
        _MenuItem(
          icon: Icons.assignment_rounded,
          label: "Tugas",
          iconBg: AppColors.menuIndigoBg,
          iconFg: AppColors.menuIndigoFg,
          onTap: () {
            // Tugas dikosongkan dulu agar tidak error
          }, 
        ),
        const SizedBox(width: 10),
        _MenuItem(
          icon: Icons.upload_file_rounded,
          label: "Upload",
          iconBg: AppColors.menuGreenBg,
          iconFg: AppColors.menuGreenFg,
          onTap: () => Navigator.pushNamed(context, '/upload'), 
        ),
        const SizedBox(width: 10),
        _MenuItem(
          icon: Icons.notifications_rounded,
          label: "Notif",
          iconBg: AppColors.menuAmberBg,
          iconFg: AppColors.menuAmberFg,
          onTap: () => Navigator.pushNamed(context, '/notifications'),
        ),
        const SizedBox(width: 10),
        _MenuItem(
          icon: Icons.person_rounded,
          label: "Profile",
          iconBg: AppColors.menuPinkBg,
          iconFg: AppColors.menuPinkFg,
          onTap: () => Navigator.pushNamed(context, '/profile'),
        ),
      ],
    );
  }

  Widget _buildAvatarRow() {
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _avatars.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) {
          final a = _avatars[i];
          return Column(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: a.$3,
                child: Text(
                  a.$1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(a.$2, style: AppTextStyle.label),
            ],
          );
        },
      ),
    );
  }
}

// ── Menu item ─────────────────────────────────────────────────────────────────
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconBg;
  final Color iconFg;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.iconBg,
    required this.iconFg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconFg, size: 22),
              ),
              const SizedBox(height: 8),
              Text(label, style: AppTextStyle.label),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Task card ─────────────────────────────────────────────────────────────────
class _TaskCard extends StatelessWidget {
  final String title, meta, status;
  final Color statusBg, statusFg;
  final IconData icon;

  const _TaskCard({
    required this.title,
    required this.meta,
    required this.status,
    required this.statusBg,
    required this.statusFg,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.menuIndigoBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyle.h3.copyWith(fontSize: 13)),
                const SizedBox(height: 2),
                Text(meta, style: AppTextStyle.caption),
              ],
            ),
          ),
          StatusPill(label: status, bg: statusBg, fg: statusFg),
        ],
      ),
    );
  }
}