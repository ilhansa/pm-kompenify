import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'data_service.dart';
import 'app_theme.dart';
import 'common_widgets.dart';
import 'models.dart';

class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<DataService>();
    final user = svc.currentUser;
    if (user == null) return const SizedBox();
    final notifs = svc.getNotifikasi(user.id);

    return GradientBackground(
      child: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(children: [
              const Text('Notifikasi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const Spacer(),
              if (notifs.any((n) => !n.sudahDibaca))
                TextButton(
                  onPressed: () => svc.markAllAsRead(user.id),
                  child: const Text('Tandai Semua Dibaca', style: TextStyle(fontSize: 12, color: AppTheme.accent)),
                ),
            ]),
          ),
          Expanded(
            child: notifs.isEmpty
              ? const EmptyState(icon: Icons.notifications_off_outlined, title: 'Tidak ada notifikasi', subtitle: 'Notifikasi akan muncul di sini')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: notifs.length,
                  itemBuilder: (ctx, i) => _NotifTile(notif: notifs[i]),
                ),
          ),
        ]),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final Notifikasi notif;
  const _NotifTile({required this.notif});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'assignment': AppTheme.accent,
      'kompen': AppTheme.accentOrange,
      'ttd': AppTheme.accentGreen,
      'approval': AppTheme.primaryLight,
    };
    final icons = {
      'assignment': Icons.assignment_outlined,
      'kompen': Icons.task_alt_outlined,
      'ttd': Icons.draw_outlined,
      'approval': Icons.verified_outlined,
    };

    final color = colors[notif.tipe] ?? AppTheme.textMuted;
    final icon = icons[notif.tipe] ?? Icons.notifications_outlined;

    return GestureDetector(
      onTap: () => context.read<DataService>().markAsRead(notif.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.sudahDibaca ? AppTheme.bgCard : AppTheme.bgCardLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: notif.sudahDibaca ? AppTheme.divider : color.withOpacity(0.4), width: notif.sudahDibaca ? 1 : 1.5),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(notif.judul, style: TextStyle(fontWeight: notif.sudahDibaca ? FontWeight.w500 : FontWeight.w700, fontSize: 13))),
              if (!notif.sudahDibaca) Container(width: 8, height: 8, decoration: BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle)),
            ]),
            const SizedBox(height: 4),
            Text(notif.pesan, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(timeago.format(notif.waktu, locale: 'id'), style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ])),
        ]),
      ),
    );
  }
}