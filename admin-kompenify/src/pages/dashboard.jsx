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
        let isSuccess = false; // Flag penanda jika proses API benar-benar sukses murni

        try {
            if (isEditing) {
                // Jalur editAkun(userId, data) - Menyertakan password dinamis
                const response = await api.put(`/admin/users/${formData.id}`, {
                    nimNip: formData.nimNip,
                    nama: formData.nama,
                    role: formData.role,
                    password: formData.password // Ikut dikirim, jika kosong backend akan mengabaikannya
                });
                
                if (response.data.success) {
                    setMessage(response.data.message || 'Akun berhasil diperbarui!');
                    isSuccess = true;
                }
            } else {
                // Jalur registerAkun(data)
                const response = await api.post('/admin/users', formData);
                
                if (response.data.success) {
                    setMessage('Akun baru berhasil didaftarkan!');
                    isSuccess = true;
                }
            }
        } catch (error) {
            console.error(error);
            // Menampilkan pesan error spesifik dari backend jika ada (misal: NIM sudah terdaftar)
            setMessage(error.response?.data?.message || 'Proses gagal, periksa kembali inputan.');
        }

        // Eksekusi reset form dan refresh tabel di luar try-catch utama jika API sukses murni
        if (isSuccess) {
            setFormData({ id: '', nimNip: '', nama: '', password: '', role: 'mhs' });
            setIsEditing(false);
            fetchUsers(); // Tabel auto-refresh real-time tanpa delay!
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
        <div className="min-h-screen bg-slate-50 text-slate-800 font-sans p-6 antialiased">
            
            {/* Topbar / Header - Putih bersih dengan bayangan soft */}
            <div className="flex justify-between items-center bg-white border border-slate-200/80 p-5 rounded-2xl mb-6 shadow-sm">
                <div>
                    <h1 className="text-xl font-black text-blue-600 tracking-wider">E-KOMPENIFY DASHBOARD</h1>
                    <p className="text-xs text-slate-500 mt-0.5 font-medium">
                        Selamat datang, <span className="text-amber-500 font-bold">{adminName}</span>
                    </p>
                </div>
                <button 
                    onClick={handleLogout} 
                    className="bg-blue-600 hover:bg-blue-700 text-white text-xs uppercase tracking-wider font-bold px-5 py-2.5 rounded-xl transition duration-200 shadow-md shadow-blue-500/10"
                >
                    Keluar Sistem
                </button>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Panel Kiri: Form Kelola Akun (Putih Bersih) */}
                <div className="bg-white border border-slate-200/80 p-6 rounded-2xl h-fit shadow-sm">
                    <h2 className="text-xs font-black text-blue-600 tracking-widest mb-5 border-b border-slate-100 pb-3 uppercase">
                        {isEditing ? 'Ubah Akun User' : 'Daftar Akun Baru'}
                    </h2>
                    
                    {/* Alert Banner Notifikasi */}
                    {message && (
                        <div className="bg-blue-50 border border-blue-200 text-blue-700 text-xs p-3 rounded-xl mb-5 font-semibold shadow-inner">
                            {message}
                        </div>
                    )}

                    <form onSubmit={handleSubmit} className="space-y-4">
                        <div>
                            <label className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block mb-1 ml-0.5">NIM / NIP / Username</label>
                            <input 
                                type="text" 
                                value={formData.nimNip} 
                                onChange={e => setFormData({...formData, nimNip: e.target.value})} 
                                className="w-full bg-slate-50/80 border border-slate-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:border-blue-500 focus:bg-white text-slate-800 shadow-inner transition-all placeholder:text-slate-400" 
                                placeholder="Masukkan nomor identitas..."
                                required 
                            />
                        </div>
                        <div>
                            <label className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block mb-1 ml-0.5">Nama Lengkap</label>
                            <input 
                                type="text" 
                                value={formData.nama} 
                                onChange={e => setFormData({...formData, nama: e.target.value})} 
                                className="w-full bg-slate-50/80 border border-slate-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:border-blue-500 focus:bg-white text-slate-800 shadow-inner transition-all placeholder:text-slate-400" 
                                placeholder="Nama lengkap user..."
                                required 
                            />
                        </div>
                        
                        <div>
                            <label className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block mb-1 ml-0.5">
                                {isEditing ? 'Password Baru (Kosongkan jika tidak diubah)' : 'Password'}
                            </label>
                            <input 
                                type="password" 
                                value={formData.password || ''} 
                                onChange={e => setFormData({...formData, password: e.target.value})} 
                                className="w-full bg-slate-50/80 border border-slate-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:border-blue-500 focus:bg-white text-slate-800 shadow-inner transition-all placeholder:text-slate-400" 
                                placeholder={isEditing ? "Masukkan password baru jika ingin mereset..." : "••••••••"}
                                required={!isEditing} 
                            />
                        </div>

                        <div>
                            <label className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block mb-1 ml-0.5">Role Akses</label>
                            <select 
                                value={formData.role} 
                                onChange={e => setFormData({...formData, role: e.target.value})} 
                                className="w-full bg-slate-50/80 border border-slate-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:border-blue-500 focus:bg-white text-slate-800 shadow-inner cursor-pointer transition-all"
                            >
                                <option value="mhs">Mahasiswa</option>
                                <option value="dosen">Dosen</option>
                                <option value="kaprodi">Kaprodi</option>
                                <option value="admin">Admin</option>
                            </select>
                        </div>
                        
                        <div className="flex gap-2 pt-2">
                            <button type="submit" className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-2.5 rounded-xl transition duration-200 text-xs uppercase tracking-wider shadow-sm">
                                {isEditing ? 'Simpan' : 'Daftarkan'}
                            </button>
                            {isEditing && (
                                <button 
                                    type="button" 
                                    onClick={() => { setIsEditing(false); setFormData({ id: '', nimNip: '', nama: '', password: '', role: 'mhs' }); }} 
                                    className="w-full bg-slate-100 hover:bg-slate-200 text-slate-600 font-bold py-2.5 rounded-xl transition duration-200 text-xs uppercase tracking-wider"
                                >
                                    Batal
                                </button>
                            )}
                        </div>
                    </form>
                </div>

                {/* Panel Kanan: Tabel Akun Sistem (Putih Bersih) */}
                <div className="lg:col-span-2 bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden">
                    {/* Header Panel */}
                    <div className="p-6 pb-4 flex flex-col space-y-1.5">
                        <h3 className="text-lg font-semibold leading-none tracking-tight text-slate-900">
                            Daftar Akun Sistem
                        </h3>
                        <p className="text-sm text-slate-500 font-medium">
                            Manajemen seluruh data akun pengguna yang terdaftar di dalam sistem.
                        </p>
                    </div>

                    {/* Table Container dengan style border tipis ala Shadcn */}
                    <div className="px-6 pb-6">
                        <div className="w-full overflow-auto border border-slate-200 rounded-lg">
                            <table className="w-full caption-bottom text-sm border-collapse">
                                {/* Header Tabel ala Shadcn: text-muted, font-medium, border-b */}
                                <thead className="bg-slate-50/70 border-b border-slate-200">
                                    <tr className="text-slate-500 font-medium text-xs transition-colors">
                                        <th className="h-10 px-4 text-left align-middle font-medium tracking-wide">NIM / NIP</th>
                                        <th className="h-10 px-4 text-left align-middle font-medium tracking-wide">Nama</th>
                                        <th className="h-10 px-4 text-left align-middle font-medium tracking-wide">Role</th>
                                        <th className="h-10 px-4 text-center align-middle font-medium tracking-wide">Aksi</th>
                                    </tr>
                                </thead>

                                {/* Body Tabel: border-b tipis, row tebal h-12 */}
                                <tbody className="divide-y divide-slate-200/60">
                                    {users.length === 0 ? (
                                        <tr>
                                            <td colSpan="4" className="p-8 text-center text-slate-500 font-medium align-middle">
                                                Belum ada data user dalam sistem.
                                            </td>
                                        </tr>
                                    ) : (
                                        users.map((user) => (
                                            <tr 
                                                key={user.id} 
                                                className="border-b border-slate-200 text-slate-700 transition-colors hover:bg-slate-50/50 data-[state=selected]:bg-slate-100"
                                            >
                                                {/* Kolom NIM/NIP */}
                                                <td className="p-4 align-middle font-mono text-xs font-semibold text-blue-600">
                                                    {user.nimNip}
                                                </td>

                                                {/* Kolom Nama */}
                                                <td className="p-4 align-middle font-medium text-slate-900">
                                                    {user.nama}
                                                </td>

                                                {/* Kolom Role Badge */}
                                                <td className="p-4 align-middle">
                                                    <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold tracking-wide border transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 ${
                                                        user.role === 'admin' 
                                                            ? 'bg-amber-50 text-amber-700 border-amber-200/60' 
                                                            : 'bg-blue-50 text-blue-700 border-blue-100'
                                                    }`}>
                                                        {user.role}
                                                    </span>
                                                </td>

                                                {/* Kolom Aksi */}
                                                <td className="p-4 align-middle text-center space-x-2">
                                                    {/* Button Edit Ala Shadcn (Outline Variant) */}
                                                    <button 
                                                        onClick={() => { setIsEditing(true); setFormData({ id: user.id, nimNip: user.nimNip, nama: user.nama, role: user.role }); }} 
                                                        className="inline-flex items-center justify-center rounded-md text-xs font-medium border border-slate-200 bg-white h-8 px-3 hover:bg-slate-100 hover:text-slate-900 transition-colors shadow-sm focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-slate-400"
                                                    >
                                                        Edit
                                                    </button>
                                                    
                                                    {/* Button Hapus Ala Shadcn (Destructive Variant adaptasi Kuning/Amber) */}
                                                    <button
                                                        onClick={() => handleDelete(user.id, user.nama)}
                                                        className="inline-flex items-center justify-center rounded-md text-xs font-medium bg-amber-500 text-white h-8 px-3 hover:bg-amber-600 transition-colors shadow-sm focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-slate-400"
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
        </div>
    );
}