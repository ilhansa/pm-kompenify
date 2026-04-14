import 'package:flutter/material.dart';
import 'app_theme.dart';

class AvailableJobsPage extends StatelessWidget {
  const AvailableJobsPage({super.key});

  // Data dummy tugas yang disesuaikan dengan format notifikasi
  static const _availableJobs = [
    ('Koreksi Tugas', 'Membantu mengoreksi tugas.', '4 Jam', Icons.dns_rounded),
    (
      'Rekap Inventaris Jurusan',
      'Mendata perangkat komputer baru yang masuk di semester genap.',
      '2 Jam',
      Icons.inventory_2_rounded,
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
              itemCount: _availableJobs.length,
              itemBuilder: (context, index) {
                final job = _availableJobs[index];
                return _JobCard(
                  title: job.$1,
                  desc: job.$2,
                  hours: job.$3,
                  icon: job.$4,
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1, // Index Tugas
        onTap: (i) {
          if (i == 0) Navigator.pushReplacementNamed(context, '/dashboard');
          if (i == 2) Navigator.pushReplacementNamed(context, '/notifications');
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
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                "Tugas Tersedia",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final String title, desc, hours;
  final IconData icon;

  const _JobCard({
    required this.title,
    required this.desc,
    required this.hours,
    required this.icon,
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
      child: Column(
        // Menggunakan Column utama agar tombol bisa Full Width di bawah
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            // Row hanya untuk Icon dan Teks Deskripsi
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: AppTextStyle.h3.copyWith(fontSize: 14),
                        ),

                        // INI KUNCINYA: Spacer bakal mendorong widget setelahnya ke ujung kanan
                        const Spacer(),

                        Text(
                          hours,
                          style: AppTextStyle.h3.copyWith(
                            color: AppColors.primary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
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

          const SizedBox(height: 16), // Jarak antara Row atas dengan tombol
          // TOMBOL SEKARANG DI LUAR ROW
          // Ini yang bikin jarak kanan dan kirinya sama (Simetris)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    10,
                  ), // Sedikit lebih bulat
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                ), // Lebih gemuk
              ),
              child: const Text(
                "Ambil Tugas",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
