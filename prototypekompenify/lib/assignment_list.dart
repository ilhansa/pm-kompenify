import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'data_service.dart';
import 'app_theme.dart';
import 'common_widgets.dart';
import 'models.dart';

class AssignmentListScreen extends StatefulWidget {
  const AssignmentListScreen({super.key});

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  String _search = '';
  int? _filterJam;

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<DataService>();
    var assignments = svc.getAssignments();
    if (_search.isNotEmpty) {
      assignments = assignments.where((a) =>
        a.judul.toLowerCase().contains(_search.toLowerCase()) ||
        a.dosenNama.toLowerCase().contains(_search.toLowerCase())
      ).toList();
    }
    if (_filterJam != null) {
      assignments = assignments.where((a) => a.jamKompen == _filterJam).toList();
    }

    return GradientBackground(
      child: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Daftar Assignment', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('${assignments.length} assignment tersedia', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => setState(() => _search = v),
                decoration: const InputDecoration(
                  hintText: 'Cari assignment...',
                  prefixIcon: Icon(Icons.search, color: AppTheme.textMuted),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  _FilterChip(label: 'Semua', selected: _filterJam == null, onTap: () => setState(() => _filterJam = null)),
                  ...([2, 3, 4, 6].map((j) => _FilterChip(
                    label: '$j Jam',
                    selected: _filterJam == j,
                    onTap: () => setState(() => _filterJam = _filterJam == j ? null : j),
                  ))),
                ]),
              ),
            ]),
          ),
          Expanded(
            child: assignments.isEmpty
              ? const EmptyState(icon: Icons.assignment_outlined, title: 'Tidak ada assignment', subtitle: 'Belum ada assignment yang tersedia saat ini')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: assignments.length,
                  itemBuilder: (ctx, i) {
                    final a = assignments[i];
                    final sudahDaftar = a.mahasiswaTerdaftar.contains(svc.currentUser?.id);
                    return AssignmentCard(
                      assignment: a,
                      onTap: () => _showDetail(context, a),
                      trailing: sudahDaftar
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(Icons.check_circle, color: AppTheme.accentGreen, size: 16),
                              SizedBox(width: 6),
                              Text('Sudah Terdaftar', style: TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.w600, fontSize: 13)),
                            ]),
                          )
                        : a.isFull
                          ? Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(color: AppTheme.accentRed.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                              child: const Center(child: Text('Kuota Penuh', style: TextStyle(color: AppTheme.accentRed, fontWeight: FontWeight.w600, fontSize: 13))),
                            )
                          : PrimaryButton(label: 'Kerjakan', onTap: () => _pilihAssignment(context, a), icon: Icons.add_task_rounded),
                    );
                  },
                ),
          ),
        ]),
      ),
    );
  }

  void _pilihAssignment(BuildContext context, Assignment a) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Konfirmasi Kompen'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Assignment: ${a.judul}', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Dosen: ${a.dosenNama}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          Text('Jam Kompen: ${a.jamKompen} jam', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          const Text('Apakah kamu yakin ingin mengerjakan assignment ini?', style: TextStyle(fontSize: 13)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tidak')),
          ElevatedButton(
            onPressed: () {
              final svc = context.read<DataService>();
              final user = svc.currentUser!;
              final ok = svc.pilihAssignment(a.id, user.id);
              if (ok) {
                svc.addPengajuan(PengajuanKompen(
                  id: const Uuid().v4(),
                  mahasiswaId: user.id,
                  mahasiswaNama: user.nama,
                  mahasiswaNim: user.nim,
                  assignmentId: a.id,
                  assignmentJudul: a.judul,
                  dosenId: a.dosenId,
                  dosenNama: a.dosenNama,
                  jamKompen: a.jamKompen,
                  tanggalPengajuan: DateTime.now(),
                ));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Assignment berhasil dipilih! Silakan upload bukti pengerjaan.'), backgroundColor: AppTheme.accentGreen),
                );
              }
            },
            child: const Text('Kerjakan'),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, Assignment a) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.divider, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text(a.judul, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            InfoRow(icon: Icons.person_outline, label: 'Dosen', value: a.dosenNama),
            InfoRow(icon: Icons.schedule_outlined, label: 'Jam Kompen', value: '${a.jamKompen} jam'),
            InfoRow(icon: Icons.people_outline, label: 'Kuota', value: '${a.mahasiswaTerdaftar.length}/${a.kuotaMahasiswa} mahasiswa'),
            InfoRow(icon: Icons.calendar_today_outlined, label: 'Mulai', value: DateFormat('dd MMM yyyy').format(a.tanggalMulai)),
            InfoRow(icon: Icons.event_outlined, label: 'Berakhir', value: DateFormat('dd MMM yyyy').format(a.tanggalBerakhir)),
            const SizedBox(height: 16),
            const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            Text(a.deskripsi, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.6)),
          ]),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.bgCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppTheme.primary : AppTheme.divider),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: selected ? Colors.white : AppTheme.textSecondary)),
      ),
    );
  }
}