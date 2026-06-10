import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/mahasiswa_controller.dart';
import '../../models/assignment_model.dart';
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';

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
    // Mengakses token login melalui AuthController
    final authController = context.watch<AuthController>();
    final token = authController.token ?? '';

    // Mengakses data tugas kompen melalui MahasiswaController
    final mhsController = context.watch<MahasiswaController>();
    var assignments = mhsController.assignmentsMahasiswa;

    // Filter pencarian berdasarkan judul tugas atau nama dosen
    if (_search.isNotEmpty) {
      assignments = assignments
          .where(
            (a) =>
                a.judul.toLowerCase().contains(_search.toLowerCase()) ||
                (a.dosenNama ?? '').toLowerCase().contains(
                  _search.toLowerCase(),
                ),
          )
          .toList();
    }

    // Filter pencarian berdasarkan bobot jam kompen
    if (_filterJam != null) {
      assignments = assignments
          .where((a) => a.jamKompen == _filterJam)
          .toList();
    }

    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daftar Assignment',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${assignments.length} assignment tersedia',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
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
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'Semua',
                          selected: _filterJam == null,
                          onTap: () => setState(() => _filterJam = null),
                        ),
                        ...[2, 3, 4, 6].map(
                          (j) => _FilterChip(
                            label: '$j Jam',
                            selected: _filterJam == j,
                            onTap: () => setState(
                              () => _filterJam = _filterJam == j ? null : j,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppTheme.primary,
                backgroundColor: AppTheme.bgCard,
                onRefresh: () =>
                    context.read<AuthController>().refreshProfile(),
                child: assignments.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(
                            height: 400,
                            child: EmptyState(
                              icon: Icons.assignment_outlined,
                              title: 'Tidak ada assignment',
                              subtitle:
                                  'Belum ada assignment yang tersedia saat ini',
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: assignments.length,
                        itemBuilder: (ctx, i) {
                          final a = assignments[i];

                          // Memeriksa status pendaftaran tugas dari riwayat pengajuan mahasiswa
                          final sudahDaftar = mhsController.pengajuanSaya.any(
                            (p) => p.assignmentId == a.id,
                          );

                          return _AssignmentApiCard(
                            assignment: a,
                            sudahDaftar: sudahDaftar,
                            onTap: () => _showDetail(context, a),
                            onKerjakan: () =>
                                _konfirmasiKerjakan(context, token, a),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _konfirmasiKerjakan(
    BuildContext context,
    String token,
    AssignmentModel a,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Konfirmasi Kompen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assignment: ${a.judul}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Jam Kompen: ${a.jamKompen} jam',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Apakah kamu yakin ingin mengerjakan assignment ini?',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Mengirimkan permintaan pengajuan kompen melalui MahasiswaController
              final result = await context
                  .read<MahasiswaController>()
                  .ajukanKompen(token, a.id);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['success'] == true
                          ? '✅ Berhasil mengajukan kompen!'
                          : '❌ ${result['message']}',
                    ),
                    backgroundColor: result['success'] == true
                        ? AppTheme.accentGreen
                        : AppTheme.accentRed,
                  ),
                );
              }
            },
            child: const Text('Kerjakan'),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, AssignmentModel a) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, ctrl) => SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                a.judul,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              if (a.dosenNama != null)
                InfoRow(
                  icon: Icons.person_outline,
                  label: 'Dosen',
                  value: a.dosenNama!,
                ),
              InfoRow(
                icon: Icons.schedule_outlined,
                label: 'Jam Kompen',
                value: '${a.jamKompen} jam',
              ),
              InfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Mulai',
                value: a.tanggalMulai,
              ),
              InfoRow(
                icon: Icons.event_outlined,
                label: 'Berakhir',
                value: a.tanggalSelesai,
              ),
              const SizedBox(height: 16),
              const Text(
                'Deskripsi',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                a.deskripsi,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssignmentApiCard extends StatelessWidget {
  final AssignmentModel assignment;
  final bool sudahDaftar;
  final VoidCallback onTap;
  final VoidCallback onKerjakan;

  const _AssignmentApiCard({
    required this.assignment,
    required this.sudahDaftar,
    required this.onTap,
    required this.onKerjakan,
  });

  @override
  Widget build(BuildContext context) {
    final a = assignment;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    a.judul,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${a.jamKompen} jam',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (a.dosenNama != null)
              Text(
                a.dosenNama!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            const SizedBox(height: 6),
            Text(
              a.deskripsi,
              style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 12,
                  color: AppTheme.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  '${a.tanggalMulai} – ${a.tanggalSelesai}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (sudahDaftar)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppTheme.accentGreen,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Sudah Diajukan',
                      style: TextStyle(
                        color: AppTheme.accentGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onKerjakan,
                  icon: const Icon(Icons.add_task_rounded, size: 16),
                  label: const Text('Kerjakan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

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
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.divider,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
