// lib/views/kaprodi/kaprodi_assignment.dart
// Menggunakan AuthController untuk sesi login dan KaprodiController untuk manajemen CRUD tugas kaprodi

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/kaprodi_controller.dart';
import '../../models/assignment_model.dart';
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';
import 'kaprodi_daftar_pelamar_page.dart';

class KaprodiAssignment extends StatelessWidget {
  const KaprodiAssignment({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Membaca data state koleksi penugasan pimpinan dari KaprodiController
    final kaprodiController = context.watch<KaprodiController>();
    final list = kaprodiController.assignmentsKaprodi;

    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  const Text(
                    'Assignment Saya',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                    ),
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    onPressed: () => _showForm(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppTheme.primary,
                backgroundColor: AppTheme.bgCard,
                // Menggunakan sinkronisasi profil terpusat dari AuthController
                onRefresh: () =>
                    context.read<AuthController>().refreshProfile(),
                child: list.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(
                            height: 400,
                            child: EmptyState(
                              icon: Icons.add_task_rounded,
                              title: 'Belum ada assignment',
                              subtitle:
                                  'Tap tombol + untuk membuat assignment baru',
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: list.length,
                        itemBuilder: (ctx, i) {
                          final a = list[i];
                          return _AssignmentKaprodiCard(
                            assignment: a,
                            onEdit: () => _showForm(context, assignment: a),
                            onDelete: () => _confirmDelete(context, a.id),
                            onLihatPelamar: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    KaprodiDaftarPelamarPage(assignment: a),
                              ),
                            ),
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

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Hapus Assignment?'),
        content: const Text(
          'Assignment ini akan dihapus permanen dari server.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Mengambil token otentikasi aktif dari AuthController
              final token = context.read<AuthController>().token ?? '';

              // Mengarahkan fungsi hapus ke KaprodiController bawaan timmu
              final result = await context
                  .read<KaprodiController>()
                  .deleteAssignmentKaprodiApi(token, id);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['success'] == true
                          ? '✅ Assignment berhasil dihapus!'
                          : '❌ ${result['message']}',
                    ),
                    backgroundColor: result['success'] == true
                        ? AppTheme.accentGreen
                        : AppTheme.accentRed,
                  ),
                );
              }
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppTheme.accentRed),
            ),
          ),
        ],
      ),
    );
  }

  void _showForm(BuildContext context, {AssignmentModel? assignment}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AssignmentKaprodiFormSheet(assignment: assignment),
    );
  }
}

// ─── Card ───────────────────────────────────────────────────────────────────────
class _AssignmentKaprodiCard extends StatelessWidget {
  final AssignmentModel assignment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onLihatPelamar;

  const _AssignmentKaprodiCard({
    required this.assignment,
    required this.onEdit,
    required this.onDelete,
    required this.onLihatPelamar,
  });

