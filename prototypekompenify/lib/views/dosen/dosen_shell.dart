// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:uuid/uuid.dart';
// import 'package:intl/intl.dart';
// import '../../utils/app_theme.dart';
// import '../shared/common_widgets.dart';
// import '../../models/models.dart';
// import '../auth/login_screen.dart';
// import '../shared/notifikasi_screen.dart';

// // ─── Dosen Shell ─────────────────────────────────────────────────────────────
// class DosenShell extends StatefulWidget {
//   const DosenShell({super.key});

//   @override
//   State<DosenShell> createState() => _DosenShellState();
// }

// class _DosenShellState extends State<DosenShell> {
//   int _idx = 0;
//   final _screens = const [DosenDashboard(), DosenAssignment(), DosenVerifikasi(), NotifikasiScreen()];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_idx],
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(color: AppTheme.bgCard, border: Border(top: BorderSide(color: AppTheme.divider))),
//         child: NavigationBar(
//           backgroundColor: Colors.transparent,
//           selectedIndex: _idx,
//           onDestinationSelected: (i) => setState(() => _idx = i),
//           indicatorColor: AppTheme.primary.withOpacity(0.2),
//           destinations: const [
//             NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
//             NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment_rounded), label: 'Assignment'),
//             NavigationDestination(icon: Icon(Icons.verified_outlined), selectedIcon: Icon(Icons.verified_rounded), label: 'Verifikasi'),
//             NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications_rounded), label: 'Notifikasi'),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─── Dosen Dashboard ─────────────────────────────────────────────────────────
// class DosenDashboard extends StatelessWidget {
//   const DosenDashboard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final svc = context.watch<DataService>();
//     final user = svc.currentUser!;
//     final myAssignments = svc.getAssignments(dosenId: user.id);
//     final myVerifikasi = svc.getPengajuan(dosenId: user.id);
//     final menunggu = myVerifikasi.where((p) => p.status == KompenStatus.proses).length;
//     final selesai = myVerifikasi.where((p) => p.status == KompenStatus.lunas || p.status == KompenStatus.disetujuiDosen).length;

//     return GradientBackground(
//       child: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Row(children: [
//               Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Text('Halo, ${user.nama.split(' ').first}! 👋', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
//                 Text('Dosen | ${user.prodi ?? ''}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
//               ])),
//               IconButton(
//                 icon: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.bgCard, borderRadius: BorderRadius.circular(12)),
//                   child: const Icon(Icons.logout_rounded, color: AppTheme.accentRed, size: 20)),
//                 onPressed: () { svc.logout(); Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())); },
//               ),
//             ]),
//             const SizedBox(height: 24),
//             GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
//               crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5,
//               children: [
//                 StatCard(label: 'Assignment Dibuat', value: '${myAssignments.length}', icon: Icons.assignment_rounded, color: AppTheme.accent),
//                 StatCard(label: 'Menunggu Verifikasi', value: '$menunggu', icon: Icons.pending_actions_rounded, color: AppTheme.accentOrange),
//                 StatCard(label: 'Total Pengajuan', value: '${myVerifikasi.length}', icon: Icons.people_rounded, color: AppTheme.primaryLight),
//                 StatCard(label: 'Sudah Diverifikasi', value: '$selesai', icon: Icons.verified_rounded, color: AppTheme.accentGreen),
//               ],
//             ),
//             const SizedBox(height: 24),
//             SectionHeader(title: 'Assignment Terbaru', action: 'Kelola', onAction: () {}),
//             const SizedBox(height: 12),
//             ...myAssignments.take(3).map((a) => AssignmentCard(assignment: a)),
//             if (myAssignments.isEmpty)
//               const EmptyState(icon: Icons.assignment_outlined, title: 'Belum ada assignment', subtitle: 'Buat assignment di tab Assignment'),
//           ]),
//         ),
//       ),
//     );
//   }
// }

// // ─── Dosen Assignment (CRUD) ──────────────────────────────────────────────────
// class DosenAssignment extends StatelessWidget {
//   const DosenAssignment({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final svc = context.watch<DataService>();
//     final user = svc.currentUser!;
//     final list = svc.getAssignments(dosenId: user.id);

