import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../api'; 

export default function Login() {
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(false);
    const navigate = useNavigate();

    const handleLogin = async (e) => {
        e.preventDefault();
        setLoading(true);
        setError('');
        
        try {
            // Menembak API login backend Laravel (Gunakan properti state 'username')
            const response = await api.post('/login', { username, password });

            if (response.data.success) {
                const user = response.data.user;

                // BARIKADE SAKTI: Filter role tepat setelah sukses API
                if (user.role !== 'admin') {
                    setError('Eits! Akun Anda terdeteksi bukan Admin. Halaman ini terlarang!');
                    return;
                }

                // 1. Simpan token autentikasi di browser jika beneran lolos sebagai Admin
                localStorage.setItem('auth_token', response.data.access_token);
                
                // 2. Simpan data user untuk dipakai di halaman dashboard nanti
                localStorage.setItem('user_data', JSON.stringify(user));

                // Pindah ke halaman dashboard setelah sukses login
                navigate('/dashboard');
            }
        } catch (err) {
            console.error(err);
            setError(err.response?.data?.message || 'Username atau password salah, Bang!');
        } finally {
            setLoading(false);
        }
    }; // <-- Kunci perbaikan ada di sini, kurung penutup fungsi handleLogin sekarang aman!

    return (
        <div className="font-sans">
            <div className="relative min-h-screen flex flex-col sm:justify-center items-center bg-slate-950">
                <div className="relative sm:max-w-sm w-full p-4">
                    {/* Kartu variasi hiasan belakang - Tema Biru & Kuning */}
                    <div className="bg-blue-600 shadow-lg w-full h-full rounded-3xl absolute transform -rotate-6 top-0 left-0"></div>
                    <div className="bg-amber-400 shadow-lg w-full h-full rounded-3xl absolute transform rotate-6 top-0 left-0"></div>
                    
                    {/* Kartu Form Utama */}
                    <div className="relative w-full rounded-3xl px-6 py-6 bg-slate-900 shadow-2xl border border-slate-800">
                        <label className="block mt-3 text-2xl text-amber-400 text-center font-bold tracking-wider uppercase">
                            E-Kompenify
                        </label>
                        <p className="text-center text-xs text-slate-400 mt-1">Halaman Log Masuk Admin</p>

                        {/* Alert jika terjadi error login */}
                        {error && (
                            <div className="mt-4 bg-amber-500/10 border border-amber-500/30 text-amber-400 text-xs p-3 rounded-xl text-center">
                                {error}
                            </div>
                        )}

                        <form onSubmit={handleLogin} className="mt-10">
                            {/* Input Username / NIM */}
                            <div>
                                <input 
                                    type="text" 
                                    required
                                    placeholder="Username / NIM Admin" 
                                    className="mt-1 block w-full border border-slate-700 bg-slate-950 h-11 px-4 rounded-xl text-white shadow-lg focus:outline-none focus:border-blue-500 text-sm transition-all placeholder:text-slate-500"
                                    value={username}
                                    onChange={(e) => setUsername(e.target.value)}
                                />
                            </div>
                
                            {/* Input Password */}
                            <div className="mt-7">                
                                <input 
                                    type="password" 
                                    required
                                    placeholder="Password" 
                                    className="mt-1 block w-full border border-slate-700 bg-slate-950 h-11 px-4 rounded-xl text-white shadow-lg focus:outline-none focus:border-blue-500 text-sm transition-all placeholder:text-slate-500"
                                    value={password}
                                    onChange={(e) => setPassword(e.target.value)}
                                />                           
                            </div>

                            {/* Fitur Ingat Saya */}
                            <div className="mt-7 flex items-center justify-between">
                                <label htmlFor="remember_me" className="inline-flex items-center cursor-pointer">
                                    <input 
                                        id="remember_me" 
                                        type="checkbox" 
                                        className="rounded border-slate-700 bg-slate-950 text-blue-500 focus:ring-0 cursor-pointer" 
                                        name="remember" 
                                    />
                                    <span className="ml-2 text-xs text-slate-400 select-none">
                                        Ingat Saya
                                    </span>
                                </label>
                
                                <div className="text-right">     
                                    <a className="underline text-xs text-slate-400 hover:text-amber-400 transition-colors" href="#">
                                        Lupa Password?
                                    </a>                                                 
                                </div>
                            </div>
                
                            {/* Tombol Submit Login */}
                            <div className="mt-8">
                                <button 
                                    type="submit"
                                    disabled={loading}
                                    className="bg-blue-600 w-full py-3 rounded-xl text-white font-semibold shadow-xl hover:bg-blue-500 focus:outline-none transition duration-300 ease-in-out transform hover:scale-102 active:scale-98 disabled:opacity-50 text-sm"
                                >
                                    {loading ? 'Memvalidasi...' : 'Masuk Sistem'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    );
}