import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../controllers/data_service.dart';
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';
import '../../models/models.dart';

// ─── Dosen Assignment (CRUD) ──────────────────────────────────────────────────
class DosenAssignment extends StatelessWidget {
  const DosenAssignment({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<DataService>();
    final user = svc.currentUser!;
    // Konversi user.id ke String
    final list = svc.getAssignments(dosenId: user.id.toString());

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
            // 📝 GANTI BAGIAN EXPANDED-NYA DENGAN INI
            Expanded(
              child: RefreshIndicator(
                color: AppTheme.primary,
                backgroundColor: AppTheme.bgCard,
                onRefresh: () => context.read<DataService>().refreshDataDosen(),
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
                          return AssignmentCard(
                            assignment: a,
                            trailing: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () =>
                                        _showForm(context, assignment: a),
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 14,
                                    ),
                                    label: const Text('Edit'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      _confirmDelete(context, a.id),
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
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    side: const BorderSide(
                                      color: AppTheme.accentRed,
                                    ),
                                  ),
                                ),
                              ],
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
        content: const Text('Assignment ini akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              context.read<DataService>().deleteAssignment(id);
              Navigator.pop(context);
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

  void _showForm(BuildContext context, {Assignment? assignment}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AssignmentFormSheet(assignment: assignment),
    );
  }
}

class _AssignmentFormSheet extends StatefulWidget {
  final Assignment? assignment;
  const _AssignmentFormSheet({this.assignment});

  @override
  State<_AssignmentFormSheet> createState() => _AssignmentFormSheetState();
}

class _AssignmentFormSheetState extends State<_AssignmentFormSheet> {
  final _judulCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _kuotaCtrl = TextEditingController(text: '5');
  int _jam = 2;
  DateTime _mulai = DateTime.now();
  DateTime _berakhir = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    if (widget.assignment != null) {
      final a = widget.assignment!;
      _judulCtrl.text = a.judul;
      _descCtrl.text = a.deskripsi;
      _kuotaCtrl.text = '${a.kuotaMahasiswa}';
      _jam = a.jamKompen;
      _mulai = a.tanggalMulai;
      _berakhir = a.tanggalBerakhir;
    }
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _descCtrl.dispose();
    _kuotaCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_judulCtrl.text.isEmpty || _descCtrl.text.isEmpty) return;
    final svc = context.read<DataService>();
    final user = svc.currentUser!;
    if (widget.assignment == null) {
      svc.addAssignment(
        Assignment(
          id: const Uuid().v4(),
          judul: _judulCtrl.text.trim(),
          deskripsi: _descCtrl.text.trim(),
          jamKompen: _jam,
          dosenId: user.id.toString(), // Konversi ke String
          dosenNama: user.name, // Ganti .nama menjadi .name
          tanggalMulai: _mulai,
          tanggalBerakhir: _berakhir,
          kuotaMahasiswa: int.tryParse(_kuotaCtrl.text) ?? 5,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Assignment berhasil dibuat!'),
          backgroundColor: AppTheme.accentGreen,
        ),
      );
    } else {
      final updated = Assignment(
        id: widget.assignment!.id,
        judul: _judulCtrl.text.trim(),
        deskripsi: _descCtrl.text.trim(),
        jamKompen: _jam,
        dosenId: user.id.toString(), // Konversi ke String
        dosenNama: user.name, // Ganti .nama menjadi .name
        tanggalMulai: _mulai,
        tanggalBerakhir: _berakhir,
        kuotaMahasiswa: int.tryParse(_kuotaCtrl.text) ?? 5,
        mahasiswaTerdaftar: widget.assignment!.mahasiswaTerdaftar,
      );
      svc.updateAssignment(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Assignment diperbarui!'),
          backgroundColor: AppTheme.accentGreen,
        ),
      );
    }
    Navigator.pop(context);
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
            TextField(
              controller: _kuotaCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Kuota Mahasiswa',
                prefixIcon: Icon(Icons.people_outline, color: AppTheme.accent),
              ),
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
            PrimaryButton(
              label: widget.assignment == null
                  ? 'Buat Assignment'
                  : 'Simpan Perubahan',
              onTap: _save,
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