  @override
  Widget build(BuildContext context) {
    final a = assignment;
    return Container(
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: a.status == 'aktif'
                      ? AppTheme.accentGreen.withOpacity(0.15)
                      : AppTheme.textMuted.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  a.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: a.status == 'aktif'
                        ? AppTheme.accentGreen
                        : AppTheme.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            a.deskripsi,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.schedule_outlined,
                size: 13,
                color: AppTheme.accent,
              ),
              const SizedBox(width: 4),
              Text(
                '${a.jamKompen} jam kompen',
                style: const TextStyle(fontSize: 12, color: AppTheme.accent),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.calendar_today_outlined,
                size: 13,
                color: AppTheme.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                '${a.tanggalMulai} – ${a.tanggalSelesai}',
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onLihatPelamar,
              icon: const Icon(Icons.people_rounded, size: 15),
              label: const Text('Lihat Pelamar'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 9),
                foregroundColor: AppTheme.primary,
                side: BorderSide(color: AppTheme.primary.withOpacity(0.5)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  size: 14,
                  color: AppTheme.accentRed,
                ),
                label: const Text(
                  'Hapus',
                  style: TextStyle(color: AppTheme.accentRed),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  side: const BorderSide(color: AppTheme.accentRed),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Form sheet ─────────────────────────────────────────────────────────────────
class _AssignmentKaprodiFormSheet extends StatefulWidget {
  final AssignmentModel? assignment;
  const _AssignmentKaprodiFormSheet({this.assignment});

  @override
  State<_AssignmentKaprodiFormSheet> createState() =>
      _AssignmentKaprodiFormSheetState();
}

class _AssignmentKaprodiFormSheetState
    extends State<_AssignmentKaprodiFormSheet> {
  final _judulCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  int _jam = 2;
  DateTime _mulai = DateTime.now();
  DateTime _berakhir = DateTime.now().add(const Duration(days: 7));
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.assignment != null) {
      final a = widget.assignment!;
      _judulCtrl.text = a.judul;
      _descCtrl.text = a.deskripsi;
      _jam = a.jamKompen;
      try {
        _mulai = DateTime.parse(a.tanggalMulai);
        _berakhir = DateTime.parse(a.tanggalSelesai);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_judulCtrl.text.isEmpty || _descCtrl.text.isEmpty) return;
    setState(() => _isSaving = true);

    // Mengambil token sesi aktif kaprodi dari AuthController
    final token = context.read<AuthController>().token ?? '';
    final kaprodiCtrl = context.read<KaprodiController>();
    Map<String, dynamic> result;

    if (widget.assignment == null) {
      // BUAT baru → KaprodiController.addAssignmentKaprodiApi
      result = await kaprodiCtrl.addAssignmentKaprodiApi(
        token,
        judul: _judulCtrl.text.trim(),
        deskripsi: _descCtrl.text.trim(),
        jamKompen: _jam,
        tanggalMulai: _mulai.toIso8601String().substring(0, 10),
        tanggalSelesai: _berakhir.toIso8601String().substring(0, 10),
      );
    } else {
      // EDIT → KaprodiController.editAssignmentKaprodiApi
      result = await kaprodiCtrl.editAssignmentKaprodiApi(
        token,
        widget.assignment!.id,
        judul: _judulCtrl.text.trim(),
        deskripsi: _descCtrl.text.trim(),
        jamKompen: _jam,
        tanggalMulai: _mulai.toIso8601String().substring(0, 10),
        tanggalSelesai: _berakhir.toIso8601String().substring(0, 10),
      );
    }

    setState(() => _isSaving = false);

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['success'] == true
                ? widget.assignment == null
                      ? '✅ Assignment berhasil dibuat!'
                      : '✅ Assignment diperbarui!'
                : '❌ ${result['message']}',
          ),
          backgroundColor: result['success'] == true
              ? AppTheme.accentGreen
              : AppTheme.accentRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.assignment == null
                      ? 'Buat Assignment'
                      : 'Edit Assignment',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _judulCtrl,
              decoration: const InputDecoration(
                labelText: 'Judul Tugas',
                prefixIcon: Icon(Icons.title, color: AppTheme.accent),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                prefixIcon: Icon(
                  Icons.description_outlined,
                  color: AppTheme.accent,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Jam Kompen',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [2, 3, 4, 6, 8]
                  .map(
                    (j) => GestureDetector(
                      onTap: () => setState(() => _jam = j),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _jam == j
                              ? AppTheme.primary
                              : AppTheme.bgCardLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$j jam',
                          style: TextStyle(
                            color: _jam == j
                                ? Colors.white
                                : AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DateBtn(
                    label: 'Mulai',
                    date: _mulai,
                    onPick: (d) => setState(() => _mulai = d),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DateBtn(
                    label: 'Berakhir',
                    date: _berakhir,
                    onPick: (d) => setState(() => _berakhir = d),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        widget.assignment == null
                            ? 'Buat Assignment'
                            : 'Simpan Perubahan',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DateBtn extends StatelessWidget {
  final String label;
  final DateTime date;
  final void Function(DateTime) onPick;
  const _DateBtn({
    required this.label,
    required this.date,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.inputFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat('dd MMM yyyy').format(date),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
