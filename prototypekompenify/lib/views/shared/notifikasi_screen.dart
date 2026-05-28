import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 1. IMPORT FIRESTORE
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';

class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Ambil user aktif dari Firebase Auth langsung
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return const SizedBox();

    // 3. Pasang pipa StreamBuilder mendengarkan koleksi notifications milik user terkait
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: firebaseUser.uid)
          .orderBy('waktu', descending: true) // Urutkan dari notif paling baru
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const GradientBackground(
            child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
          );
        }

        final notifDocs = snapshot.data?.docs ?? [];

        // Fungsi aksi untuk menandai semua dokumen notif menjadi sudah dibaca
        void markAllAsRead() async {
          final batch = FirebaseFirestore.instance.batch();
          final unreadDocs = notifDocs.where((doc) => (doc.data() as Map<String, dynamic>)['sudahDibaca'] == false);
          
          for (var doc in unreadDocs) {
            batch.update(doc.reference, {'sudahDibaca': true});
          }
          await batch.commit();
        }

        bool adaNotifBelumDibaca = notifDocs.any((doc) => (doc.data() as Map<String, dynamic>)['sudahDibaca'] == false);

        return GradientBackground(
          child: SafeArea(
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(children: [
                  const Text('Notifikasi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  if (adaNotifBelumDibaca)
                    TextButton(
                      onPressed: markAllAsRead,
                      child: const Text('Tandai Semua Dibaca', style: TextStyle(fontSize: 12, color: AppTheme.accent)),
                    ),
                ]),
              ),
              Expanded(
                child: notifDocs.isEmpty
                  ? const EmptyState(icon: Icons.notifications_off_outlined, title: 'Tidak ada notifikasi', subtitle: 'Notifikasi akan muncul di sini')
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: notifDocs.length,
                      itemBuilder: (ctx, i) {
                        final data = notifDocs[i].data() as Map<String, dynamic>;
                        return _NotifTile(notifId: notifDocs[i].id, data: data);
                      },
                    ),
              ),
            ]),
          ),
        );
      },
    );
  }
}

class _NotifTile extends StatelessWidget {
  final String notifId;
  final Map<String, dynamic> data;

  const _NotifTile({required this.notifId, required this.data});

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

    String tipe = data['tipe'] ?? 'assignment';
    bool sudahDibaca = data['sudahDibaca'] ?? false;
    DateTime waktu = (data['waktu'] as Timestamp?)?.toDate() ?? DateTime.now();

    final color = colors[tipe] ?? AppTheme.textMuted;
    final icon = icons[tipe] ?? Icons.notifications_outlined;

    return GestureDetector(
      // Aksi ketuk tile untuk merubah status tunggal dokumen di Firestore menjadi dibaca
      onTap: () => FirebaseFirestore.instance.collection('notifications').doc(notifId).update({'sudahDibaca': true}),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: sudahDibaca ? AppTheme.bgCard : AppTheme.bgCardLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: sudahDibaca ? AppTheme.divider : color.withOpacity(0.4), 
            width: sudahDibaca ? 1 : 1.5
          ),
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
              Expanded(child: Text(data['judul'] ?? '', style: TextStyle(fontWeight: sudahDibaca ? FontWeight.w500 : FontWeight.w700, fontSize: 13))),
              if (!sudahDibaca) Container(width: 8, height: 8, decoration: BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle)),
            ]),
            const SizedBox(height: 4),
            Text(data['pesan'] ?? '', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(timeago.format(waktu, locale: 'id'), style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ])),
        ]),
      ),
    );
  }
}