//     return GradientBackground(
//       child: SafeArea(
//         child: Column(children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
//             child: Row(children: [
//               const Text('Assignment Saya', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
//               const Spacer(),
//               IconButton.filled(
//                 style: IconButton.styleFrom(backgroundColor: AppTheme.primary),
//                 icon: const Icon(Icons.add_rounded, color: Colors.white),
//                 onPressed: () => _showForm(context),
//               ),
//             ]),
//           ),
//           Expanded(
//             child: list.isEmpty
//               ? const EmptyState(icon: Icons.add_task_rounded, title: 'Belum ada assignment', subtitle: 'Tap tombol + untuk membuat assignment baru')
//               : ListView.builder(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   itemCount: list.length,
//                   itemBuilder: (ctx, i) {
//                     final a = list[i];
//                     return AssignmentCard(
//                       assignment: a,
//                       trailing: Row(children: [
//                         Expanded(child: OutlinedButton.icon(
//                           onPressed: () => _showForm(context, assignment: a),
//                           icon: const Icon(Icons.edit_outlined, size: 14),
//                           label: const Text('Edit'),
//                           style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
//                         )),
//                         const SizedBox(width: 8),
//                         OutlinedButton.icon(
//                           onPressed: () => _confirmDelete(context, a.id),
//                           icon: const Icon(Icons.delete_outline, size: 14, color: AppTheme.accentRed),
//                           label: const Text('Hapus', style: TextStyle(color: AppTheme.accentRed)),
//                           style: OutlinedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 8),
//                             side: const BorderSide(color: AppTheme.accentRed),
//                           ),
//                         ),
//                       ]),
//                     );
//                   },
//                 ),
//           ),
//         ]),
//       ),
//     );
//   }

//   void _confirmDelete(BuildContext context, String id) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         backgroundColor: AppTheme.bgCard,
//         title: const Text('Hapus Assignment?'),
//         content: const Text('Assignment ini akan dihapus permanen.'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
//           TextButton(
//             onPressed: () { context.read<DataService>().deleteAssignment(id); Navigator.pop(context); },
//             child: const Text('Hapus', style: TextStyle(color: AppTheme.accentRed)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showForm(BuildContext context, {Assignment? assignment}) {
//     showModalBottomSheet(
//       context: context, isScrollControlled: true,
//       backgroundColor: AppTheme.bgCard,
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
//       builder: (_) => _AssignmentFormSheet(assignment: assignment),
//     );
//   }
// }

// class _AssignmentFormSheet extends StatefulWidget {
//   final Assignment? assignment;
//   const _AssignmentFormSheet({this.assignment});

//   @override
//   State<_AssignmentFormSheet> createState() => _AssignmentFormSheetState();
// }

// class _AssignmentFormSheetState extends State<_AssignmentFormSheet> {
//   final _judulCtrl = TextEditingController();
//   final _descCtrl = TextEditingController();
//   final _kuotaCtrl = TextEditingController(text: '5');
//   int _jam = 2;
//   DateTime _mulai = DateTime.now();
//   DateTime _berakhir = DateTime.now().add(const Duration(days: 7));

//   @override
//   void initState() {
//     super.initState();
//     if (widget.assignment != null) {
//       final a = widget.assignment!;
//       _judulCtrl.text = a.judul;
//       _descCtrl.text = a.deskripsi;
//       _kuotaCtrl.text = '${a.kuotaMahasiswa}';
//       _jam = a.jamKompen;
//       _mulai = a.tanggalMulai;
//       _berakhir = a.tanggalBerakhir;
//     }
//   }

//   @override
//   void dispose() {
//     _judulCtrl.dispose(); _descCtrl.dispose(); _kuotaCtrl.dispose();
//     super.dispose();
//   }

