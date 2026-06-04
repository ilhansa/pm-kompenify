import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../api'; 

export default function Login() {
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(false);
    const navigate = useNavigate();
    const [showPassword, setShowPassword] = useState(false);

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
        <div className="font-sans min-h-screen w-full overflow-x-hidden bg-slate-50 flex flex-col sm:justify-center items-center">
            <div className="relative sm:max-w-sm w-full p-4">
                <div className="bg-blue-600 shadow-md w-full h-full rounded-3xl absolute transform -rotate-6 top-0 left-0 opacity-80"></div>
                <div className="bg-amber-400 shadow-md w-full h-full rounded-3xl absolute transform rotate-6 top-0 left-0 opacity-80"></div>
                
                <div className="relative w-full rounded-3xl px-6 py-6 bg-white shadow-xl border border-slate-200">
                    <label className="block mt-3 text-2xl text-blue-600 text-center font-black tracking-wider uppercase">
                        E-Kompenify
                    </label>
                    <p className="text-center text-xs text-slate-500 mt-1 font-medium">Halaman Log Masuk Admin</p>

                    {error && (
                        <div className="mt-4 bg-amber-50 border border-amber-300 text-amber-700 text-xs p-3 rounded-xl text-center font-semibold shadow-sm">
                            {error}
                        </div>
                    )}

                    <form onSubmit={handleLogin} className="mt-10">
                        <div>
                            <label className="text-xs font-bold text-slate-500 uppercase tracking-wide ml-1">Username / NIM</label>
                            <input 
                                type="text" 
                                required
                                placeholder="Username / NIM Admin" 
                                className="mt-1 block w-full border border-slate-300 bg-slate-50 h-11 px-4 rounded-xl text-slate-800 shadow-inner focus:outline-none focus:border-blue-500 focus:bg-white text-sm transition-all placeholder:text-slate-400"
                                value={username}
                                onChange={(e) => setUsername(e.target.value)}
                            />
                        </div>
            
                        <div className="mt-6">                
                            <label className="text-xs font-bold text-slate-500 uppercase tracking-wide ml-1">Password</label>
                            <div className="relative mt-1">
                                <input 
                                    type={showPassword ? "text" : "password"} 
                                    required
                                    placeholder="••••••••" 
                                    className="block w-full border border-slate-300 bg-slate-50 h-11 pl-4 pr-12 rounded-xl text-slate-800 shadow-inner focus:outline-none focus:border-blue-500 focus:bg-white text-sm transition-all placeholder:text-slate-400"
                                    value={password}
                                    onChange={(e) => setPassword(e.target.value)}
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
            
                        <div className="mt-8">
                            <button 
                                type="submit"
                                disabled={loading}
                                className="bg-blue-600 w-full py-3 rounded-xl text-white font-bold shadow-lg hover:bg-blue-700 hover:shadow-blue-500/30 focus:outline-none transition duration-300 ease-in-out transform hover:scale-[1.02] active:scale-[0.98] disabled:opacity-50 text-sm tracking-wide"
                            >
                                {loading ? 'Memvalidasi...' : 'Masuk Sistem'}
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    );
}