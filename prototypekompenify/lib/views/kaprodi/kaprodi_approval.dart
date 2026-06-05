// lib/views/kaprodi/kaprodi_approval.dart
// ✅ Sudah tersambung ke API Laravel
// Perubahan dari versi lama:
//   - Data dari svc.pengajuanMasuk (API real)
//   - Tombol "Setujui & TTD" → svc.updateStatusPengajuan(id, 'diterima')
//   - Tombol "Tolak"         → svc.updateStatusPengajuan(id, 'ditolak')

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../controllers/data_service.dart';
import '../../models/pengajuan_model.dart';
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';

class KaprodiApproval extends StatelessWidget {
  const KaprodiApproval({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<DataService>();

    final pending = svc.pengajuanMasuk.where((p) => p.status == 'pending').toList();
    final history = svc.pengajuanMasuk.where((p) => p.status != 'pending').toList();

    return GradientBackground(
      child: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Approval Kompen',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              Text('${pending.length} menunggu persetujuan',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ]),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppTheme.primary,
              backgroundColor: AppTheme.bgCard,
              onRefresh: () => context.read<DataService>().refreshDataKaprodi(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  if (pending.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: EmptyState(
                        icon: Icons.task_alt_outlined,
                        title: 'Tidak ada pengajuan pending',
                      ),
                    )
                  else
                    ...pending.map((p) => _ApprovalCard(pengajuan: p)),
                  if (history.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('Riwayat',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    ...history.map((p) => _RiwayatCard(pengajuan: p)),
                  ],
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  final PengajuanModel pengajuan;
  const _ApprovalCard({required this.pengajuan});

  @override
  Widget build(BuildContext context) {
    final p = pengajuan;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryLight.withOpacity(0.4), width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(p.mahasiswaNama ?? 'Mahasiswa',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
          StatusBadge(label: p.statusLabel, color: p.statusColor),
        ]),
        const SizedBox(height: 4),
        Text(p.mahasiswaNim ?? '-',
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        const SizedBox(height: 10),
        InfoRow(icon: Icons.assignment_outlined, label: 'Assignment', value: p.assignmentJudul ?? '-'),
        InfoRow(icon: Icons.schedule_outlined, label: 'Jam', value: '${p.assignmentJamKompen ?? 0} jam'),
        InfoRow(
          icon: Icons.calendar_today_outlined,
          label: 'Diajukan',
          value: timeago.format(DateTime.tryParse(p.createdAt) ?? DateTime.now(), locale: 'id'),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: () => _showTolakDialog(context, p),
            icon: const Icon(Icons.close_rounded, size: 16, color: AppTheme.accentRed),
            label: const Text('Tolak', style: TextStyle(color: AppTheme.accentRed, fontSize: 12)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.accentRed),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          )),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton.icon(
            onPressed: () => _showTerimaDialog(context, p),
            icon: const Icon(Icons.draw_outlined, size: 16),
            label: const Text('Setujui & TTD', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentGreen,
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          )),
        ]),
      ]),
    );
  }

  void _showTerimaDialog(BuildContext context, PengajuanModel p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Row(children: [
          Icon(Icons.verified_rounded, color: AppTheme.accentGreen),
          SizedBox(width: 8),
          Text('Setujui Kompen'),
        ]),
        content: Text(
          'Setujui dan tandatangani kompen ${p.mahasiswaNama ?? "mahasiswa"} untuk "${p.assignmentJudul ?? "-"}"?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // ✅ Kirim ke PUT /api/kaprodi/pengajuan-kompen/{id}/status
              final result = await context.read<DataService>().updateStatusPengajuan(p.id, 'diterima');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(result['success'] == true
                      ? '🎊 Kompen disetujui! Notifikasi dikirim ke mahasiswa.'
                      : '❌ ${result['message']}'),
                  backgroundColor: result['success'] == true ? AppTheme.accentGreen : AppTheme.accentRed,
                ));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGreen),
            child: const Text('Setujui & TTD'),
          ),
        ],
      ),
    );
  }

  void _showTolakDialog(BuildContext context, PengajuanModel p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Tolak Kompen'),
        content: const Text('Yakin ingin menolak pengajuan kompen ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // ✅ Kirim ke PUT /api/kaprodi/pengajuan-kompen/{id}/status
              final result = await context.read<DataService>().updateStatusPengajuan(p.id, 'ditolak');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(result['success'] == true
                      ? 'Kompen ditolak. Notifikasi dikirim ke mahasiswa.'
                      : '❌ ${result['message']}'),
                  backgroundColor: result['success'] == true ? AppTheme.accentOrange : AppTheme.accentRed,
                ));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }
}

class _RiwayatCard extends StatelessWidget {
  final PengajuanModel pengajuan;
  const _RiwayatCard({required this.pengajuan});

  @override
  Widget build(BuildContext context) {
    final p = pengajuan;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.mahasiswaNama ?? 'Mahasiswa',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 2),
          Text(p.assignmentJudul ?? '-',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ])),
        StatusBadge(label: p.statusLabel, color: p.statusColor),
      ]),
    );
  }
}