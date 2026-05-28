import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/utils/app_theme.dart';
import '/models/models.dart';

// ─── Gradient Background ────────────────────────────────────────────────────
class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
      child: child,
    );
  }
}

// ─── Primary Button ─────────────────────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final IconData? icon;
  final double? width;

  const PrimaryButton({
    super.key, required this.label, this.onTap,
    this.loading = false, this.icon, this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: onTap == null ? null : AppTheme.primaryGradient,
          color: onTap == null ? AppTheme.textMuted : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: onTap == null ? null : [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.4),
              blurRadius: 12, offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: loading ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: loading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
                    Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Kompen Status Badge ────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

// ─── Kompen Card ────────────────────────────────────────────────────────────
class KompenCard extends StatelessWidget {
  // UBAH: dari 'final PengajuanKompen pengajuan' menjadi Map<String, dynamic>
  final Map<String, dynamic> pengajuan; 
  final VoidCallback onTap;

  const KompenCard({super.key, required this.pengajuan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Parsing String status dari Firestore menjadi Enum lokal agar warna status sesuai
    String statusStr = pengajuan['status'] ?? 'menunggu';
    
    // Sesuaikan index atau nama enum jika dibutuhkan
    KompenStatus status = KompenStatus.values.byName(statusStr);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onTap: onTap,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    pengajuan['assignmentJudul'] ?? '', // Ambil dari Map
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _statusBadge(status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Dosen: ${pengajuan['dosenNama'] ?? ''}', // Ambil dari Map
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              'Jam Kompen: ${pengajuan['jamKompen'] ?? 0} jam', // Ambil dari Map
              style: const TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
      ),
    );
  }

  // Widget helper untuk menampilkan Badge Status di dalam Card
  Widget _statusBadge(KompenStatus s) {
    Color color;
    String label;

    switch (s) {
      case KompenStatus.menunggu:
        color = AppTheme.textSecondary;
        label = 'Menunggu';
        break;
      case KompenStatus.proses:
        color = AppTheme.accentOrange;
        label = 'Proses';
        break;
      case KompenStatus.revisi:
        color = AppTheme.accentRed;
        label = 'Revisi';
        break;
      case KompenStatus.disetujuiDosen:
        color = AppTheme.accent;
        label = 'Disetujui Dosen';
        break;
      case KompenStatus.lunas:
        color = AppTheme.accentGreen;
        label = 'Lunas';
        break;
      case KompenStatus.ditolak:
        color = AppTheme.accentRed;
        label = 'Ditolak';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _TtdProgress extends StatelessWidget {
  final PengajuanKompen pengajuan;
  const _TtdProgress({required this.pengajuan});

  @override
  Widget build(BuildContext context) {
    final hasDosen = pengajuan.ttdDosenBase64 != null;
    final hasKaprodi = pengajuan.ttdKaprodiBase64 != null;
    return Row(children: [
      _Step(label: 'Upload Bukti', done: pengajuan.buktiFotoPath != null),
      _StepLine(),
      _Step(label: 'TTD Dosen', done: hasDosen),
      _StepLine(),
      _Step(label: 'TTD Kaprodi', done: hasKaprodi),
    ]);
  }
}

class _Step extends StatelessWidget {
  final String label;
  final bool done;
  const _Step({required this.label, required this.done});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: 24, height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: done ? AppTheme.accentGreen : AppTheme.divider,
        ),
        child: Icon(done ? Icons.check : Icons.circle, size: 14,
          color: done ? Colors.white : AppTheme.textMuted),
      ),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
    ]);
  }
}

class _StepLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(height: 1.5, color: AppTheme.divider));
  }
}

// ─── Assignment Card ────────────────────────────────────────────────────────
class AssignmentCard extends StatelessWidget {
  final Assignment assignment;
  final VoidCallback? onTap;
  final Widget? trailing;

  const AssignmentCard({super.key, required this.assignment, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final sisa = assignment.tanggalBerakhir.difference(now);
    final isExpiring = sisa.inDays <= 2;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${assignment.jamKompen} Jam',
                    style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w700, fontSize: 12)),
                ),
                const Spacer(),
                if (assignment.isFull)
                  const StatusBadge(label: 'Penuh', color: AppTheme.accentRed)
                else if (isExpiring)
                  StatusBadge(label: 'Segera Berakhir', color: AppTheme.accentOrange)
                else
                  const StatusBadge(label: 'Tersedia', color: AppTheme.accentGreen),
              ]),
              const SizedBox(height: 10),
              Text(assignment.judul,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 6),
              Text(assignment.deskripsi,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.5)),
              const SizedBox(height: 12),
              Row(children: [
                Icon(Icons.person_outline, size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Expanded(child: Text(assignment.dosenNama,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.people_outline, size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text('${assignment.mahasiswaTerdaftar.length}/${assignment.kuotaMahasiswa} mahasiswa',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                const Spacer(),
                Icon(Icons.calendar_today_outlined, size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text(DateFormat('dd MMM').format(assignment.tanggalBerakhir),
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ]),
            ]),
          ),
          if (trailing != null) ...[
            Divider(height: 1, color: AppTheme.divider),
            Padding(padding: const EdgeInsets.all(12), child: trailing!),
          ],
        ]),
      ),
    );
  }
}

// ─── Section Header ─────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const Spacer(),
      if (action != null)
        GestureDetector(
          onTap: onAction,
          child: Text(action!, style: const TextStyle(color: AppTheme.accent, fontSize: 13, fontWeight: FontWeight.w500)),
        ),
    ]);
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const EmptyState({super.key, required this.icon, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.bgCard, shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(subtitle!, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              textAlign: TextAlign.center),
          ],
        ]),
      ),
    );
  }
}

// ─── Info Row ────────────────────────────────────────────────────────────────
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({super.key, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 16, color: AppTheme.accent),
        const SizedBox(width: 10),
        Text('$label: ', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
      ]),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({super.key, required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ]),
    );
  }
}