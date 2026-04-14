import 'package:flutter/material.dart';
import 'app_theme.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  // Data dummy untuk notifikasi
  static const _notifications = [
    (
      'Tugas Baru Ditambahkan',
      'Dosen Dr. Budi Santoso menambahkan tugas "Input Data Inventaris Lab".',
      'Baru',
      '10 Menit lalu',
      Icons.assignment_ind_rounded,
      AppColors.blueBg,
      AppColors.blueText,
    ),
    (
      'Bukti Kompen Divalidasi',
      'Selamat! Bukti kompen "Bersih Ruang Baca" telah disetujui oleh Kaprodi.',
      'Selesai',
      '2 Jam lalu',
      Icons.check_circle_rounded,
      AppColors.greenBg,
      AppColors.greenText,
    ),
    (
      'Peringatan Kompen',
      'Total kompen Anda mencapai 120 jam. Segera selesaikan sebelum UAS.',
      'Penting',
      'Kemarin',
      Icons.warning_amber_rounded,
      AppColors.redBg,
      AppColors.redText,
    ),
    (
      'Sistem Maintenance',
      'Aplikasi akan mengalami pemeliharaan rutin pada pukul 00:00 WIB.',
      'Info',
      '2 hari lalu',
      Icons.info_outline_rounded,
      AppColors.yellowBg,
      AppColors.yellowText,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final n = _notifications[index];
                return _NotificationCard(
                  title: n.$1,
                  desc: n.$2,
                  tag: n.$3,
                  time: n.$4,
                  icon: n.$5,
                  tagBg: n.$6,
                  tagFg: n.$7,
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2, // Index Notif
        onTap: (i) {
          if (i == 0) Navigator.pushReplacementNamed(context, '/dashboard');
          if (i == 3) Navigator.pushReplacementNamed(context, '/profile');
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return GradientHeader(
      bottomPadding: 24,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Notifikasi",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Text(
                "Tandai baca",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String title, desc, tag, time;
  final IconData icon;
  final Color tagBg, tagFg;

  const _NotificationCard({
    required this.title,
    required this.desc,
    required this.tag,
    required this.time,
    required this.icon,
    required this.tagBg,
    required this.tagFg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: tagBg.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: tagFg, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusPill(label: tag, bg: tagBg, fg: tagFg),
                    Text(time, style: AppTextStyle.caption),
                  ],
                ),
                const SizedBox(height: 8),
                Text(title, style: AppTextStyle.h3.copyWith(fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: AppTextStyle.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
