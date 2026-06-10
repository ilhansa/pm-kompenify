// lib/views/shared/notifikasi_screen.dart
// ✅ Sudah tersambung ke AuthController pusat untuk sinkronisasi notifikasi real-time API Laravel

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../controllers/auth_controller.dart';
import '../../models/notifikasi_model.dart';
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';

class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Mengakses data notifikasi real-time dari AuthController terpusat
    final authController = context.watch<AuthController>();
    // ✅ Menggunakan get notifikasiList sesuai isi AuthController kelompokmu
    final notifs = authController.notifikasiList;
    final unreadCount = authController.unreadCount;

    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  const Text(
                    'Notifikasi',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  if (unreadCount > 0)
                    TextButton(
                      // ✅ Menggunakan markAllNotifikasiAsRead dari AuthController pusat
                      onPressed: () => context
                          .read<AuthController>()
                          .markAllNotifikasiAsRead(),
                      child: const Text(
                        'Tandai Semua Dibaca',
                        style: TextStyle(fontSize: 12, color: AppTheme.accent),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppTheme.primary,
                backgroundColor: AppTheme.bgCard,
                // ✅ Memicu reload profil & notifikasi terpusat dari server Laravel
                onRefresh: () =>
                    context.read<AuthController>().refreshProfile(),
                child: notifs.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(
                            height: 400,
                            child: EmptyState(
                              icon: Icons.notifications_off_outlined,
                              title: 'Tidak ada notifikasi',
                              subtitle: 'Notifikasi akan muncul di sini',
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: notifs.length,
                        itemBuilder: (ctx, i) => _NotifTile(notif: notifs[i]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final NotifikasiModel notif; // ✅ Pakai NotifikasiModel asli kelompok Sultan
  const _NotifTile({required this.notif});

  @override
  Widget build(BuildContext context) {
    // Warna & Ikon dinamis berdasarkan kata kunci di judul bawaan asli kelompokmu
    Color color = AppTheme.accent;
    IconData icon = Icons.notifications_outlined;

    final judul = notif.judul.toLowerCase();
    if (judul.contains('assignment') || judul.contains('tugas')) {
      color = AppTheme.accent;
      icon = Icons.assignment_outlined;
    } else if (judul.contains('diterima') || judul.contains('lunas')) {
      color = AppTheme.accentGreen;
      icon = Icons.check_circle_outline;
    } else if (judul.contains('ditolak') || judul.contains('tolak')) {
      color = AppTheme.accentRed;
      icon = Icons.cancel_outlined;
    } else if (judul.contains('pelamar') || judul.contains('kompen')) {
      color = AppTheme.accentOrange;
      icon = Icons.task_alt_outlined;
    }

    return GestureDetector(
      onTap: () {
        if (!notif.isRead) {
          // ✅ Menggunakan markNotifikasiAsRead terpusat dari AuthController
          context.read<AuthController>().markNotifikasiAsRead(notif.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isRead ? AppTheme.bgCard : AppTheme.bgCardLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notif.isRead ? AppTheme.divider : color.withOpacity(0.4),
            width: notif.isRead ? 1 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.judul,
                          style: TextStyle(
                            fontWeight: notif.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.pesan,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    timeago.format(notif.createdAt, locale: 'id'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
