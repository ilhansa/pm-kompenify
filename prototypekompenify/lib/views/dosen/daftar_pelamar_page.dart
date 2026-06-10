// lib/views/dosen/daftar_pelamar_page.dart
// Menggunakan AuthController untuk sinkronisasi token sesi dan verifikasi status pelamar

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../controllers/auth_controller.dart';
import '../../models/assignment_model.dart';
import '../../models/pengajuan_model.dart';

class DaftarPelamarPage extends StatefulWidget {
  final AssignmentModel assignment;
  const DaftarPelamarPage({super.key, required this.assignment});

  @override
  State<DaftarPelamarPage> createState() => _DaftarPelamarPageState();
}

class _DaftarPelamarPageState extends State<DaftarPelamarPage> {
  List<PengajuanModel> _pelamars = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPelamars();
  }

  Future<void> _fetchPelamars() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Mengambil token otentikasi aktif dari AuthController
      final token = context.read<AuthController>().token!;
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:8000/api';

      final res = await http.get(
        Uri.parse(
          '$baseUrl/dosen/assignments/${widget.assignment.id}/pengajuan-kompen',
        ),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        setState(() {
          _pelamars = (body['data'] as List)
              .map((e) => PengajuanModel.fromJson(e))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = body['message'] ?? 'Gagal memuat data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Gagal terhubung ke server: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(PengajuanModel p, String status) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          status == 'diterima' ? 'Terima Pengajuan?' : 'Tolak Pengajuan?',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          status == 'diterima'
              ? 'Mahasiswa ${p.mahasiswaNama ?? p.mahasiswaNim ?? '-'} akan diterima. Pelamar lain otomatis ditolak.'
              : 'Pengajuan ${p.mahasiswaNama ?? p.mahasiswaNim ?? '-'} akan ditolak.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: status == 'diterima'
                  ? const Color(0xFF4CAF8D)
                  : const Color(0xFFE74C6B),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(status == 'diterima' ? 'Terima' : 'Tolak'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      // Menjalankan fungsi verifikasi satu pintu melalui AuthController
      final result = await context.read<AuthController>().verifikasiPengajuan(
        id: p.id,
        status: status,
        role:
            'dosen', // Memastikan instruksi peran tetap ditujukan kepada dosen
      );

      if (result['success'] == true) {
        _showSnackbar(
          status == 'diterima'
              ? 'Pengajuan berhasil diterima!'
              : 'Pengajuan berhasil ditolak.',
          status == 'diterima'
              ? const Color(0xFF4CAF8D)
              : const Color(0xFFE74C6B),
        );
        await _fetchPelamars();
      } else {
        _showSnackbar(result['message'] ?? 'Gagal memproses', Colors.red);
      }
    } catch (e) {
      _showSnackbar('Gagal terhubung ke server', Colors.red);
    }
  }

  void _showSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asg = widget.assignment;
    final pendingCount = _pelamars.where((p) => p.status == 'pending').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Daftar Pelamar',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetchPelamars,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1),
                const SizedBox(height: 12),
                Text(
                  asg.judul,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _infoChip(
                      Icons.schedule_rounded,
                      '${asg.jamKompen} jam kompen',
                      const Color(0xFF6C63FF),
                    ),
                    const SizedBox(width: 8),
                    _infoChip(
                      Icons.people_rounded,
                      '$pendingCount menunggu',
                      const Color(0xFFFFB020),
                    ),
                    const SizedBox(width: 8),
                    _statusBadge(asg.status),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? _buildError()
                : _pelamars.isEmpty
                ? _buildEmpty()
                : RefreshIndicator(
                    onRefresh: _fetchPelamars,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _pelamars.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _PelamarCard(
                        pengajuan: _pelamars[i],
                        onTerima: () => _updateStatus(_pelamars[i], 'diterima'),
                        onTolak: () => _updateStatus(_pelamars[i], 'ditolak'),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Widget _statusBadge(String status) {
    final map = {
      'aktif': (const Color(0xFF4CAF8D), 'Aktif'),
      'sedang dikerjakan': (const Color(0xFF6C63FF), 'Dikerjakan'),
      'selesai': (Colors.grey, 'Selesai'),
    };
    final data = map[status] ?? (Colors.grey, status);
    return _infoChip(Icons.circle, data.$2, data.$1);
  }

  Widget _buildEmpty() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text(
          'Belum ada pelamar',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          'Mahasiswa belum ada yang mengajukan kompen ini',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        ),
      ],
    ),
  );

  Widget _buildError() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 12),
        Text(_error!, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _fetchPelamars,
          icon: const Icon(Icons.refresh),
          label: const Text('Coba Lagi'),
        ),
      ],
    ),
  );
}

class _PelamarCard extends StatelessWidget {
  final PengajuanModel pengajuan;
  final VoidCallback onTerima;
  final VoidCallback onTolak;

  const _PelamarCard({
    required this.pengajuan,
    required this.onTerima,
    required this.onTolak,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = pengajuan.status == 'pending';
    final nama = pengajuan.mahasiswaNama ?? '-';
    final nim = pengajuan.mahasiswaNim ?? '-';
    final inisial = nama != '-' && nama.isNotEmpty
        ? nama[0].toUpperCase()
        : '?';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF6C63FF).withOpacity(0.12),
              child: Text(
                inisial,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C63FF),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    nim,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: pengajuan.statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      pengajuan.statusLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: pengajuan.statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isPending) ...[
              const SizedBox(width: 8),
              Column(
                children: [
                  _ActionBtn(
                    icon: Icons.check_rounded,
                    color: const Color(0xFF4CAF8D),
                    label: 'Terima',
                    onTap: onTerima,
                  ),
                  const SizedBox(height: 6),
                  _ActionBtn(
                    icon: Icons.close_rounded,
                    color: const Color(0xFFE74C6B),
                    label: 'Tolak',
                    onTap: onTolak,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