//   void _save() {
//     if (_judulCtrl.text.isEmpty || _descCtrl.text.isEmpty) return;
//     final svc = context.read<DataService>();
//     final user = svc.currentUser!;
//     if (widget.assignment == null) {
//       svc.addAssignment(Assignment(
//         id: const Uuid().v4(),
//         judul: _judulCtrl.text.trim(),
//         deskripsi: _descCtrl.text.trim(),
//         jamKompen: _jam,
//         dosenId: user.id,
//         dosenNama: user.nama,
//         tanggalMulai: _mulai,
//         tanggalBerakhir: _berakhir,
//         kuotaMahasiswa: int.tryParse(_kuotaCtrl.text) ?? 5,
//       ));
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Assignment berhasil dibuat!'), backgroundColor: AppTheme.accentGreen));
//     } else {
//       final updated = Assignment(
//         id: widget.assignment!.id,
//         judul: _judulCtrl.text.trim(),
//         deskripsi: _descCtrl.text.trim(),
//         jamKompen: _jam,
//         dosenId: user.id,
//         dosenNama: user.nama,
//         tanggalMulai: _mulai,
//         tanggalBerakhir: _berakhir,
//         kuotaMahasiswa: int.tryParse(_kuotaCtrl.text) ?? 5,
//         mahasiswaTerdaftar: widget.assignment!.mahasiswaTerdaftar,
//       );
//       svc.updateAssignment(updated);
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Assignment diperbarui!'), backgroundColor: AppTheme.accentGreen));
//     }
//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Row(children: [
//             Text(widget.assignment == null ? 'Buat Assignment' : 'Edit Assignment',
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
//             const Spacer(),
//             IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
//           ]),
//           const SizedBox(height: 20),
//           TextField(controller: _judulCtrl, decoration: const InputDecoration(labelText: 'Judul Tugas', prefixIcon: Icon(Icons.title, color: AppTheme.accent))),
//           const SizedBox(height: 12),
//           TextField(controller: _descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Deskripsi', prefixIcon: Icon(Icons.description_outlined, color: AppTheme.accent))),
//           const SizedBox(height: 12),
//           const Text('Jam Kompen', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
//           const SizedBox(height: 8),
//           Wrap(spacing: 8, children: [2, 3, 4, 6, 8].map((j) => GestureDetector(
//             onTap: () => setState(() => _jam = j),
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 color: _jam == j ? AppTheme.primary : AppTheme.bgCardLight,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text('$j jam', style: TextStyle(color: _jam == j ? Colors.white : AppTheme.textSecondary, fontWeight: FontWeight.w600)),
//             ),
//           )).toList()),
//           const SizedBox(height: 12),
//           TextField(controller: _kuotaCtrl, keyboardType: TextInputType.number,
//             decoration: const InputDecoration(labelText: 'Kuota Mahasiswa', prefixIcon: Icon(Icons.people_outline, color: AppTheme.accent))),
//           const SizedBox(height: 12),
//           Row(children: [
//             Expanded(child: _DateBtn(label: 'Mulai', date: _mulai, onPick: (d) => setState(() => _mulai = d))),
//             const SizedBox(width: 10),
//             Expanded(child: _DateBtn(label: 'Berakhir', date: _berakhir, onPick: (d) => setState(() => _berakhir = d))),
//           ]),
//           const SizedBox(height: 24),
//           PrimaryButton(label: widget.assignment == null ? 'Buat Assignment' : 'Simpan Perubahan', onTap: _save),
//           const SizedBox(height: 8),
//         ]),
//       ),
//     );
//   }
// }

// class _DateBtn extends StatelessWidget {
//   final String label;
//   final DateTime date;
//   final void Function(DateTime) onPick;
//   const _DateBtn({required this.label, required this.date, required this.onPick});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () async {
//         final picked = await showDatePicker(
//           context: context, initialDate: date,
//           firstDate: DateTime.now().subtract(const Duration(days: 30)),
//           lastDate: DateTime.now().add(const Duration(days: 365)),
//         );
//         if (picked != null) onPick(picked);
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//         decoration: BoxDecoration(color: AppTheme.inputFill, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.divider)),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
//           const SizedBox(height: 2),
//           Text(DateFormat('dd MMM yyyy').format(date), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
//         ]),
//       ),
//     );
//   }
// }

// // ─── Dosen Verifikasi ─────────────────────────────────────────────────────────
// class DosenVerifikasi extends StatelessWidget {
//   const DosenVerifikasi({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final svc = context.watch<DataService>();
//     final user = svc.currentUser!;
//     final list = svc.getPengajuan(dosenId: user.id).where((p) => p.status == KompenStatus.proses || p.status == KompenStatus.menunggu).toList();
//     final history = svc.getPengajuan(dosenId: user.id).where((p) => p.status != KompenStatus.proses && p.status != KompenStatus.menunggu).toList();

//     return GradientBackground(
//       child: SafeArea(
//         child: Column(children: [
//           Padding(
//             padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//               const Text('Verifikasi Kompen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
//               Text('${list.length} menunggu verifikasi', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
//             ]),
//           ),
//           Expanded(
//             child: ListView(padding: const EdgeInsets.symmetric(horizontal: 20), children: [
//               if (list.isEmpty)
//                 const EmptyState(icon: Icons.inbox_outlined, title: 'Tidak ada yang perlu diverifikasi')
//               else ...[
//                 ...list.map((p) => _VerifikasiCard(pengajuan: p)),
//               ],
//               if (history.isNotEmpty) ...[
//                 const SizedBox(height: 16),
//                 const Text('Riwayat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
//                 const SizedBox(height: 12),
//                 ...history.map((p) => KompenCard(pengajuan: p)),
//               ],
//             ]),
//           ),
//         ]),
//       ),
//     );
//   }
// }

