import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../api';

export default function Dashboard() {
    const navigate = useNavigate();
    const [users, setUsers] = useState([]);
    const [adminName, setAdminName] = useState('Admin');

    // State untuk Form Sesuai Fungsi Class Diagram (registerAkun & editAkun)
    const [formData, setFormData] = useState({ id: '', nimNip: '', nama: '', password: '', role: 'mhs' });
    const [isEditing, setIsEditing] = useState(false);
    const [message, setMessage] = useState('');

    useEffect(() => {
        // Cek token, kalau tidak ada tendang balik ke halaman login
        const token = localStorage.getItem('auth_token');
        if (!token) {
            navigate('/');
            return;
        }
        
        // Ambil data profil admin yang sedang login
        const savedUser = JSON.parse(localStorage.getItem('user_data'));
        if (savedUser) setAdminName(savedUser.nama);

        fetchUsers();
    }, [navigate]);

    // 1. Fungsi: lihatDaftarAkun()
    const fetchUsers = async () => {
        try {
            const response = await api.get('/admin/users');
            if (response.data.success) {
                setUsers(response.data.data);
            }
        } catch (error) {
            console.error('Gagal mengambil daftar akun', error);
        }
    };

    // 2. Fungsi: registerAkun() & editAkun()
    const handleSubmit = async (e) => {
        e.preventDefault();
        setMessage('');
        try {
            if (isEditing) {
                // Jalur editAkun(userId, data)
                await api.put(`/admin/users/${formData.id}`, formData);
                setMessage('Akun berhasil diperbarui!');
            } else {
                // Jalur registerAkun(data)
                await api.post('/admin/users', formData);
                setMessage('Akun baru berhasil didaftarkan!');
            }
            // Reset form dan refresh tabel
            setFormData({ id: '', nimNip: '', nama: '', password: '', role: 'mhs' });
            setIsEditing(false);
            fetchUsers();
        } catch (error) {
            setMessage('Proses gagal, periksa kembali inputan.');
        }
    };

    // 3. Fungsi: hapusAkun(userId)
    const handleDelete = async (id, nama) => {
        if (window.confirm(`Apakah kamu yakin ingin menghapus akun ${nama}`)) {
            try {
                const response = await api.delete(`/admin/users/${id}`);

                if (response.data.success) {
                    alert('Akun berhasil dihapus dari sistem!');
                    
                    fetchUsers();
                }
            } catch (err) {
                console.error(err);
                alert(err.response?.data?.message || 'Gagal menghapus akun, coba cek terminal Laravel!');
            }
        }
    };

    const handleLogout = () => {
        localStorage.removeItem('auth_token');
        localStorage.removeItem('user_data');
        navigate('/');
    };

    return (
        <div className="min-h-screen bg-slate-950 text-slate-100 font-sans p-6">
            {/* Topbar / Header */}
            <div className="flex justify-between items-center bg-slate-900 border border-blue-900/40 p-4 rounded-2xl mb-6 shadow-lg">
                <div>
                    <h1 className="text-2xl font-black text-amber-400 tracking-wider">E-KOMPENIFY DASHBOARD</h1>
                    <p className="text-sm text-slate-400">Selamat datang, <span className="text-blue-400 font-bold">{adminName}</span></p>
                </div>
                <button onClick={handleLogout} className="bg-amber-500 hover:bg-amber-600 text-slate-950 font-bold px-4 py-2 rounded-xl transition duration-200 shadow-md">
                    Keluar Sistem
                </button>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Panel Kiri: Form Kelola Akun (register/edit) */}
                <div className="bg-slate-900 border border-blue-900/40 p-6 rounded-2xl h-fit shadow-lg">
                    <h2 className="text-lg font-bold text-amber-400 mb-4 border-b border-blue-900/40 pb-2">
                        {isEditing ? '⚡ EDIT AKUN USER' : '✨ REGISTER AKUN BARU'}
                    </h2>
                    
                    {message && <div className="bg-blue-950 border border-blue-500 text-blue-300 text-xs p-3 rounded-xl mb-4 font-semibold">{message}</div>}

                    <form onSubmit={handleSubmit} className="space-y-4">
                        <div>
                            <label className="text-xs font-bold text-slate-400 uppercase">NIM / NIP / Username</label>
                            <input type="text" value={formData.nimNip} onChange={e => setFormData({...formData, nimNip: e.target.value})} className="w-full bg-slate-950 border border-blue-900/60 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:border-amber-400 text-slate-100" required />
                        </div>
                        <div>
                            <label className="text-xs font-bold text-slate-400 uppercase">Nama Lengkap</label>
                            <input type="text" value={formData.nama} onChange={e => setFormData({...formData, nama: e.target.value})} className="w-full bg-slate-950 border border-blue-900/60 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:border-amber-400 text-slate-100" required />
                        </div>
                        {!isEditing && (
                            <div>
                                <label className="text-xs font-bold text-slate-400 uppercase">Password</label>
                                <input type="password" value={formData.password} onChange={e => setFormData({...formData, password: e.target.value})} className="w-full bg-slate-950 border border-blue-900/60 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:border-amber-400 text-slate-100" required />
                            </div>
                        )}
                        <div>
                            <label className="text-xs font-bold text-slate-400 uppercase">Role Akses</label>
                            <select value={formData.role} onChange={e => setFormData({...formData, role: e.target.value})} className="w-full bg-slate-950 border border-blue-900/60 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:border-amber-400 text-slate-100">
                                <option value="mhs">Mahasiswa</option>
                                <option value="dosen">Dosen</option>
                                <option value="kaprodi">Kaprodi</option>
                                <option value="admin">Admin</option>
                            </select>
                        </div>
                        <div className="flex gap-2 pt-2">
                            <button type="submit" className="w-full bg-blue-600 hover:bg-blue-500 text-white font-bold py-2.5 rounded-xl transition duration-200">
                                {isEditing ? 'Simpan Perubahan' : 'Daftarkan Akun'}
                            </button>
                            {isEditing && (
                                <button type="button" onClick={() => { setIsEditing(false); setFormData({ id: '', nimNip: '', nama: '', password: '', role: 'mhs' }); }} className="w-full bg-slate-800 hover:bg-slate-700 text-slate-300 font-bold py-2.5 rounded-xl transition duration-200">
                                    Batal
                                </button>
                            )}
                        </div>
                    </form>
                </div>

                {/* Panel Kanan: Tabel lihatDaftarAkun() */}
                <div className="lg:col-span-2 bg-slate-900 border border-blue-900/40 p-6 rounded-2xl shadow-lg">
                    <h2 className="text-lg font-bold text-amber-400 mb-4 border-b border-blue-900/40 pb-2">
                        📋 DAFTAR AKUN SISTEM (lihatDaftarAkun)
                    </h2>
                    <div className="overflow-x-auto">
                        <table className="w-full text-left border-collapse">
                            <thead>
                                <tr className="border-b border-blue-900/60 text-slate-400 text-xs uppercase tracking-wider">
                                    <th className="pb-3 pl-2">NIM / NIP</th>
                                    <th className="pb-3">Nama</th>
                                    <th className="pb-3">Role</th>
                                    <th className="pb-3 text-center">Aksi</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-blue-950 text-sm">
                                {users.length === 0 ? (
                                    <tr>
                                        <td colSpan="4" className="py-4 text-center text-slate-500">Belum ada data user dalam sistem.</td>
                                    </tr>
                                ) : (
                                    users.map((user) => (
                                        <tr key={user.id} className="hover:bg-blue-950/20 transition">
                                            <td className="py-3.5 pl-2 font-mono text-blue-400">{user.nimNip}</td>
                                            <td className="py-3.5 font-semibold text-slate-200">{user.nama}</td>
                                            <td className="py-3.5">
                                                <span className={`px-2 py-0.5 rounded-md text-xs font-bold ${user.role === 'admin' ? 'bg-amber-500/10 text-amber-400 border border-amber-500/30' : 'bg-blue-500/10 text-blue-400 border border-blue-500/30'}`}>
                                                    {user.role.toUpperCase()}
                                                </span>
                                            </td>
                                            <td className="py-3.5 text-center space-x-2">
                                                <button onClick={() => { setIsEditing(true); setFormData({ id: user.id, nimNip: user.nimNip, nama: user.nama, role: user.role }); }} className="bg-blue-600 hover:bg-blue-500 text-white text-xs px-3 py-1.5 rounded-lg font-bold transition">
                                                    Edit
                                                </button>
                                                <button
                                                    onClick={() => handleDelete(user.id, user.nama)}
                                                    className="bg-amber-500 hover:bg-amber-400 text-slate-950 text-xs px-3 py-1 rounded-lg font-semibold transition-colors"
                                                >
                                                    Hapus
                                                </button>
                                            </td>
                                        </tr>
                                    ))
                                )}
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    );
}