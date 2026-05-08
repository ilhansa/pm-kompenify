import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data_service.dart';
import 'app_theme.dart';
import 'common_widgets.dart';
import 'models.dart';
import 'login_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<DataService>();
    final user = svc.currentUser!;
    final allUsers = svc.getUsers();
    final mahasiswas = allUsers.where((u) => u.role == UserRole.mahasiswa).length;
    final dosens = allUsers.where((u) => u.role == UserRole.dosen).length;
    final kaprodis = allUsers.where((u) => u.role == UserRole.kaprodi).length;
    final assignments = svc.getAssignments().length;

    return GradientBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Halo, Admin! 👋', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                Text(user.nama, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              ]),
              const Spacer(),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.logout_rounded, color: AppTheme.accentRed, size: 20),
                ),
                onPressed: () {
                  svc.logout();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                },
              ),
            ]),
            const SizedBox(height: 28),
            // Stats grid
            const Text('Statistik Sistem', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                StatCard(label: 'Total Mahasiswa', value: '$mahasiswas', icon: Icons.school_rounded, color: AppTheme.accent),
                StatCard(label: 'Total Dosen', value: '$dosens', icon: Icons.person_rounded, color: AppTheme.accentGreen),
                StatCard(label: 'Total Kaprodi', value: '$kaprodis', icon: Icons.admin_panel_settings_rounded, color: AppTheme.accentOrange),
                StatCard(label: 'Total Assignment', value: '$assignments', icon: Icons.assignment_rounded, color: AppTheme.primaryLight),
              ],
            ),
            const SizedBox(height: 28),
            // Recent users
            const SectionHeader(title: 'Pengguna Terdaftar'),
            const SizedBox(height: 12),
            ...allUsers.take(5).map((u) => _UserTile(user: u)),
            if (allUsers.length > 5) ...[
              const SizedBox(height: 8),
              Center(child: Text('dan ${allUsers.length - 5} pengguna lainnya',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12))),
            ],
          ]),
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final User user;
  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final colors = {
      UserRole.admin: AppTheme.accent,
      UserRole.mahasiswa: AppTheme.accentGreen,
      UserRole.dosen: AppTheme.accentOrange,
      UserRole.kaprodi: AppTheme.primaryLight,
    };
    final color = colors[user.role]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
          child: Center(child: Text(user.nama[0], style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 16))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(user.nama, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13), overflow: TextOverflow.ellipsis),
          Text(user.nim, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        ])),
        StatusBadge(label: user.roleLabel, color: color),
      ]),
    );
  }
}