// class _VerifikasiCard extends StatelessWidget {
//   final PengajuanKompen pengajuan;
//   const _VerifikasiCard({required this.pengajuan});

//   @override
//   Widget build(BuildContext context) {
//     final p = pengajuan;
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: AppTheme.cardGradient, borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: AppTheme.accentOrange.withOpacity(0.4), width: 1.5),
//       ),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(children: [
//           Expanded(child: Text(p.mahasiswaNama, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
//           StatusBadge(label: p.statusLabel, color: p.statusColor),
//         ]),
//         const SizedBox(height: 4),
//         Text(p.mahasiswaNim, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
//         const SizedBox(height: 10),
//         InfoRow(icon: Icons.assignment_outlined, label: 'Assignment', value: p.assignmentJudul),
//         InfoRow(icon: Icons.schedule_outlined, label: 'Jam', value: '${p.jamKompen} jam'),
//         if (p.buktiFotoPath != null) ...[
//           const SizedBox(height: 8),
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(color: AppTheme.accentGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
//             child: const Row(children: [
//               Icon(Icons.attach_file, color: AppTheme.accentGreen, size: 16),
//               SizedBox(width: 6),
//               Text('Bukti sudah diupload', style: TextStyle(color: AppTheme.accentGreen, fontSize: 12)),
//             ]),
//           ),
//         ] else ...[
//           const SizedBox(height: 8),
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(color: AppTheme.accentOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
//             child: const Row(children: [
//               Icon(Icons.upload_file_outlined, color: AppTheme.accentOrange, size: 16),
//               SizedBox(width: 6),
//               Text('Menunggu mahasiswa upload bukti', style: TextStyle(color: AppTheme.accentOrange, fontSize: 12)),
//             ]),
//           ),
//         ],
//         if (p.buktiFotoPath != null) ...[
//           const SizedBox(height: 12),
//           Row(children: [
//             Expanded(child: OutlinedButton.icon(
//               onPressed: () => _reject(context, p),
//               icon: const Icon(Icons.close_rounded, size: 16, color: AppTheme.accentRed),
//               label: const Text('Minta Revisi', style: TextStyle(color: AppTheme.accentRed, fontSize: 12)),
//               style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.accentRed), padding: const EdgeInsets.symmetric(vertical: 10)),
//             )),
//             const SizedBox(width: 10),
//             Expanded(child: ElevatedButton.icon(
//               onPressed: () => _approve(context, p),
//               icon: const Icon(Icons.draw_outlined, size: 16),
//               label: const Text('Berikan E-TTD', style: TextStyle(fontSize: 12)),
//               style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGreen, padding: const EdgeInsets.symmetric(vertical: 10)),
//             )),
//           ]),
//         ],
//       ]),
//     );
//   }

//   void _approve(BuildContext context, PengajuanKompen p) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         backgroundColor: AppTheme.bgCard,
//         title: const Row(children: [Icon(Icons.draw_outlined, color: AppTheme.accentGreen), SizedBox(width: 8), Text('Berikan E-TTD')]),
//         content: Text('Setujui dan tandatangani kompen ${p.mahasiswaNama} untuk "${p.assignmentJudul}"?'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
//           ElevatedButton(
//             onPressed: () {
//               context.read<DataService>().verifikasiDosen(p.id, true);
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('✅ E-TTD berhasil diberikan! Notifikasi dikirim ke Kaprodi.'), backgroundColor: AppTheme.accentGreen),
//               );
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGreen),
//             child: const Text('Setujui & TTD'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _reject(BuildContext context, PengajuanKompen p) {
//     final ctrl = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         backgroundColor: AppTheme.bgCard,
//         title: const Text('Minta Revisi'),
//         content: Column(mainAxisSize: MainAxisSize.min, children: [
//           const Text('Berikan catatan untuk mahasiswa:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
//           const SizedBox(height: 12),
//           TextField(controller: ctrl, maxLines: 3, decoration: const InputDecoration(hintText: 'Masukkan catatan revisi...')),
//         ]),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
//           ElevatedButton(
//             onPressed: () {
//               context.read<DataService>().verifikasiDosen(p.id, false, catatan: ctrl.text);
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('📝 Revisi diminta. Notifikasi dikirim ke mahasiswa.'), backgroundColor: AppTheme.accentOrange),
//               );
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentOrange),
//             child: const Text('Kirim Revisi'),
//           ),
//         ],
//       ),
//     );
//   }
// }