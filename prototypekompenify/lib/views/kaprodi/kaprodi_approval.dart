import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/data_service.dart';
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';
import '../../models/models.dart';

// ─── Kaprodi Approval ─────────────────────────────────────────────────────────
class KaprodiApproval extends StatelessWidget {
  const KaprodiApproval({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<DataService>();
    final pending = svc.getPengajuan().where((p) => p.status == KompenStatus.disetujuiDosen).toList();
    final history = svc.getPengajuan().where((p) => p.status == KompenStatus.lunas || p.status == KompenStatus.ditolak).toList();

    return GradientBackground(
      child: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Approval Kompen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              Text('${pending.length} menunggu persetujuan', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
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
                      child: EmptyState(icon: Icons.task_alt_outlined, title: 'Tidak ada pengajuan pending'),
                    )
                  else ...[
                    ...pending.map((p) => _ApprovalCard(pengajuan: p)),
                  ],
                  if (history.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('Riwayat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    ...history.map((p) => KompenCard(pengajuan: p)),
                  ],
                ]
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  final PengajuanKompen pengajuan;
  const _ApprovalCard({required this.pengajuan});

  @override
  Widget build(BuildContext context) {
    final p = pengajuan;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryLight.withOpacity(0.4), width: 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(p.mahasiswaNama, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
          StatusBadge(label: p.statusLabel, color: p.statusColor),
        ]),
        const SizedBox(height: 4),
        Text(p.mahasiswaNim, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        const SizedBox(height: 10),
        InfoRow(icon: Icons.assignment_outlined, label: 'Assignment', value: p.assignmentJudul),
        InfoRow(icon: Icons.person_outline, label: 'Dosen', value: p.dosenNama),
        InfoRow(icon: Icons.schedule_outlined, label: 'Jam', value: '${p.jamKompen} jam'),
        InfoRow(icon: Icons.calendar_today_outlined, label: 'Tanggal', value: DateFormat('dd MMM yyyy').format(p.tanggalPengajuan)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: () => _reject(context, p),
            icon: const Icon(Icons.close_rounded, size: 16, color: AppTheme.accentRed),
            label: const Text('Tolak', style: TextStyle(color: AppTheme.accentRed, fontSize: 12)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accentRed), padding: const EdgeInsets.symmetric(vertical: 10)),
          )),
          const SizedBox(width: 10),
          Expanded(child: ElevatedButton.icon(
            onPressed: () => _approve(context, p),
            icon: const Icon(Icons.draw_outlined, size: 16),
            label: const Text('Setujui & TTD', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGreen, padding: const EdgeInsets.symmetric(vertical: 10)),
          )),
        ]),
      ]),
    );
  }

  void _approve(BuildContext context, PengajuanKompen p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Row(children: [Icon(Icons.verified_rounded, color: AppTheme.accentGreen), SizedBox(width: 8), Text('Setujui Kompen')]),
        content: Text('Setujui dan tandatangani kompen ${p.mahasiswaNama} untuk "${p.assignmentJudul}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              context.read<DataService>().approvalKaprodi(p.id, true);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🎊 Kompen disetujui! Mahasiswa mendapat notifikasi LUNAS.'), backgroundColor: AppTheme.accentGreen),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGreen),
            child: const Text('Setujui & TTD'),
          ),
        ],
      ),
    );
  }

  void _reject(BuildContext context, PengajuanKompen p) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Tolak Kompen'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Berikan alasan penolakan:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          TextField(controller: ctrl, maxLines: 3, decoration: const InputDecoration(hintText: 'Masukkan alasan...')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              context.read<DataService>().approvalKaprodi(p.id, false, catatan: ctrl.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kompen ditolak. Notifikasi dikirim ke mahasiswa.'), backgroundColor: AppTheme.accentRed),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }
}