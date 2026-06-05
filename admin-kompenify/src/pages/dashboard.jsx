import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../api';

export default function Dashboard() {
    const navigate = useNavigate();
    const [users, setUsers] = useState([]);
    const [adminName, setAdminName] = useState('Admin');

    const [formData, setFormData] = useState({ id: '', nimNip: '', nama: '', password: '', role: 'mhs' });
    const [isEditing, setIsEditing] = useState(false);
    const [selectedProdi, setSelectedProdi] = useState('');
    const [message, setMessage] = useState('');
    const [showPassword, setShowPassword] = useState(false);

    useEffect(() => {
        const token = localStorage.getItem('auth_token');
        if (!token) {
            navigate('/');
            return;
        }
        
        const savedUser = JSON.parse(localStorage.getItem('user_data'));
        if (savedUser) setAdminName(savedUser.nama);

        fetchUsers();
    }, [navigate]);

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

    const handleSubmit = async (e) => {
        e.preventDefault();
        setMessage('');
        let isSuccess = false;

        try {
            if (isEditing) {
                const response = await api.put(`/admin/users/${formData.id}`, {
                    nimNip: formData.nimNip,
                    nama: formData.nama,
                    role: formData.role,
                    password: formData.password,
                    prodi: formData.role === 'mhs' ? selectedProdi : null
                });
                
                if (response.data.success) {
                    setMessage(response.data.message || 'Akun berhasil diperbarui!');
                    isSuccess = true;
                }
            } else {
                const dataToSend = {
                    ...formData,
                    prodi: formData.role === 'mhs' ? selectedProdi : null
                };

                const response = await api.post('/admin/users', dataToSend);
                
                if (response.data.success) {
                    setMessage('Akun baru berhasil didaftarkan!');
                    isSuccess = true;
                }
            }
        } catch (error) {
            console.error(error);
            setMessage(error.response?.data?.message || 'Proses gagal, periksa kembali inputan.');
        }

        if (isSuccess) {
            setFormData({ id: '', nimNip: '', nama: '', password: '', role: 'mhs' });
            setSelectedProdi('');
            setIsEditing(false);
            fetchUsers();
        }
    };

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
        <div className="min-h-screen w-full overflow-x-hidden bg-slate-50 text-slate-800 font-sans p-6 antialiased">
            
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
                <div className="bg-white border border-slate-200/80 p-6 rounded-2xl h-fit shadow-sm">
                    <h2 className="text-xs font-black text-blue-600 tracking-widest mb-5 border-b border-slate-100 pb-3 uppercase">
                        {isEditing ? 'Ubah Akun User' : 'Daftar Akun Baru'}
                    </h2>
                    
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
                            <div className="relative mt-1">
                                <input 
                                    type={showPassword ? "text" : "password"} 
                                    value={formData.password || ''} 
                                    onChange={e => setFormData({...formData, password: e.target.value})} 
                                    className="w-full bg-slate-50/80 border border-slate-200 rounded-xl pl-4 pr-12 py-2.5 text-sm focus:outline-none focus:border-blue-500 focus:bg-white text-slate-800 shadow-inner transition-all placeholder:text-slate-400" 
                                    placeholder={isEditing ? "Masukkan password baru jika ingin mereset..." : "••••••••"}
                                    required={!isEditing} 
                                />
                                
                                <button
                                    type="button"
                                    onClick={() => setShowPassword(!showPassword)}
                                    className="absolute right-3 top-1/2 transform -translate-y-1/2 text-slate-400 hover:text-blue-600 active:scale-95 transition-all select-none focus:outline-none p-1"
                                    title={showPassword ? "Sembunyikan Password" : "Lihat Password"}
                                >
                                    {showPassword ? (
                                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={2} stroke="currentColor" className="w-5 h-5">
                                            <path strokeLinecap="round" strokeLinejoin="round" d="M3.98 8.223A10.477 10.477 0 0 0 1.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.451 10.451 0 0 1 12 4.5c4.756 0 8.773 3.162 10.065 7.498a10.522 10.522 0 0 1-4.293 5.774M6.228 6.228 3 3m3.228 3.228 3.65 3.65m7.894 7.894L21 21m-3.228-3.228-3.65-3.65m0 0a3 3 0 1 0-4.243-4.243m4.242 4.242L9.88 9.88" />
                                        </svg>
                                    ) : (
                                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={2} stroke="currentColor" className="w-5 h-5">
                                            <path strokeLinecap="round" strokeLinejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z" />
                                            <path strokeLinecap="round" strokeLinejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
                                        </svg>
                                    )}
                                </button>
                            </div>
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

                        {formData.role === 'mhs' && (
                            <div className="animate-fadeIn">
                                <label className="text-[10px] font-extrabold text-slate-400 uppercase tracking-wider block mb-1 ml-0.5">Program Studi</label>
                                <select 
                                    value={selectedProdi} 
                                    onChange={e => setSelectedProdi(e.target.value)} 
                                    className="w-full bg-slate-50/80 border border-slate-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:border-blue-500 focus:bg-white text-slate-800 shadow-inner cursor-pointer transition-all"
                                    required
                                >
                                    <option value="">-- Pilih Prodi --</option>
                                    <option value="D4 Teknik Informatika">D4 Teknik Informatika</option>
                                    <option value="D4 Sistem Informasi Bisnis">D4 Sistem Informasi Bisnis</option>
                                </select>
                            </div>
                        )}
                        
                        <div className="flex gap-2 pt-2">
                            <button type="submit" className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-2.5 rounded-xl transition duration-200 text-xs uppercase tracking-wider shadow-sm">
                                {isEditing ? 'Simpan' : 'Daftarkan'}
                            </button>
                            {isEditing && (
                                <button 
                                    type="button" 
                                    onClick={() => { setIsEditing(false); setFormData({ id: '', nimNip: '', nama: '', password: '', role: 'mhs' }); setSelectedProdi(''); }} 
                                    className="w-full bg-slate-100 hover:bg-slate-200 text-slate-600 font-bold py-2.5 rounded-xl transition duration-200 text-xs uppercase tracking-wider"
                                >
                                    Batal
                                </button>
                            )}
                        </div>
                    </form>
                </div>

                <div className="lg:col-span-2 bg-white border border-slate-200 rounded-xl shadow-sm overflow-hidden">
                    <div className="p-6 pb-4 flex flex-col space-y-1.5">
                        <h3 className="text-lg font-semibold leading-none tracking-tight text-slate-900">
                            Daftar Akun Sistem
                        </h3>
                        <p className="text-sm text-slate-500 font-medium">
                            Manajemen seluruh data akun pengguna yang terdaftar di dalam sistem.
                        </p>
                    </div>

                    <div className="px-6 pb-6">
                        <div className="w-full overflow-auto border border-slate-200 rounded-lg">
                            <table className="w-full caption-bottom text-sm border-collapse">
                                <thead className="bg-slate-50/70 border-b border-slate-200">
                                    <tr className="text-slate-500 font-medium text-xs transition-colors">
                                        <th className="h-10 px-4 text-left align-middle font-medium tracking-wide">NIM / NIP</th>
                                        <th className="h-10 px-4 text-left align-middle font-medium tracking-wide">Nama</th>
                                        <th className="h-10 px-4 text-left align-middle font-medium tracking-wide">Role</th>
                                        <th className="h-10 px-4 text-center align-middle font-medium tracking-wide">Aksi</th>
                                    </tr>
                                </thead>

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
                                                <td className="p-4 align-middle font-mono text-xs font-semibold text-blue-600">
                                                    {user.nimNip}
                                                </td>
                                                <td className="p-4 align-middle font-medium text-slate-900">
                                                    {user.nama}
                                                </td>
                                                <td className="p-4 align-middle">
                                                    <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-semibold tracking-wide border transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 ${
                                                        user.role === 'admin' 
                                                            ? 'bg-amber-50 text-amber-700 border-amber-200/60' 
                                                            : 'bg-blue-50 text-blue-700 border-blue-100'
                                                    }`}>
                                                        {user.role}
                                                    </span>
                                                </td>
                                                <td className="p-4 align-middle text-center space-x-2">
                                                    <button 
                                                        onClick={() => { 
                                                            setIsEditing(true); 
                                                            setFormData({ id: user.id, nimNip: user.nimNip, nama: user.nama, role: user.role, password: '' }); 
                                                            setSelectedProdi(user.role === 'mhs' ? user.prodi || '' : '');
                                                        }} 
                                                        className="inline-flex items-center justify-center rounded-md text-xs font-medium border border-slate-200 bg-white h-8 px-3 hover:bg-slate-100 hover:text-slate-900 transition-colors shadow-sm focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-slate-400"
                                                    >
                                                        Edit
                                                    </button>
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