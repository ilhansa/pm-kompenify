// lib/views/admin/admin_users.dart
// Menggunakan AuthController untuk backward compatibility manajemen CRUD data pengguna sistem

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../controllers/auth_controller.dart'; // ✅ Menggunakan AuthController pusat
import '../../utils/app_theme.dart';
import '../shared/common_widgets.dart';
import '../../models/models.dart';

class AdminUsers extends StatefulWidget {
  const AdminUsers({super.key});

  @override
  State<AdminUsers> createState() => _AdminUsersState();
}

class _AdminUsersState extends State<AdminUsers>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Manajemen Pengguna',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                        ),
                        icon: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () => _showAddDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (v) => setState(() => _search = v),
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Cari nama atau NIM/NIP...',
                      prefixIcon: Icon(Icons.search, color: AppTheme.textMuted),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TabBar(
                    controller: _tabCtrl,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorColor: AppTheme.accent,
                    labelColor: AppTheme.accent,
                    unselectedLabelColor: AppTheme.textMuted,
                    tabs: const [
                      Tab(text: 'Semua'),
                      Tab(text: 'Mahasiswa'),
                      Tab(text: 'Dosen'),
                      Tab(text: 'Kaprodi'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _UserList(role: null, search: _search),
                  _UserList(role: UserRole.mahasiswa, search: _search),
                  _UserList(role: UserRole.dosen, search: _search),
                  _UserList(role: UserRole.kaprodi, search: _search),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _UserFormSheet(),
    );
  }
}

class _UserList extends StatelessWidget {
  final UserRole? role;
  final String search;
  const _UserList({this.role, required this.search});

  @override
  Widget build(BuildContext context) {
    // ✅ Mengalihkan pembacaan list pengguna via AuthController
    final svc = context.watch<AuthController>();
    var users = svc.getUsers(role: role);
    if (search.isNotEmpty) {
      users = users
          .where(
            (u) =>
                u.nama.toLowerCase().contains(search.toLowerCase()) ||
                u.nim.contains(search),
          )
          .toList();
    }

    if (users.isEmpty) {
      return const EmptyState(
        icon: Icons.people_outline,
        title: 'Tidak ada pengguna',
        subtitle: 'Tambahkan pengguna baru dengan tombol +',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: users.length,
      itemBuilder: (ctx, i) => _UserCard(user: users[i]),
    );
  }
}

class _UserCard extends StatelessWidget {
  final User user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final colors = {
      UserRole.admin: AppTheme.accent,
      UserRole.mahasiswa: AppTheme.accentGreen,
      UserRole.dosen: AppTheme.accentOrange,
      UserRole.kaprodi: AppTheme.primaryLight,
    };
    final color = colors[user.role]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.nama.isNotEmpty ? user.nama[0].toUpperCase() : '?',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  user.nim,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (user.prodi != null)
                  Text(
                    user.prodi!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(label: user.roleLabel, color: color),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _IconBtn(
                    icon: Icons.edit_outlined,
                    color: AppTheme.accent,
                    onTap: () => _showEditSheet(context, user),
                  ),
                  const SizedBox(width: 4),
                  _IconBtn(
                    icon: Icons.delete_outline,
                    color: AppTheme.accentRed,
                    onTap: () => _confirmDelete(context, user),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, User user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _UserFormSheet(user: user),
    );
  }

  void _confirmDelete(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Hapus Pengguna?'),
        content: Text('Yakin ingin menghapus akun ${user.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              // ✅ Mengalihkan fungsi hapus pengguna ke AuthController
              context.read<AuthController>().deleteUser(user.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pengguna berhasil dihapus'),
                  backgroundColor: AppTheme.accentRed,
                ),
              );
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
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}

class _UserFormSheet extends StatefulWidget {
  final User? user;
  const _UserFormSheet({this.user});

  @override
  State<_UserFormSheet> createState() => _UserFormSheetState();
}

class _UserFormSheetState extends State<_UserFormSheet> {
  final _nimCtrl = TextEditingController();
  final _namaCtrl = TextEditingController();
  final _prodiCtrl = TextEditingController();
  UserRole _role = UserRole.mahasiswa;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _nimCtrl.text = widget.user!.nim;
      _namaCtrl.text = widget.user!.nama;
      _prodiCtrl.text = widget.user!.prodi ?? '';
      _role = widget.user!.role;
    }
  }

  @override
  void dispose() {
    _nimCtrl.dispose();
    _namaCtrl.dispose();
    _prodiCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_nimCtrl.text.isEmpty || _namaCtrl.text.isEmpty) return;

    // ✅ Mengalihkan fungsi manipulasi data ke AuthController
    final svc = context.read<AuthController>();
    if (widget.user == null) {
      svc.addUser(
        User(
          id: const Uuid().v4(),
          nim: _nimCtrl.text.trim(),
          nama: _namaCtrl.text.trim(),
          role: _role,
          prodi: _prodiCtrl.text.trim().isEmpty ? null : _prodiCtrl.text.trim(),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Akun berhasil dibuat'),
          backgroundColor: AppTheme.accentGreen,
        ),
      );
    } else {
      svc.updateUser(
        User(
          id: widget.user!.id,
          nim: _nimCtrl.text.trim(),
          nama: _namaCtrl.text.trim(),
          role: _role,
          prodi: _prodiCtrl.text.trim().isEmpty ? null : _prodiCtrl.text.trim(),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Akun berhasil diperbarui'),
          backgroundColor: AppTheme.accentGreen,
        ),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.user != null;
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
                  isEdit ? 'Edit Pengguna' : 'Tambah Pengguna',
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
              controller: _nimCtrl,
              decoration: const InputDecoration(
                labelText: 'NIM / NIP',
                prefixIcon: Icon(Icons.badge_outlined, color: AppTheme.accent),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _namaCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                prefixIcon: Icon(Icons.person_outline, color: AppTheme.accent),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _prodiCtrl,
              decoration: const InputDecoration(
                labelText: 'Program Studi',
                prefixIcon: Icon(Icons.school_outlined, color: AppTheme.accent),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Role',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: UserRole.values.map((r) {
                final selected = _role == r;
                return ChoiceChip(
                  label: Text(
                    User(id: '', nim: '', nama: '', role: r).roleLabel,
                  ),
                  selected: selected,
                  onSelected: (_) => setState(() => _role = r),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: isEdit ? 'Simpan Perubahan' : 'Buat Akun',
              onTap: _save,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
