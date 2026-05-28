// src/components/Login.jsx
import { useState } from 'react';
import { getAuth, signInWithEmailAndPassword } from 'firebase/auth'; 
import { db } from '../firebase';
import { doc, getDoc } from 'firebase/firestore'; 

function Login({ onLogin }) {
  const [loginEmail, setLoginEmail] = useState('');
  const [loginPassword, setLoginPassword] = useState('');
  const [loadingBtn, setLoadingBtn] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!loginEmail || !loginPassword) return alert('Isi Email dan Password-nya dulu, Bang!');

    setLoadingBtn(true);
    const auth = getAuth();

    // JALUR KHUSUS BYPASS DEV (Biar kalau offline atau butuh cepat tetap bisa masuk)
    if (loginEmail === 'admin@kompenify.local' && loginPassword === 'admin123') {
      onLogin('Sultan Admin (Bypass)');
      alert('Login Berhasil via Jalur Khusus Developer!');
      setLoadingBtn(false);
      return; // Stop eksekusi ke Firebase
    }

    try {
      // 1. Login resmi ke Firebase Authentication
      const userCredential = await signInWithEmailAndPassword(auth, loginEmail, loginPassword);
      const loggedInUid = userCredential.user.uid;

      // 2. Ambil dokumen spesifik milik UID ini di Firestore (Lolos rules)
      const docRef = doc(db, 'users', loggedInUid);
      const docSnap = await getDoc(docRef);

      if (docSnap.exists()) {
        const userData = docSnap.data();
        
        // 3. Validasi apakah rolenya beneran admin
        if (userData.role === 'admin') {
          onLogin(userData.nama || 'Sultan Admin');
          alert(`Login Berhasil! Selamat Datang, ${userData.nama || 'Admin'}.`);
        } else {
          alert('Akun terdaftar di Auth, namun Anda bukan Admin di database Firestore!');
        }
      } else {
        alert('Akun Auth sukses, tapi data profil Anda tidak ditemukan di Firestore!');
      }
    } catch (error) {
      console.error(error);
      alert('Login Gagal: Email atau password salah, atau jaringan bermasalah!');
    } finally {
      setLoadingBtn(false);
    }
  };

  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-slate-950 px-4 py-12 font-sans text-slate-100">
      <div className="w-full max-w-md rounded-xl border border-slate-800 bg-slate-900 shadow-2xl p-6 sm:p-8 space-y-6">
        
        <div className="text-center space-y-2">
          <div className="mx-auto text-3xl text-amber-400">⚡</div>
          <h1 className="text-2xl font-bold tracking-tight text-amber-400">Welcome back</h1>
          <p className="text-sm text-slate-400">Secure Admin Login via Firebase Auth</p>
        </div>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div className="space-y-1.5">
            <label className="text-sm font-medium text-slate-300 block">Email Admin</label>
            <input
              type="email"
              value={loginEmail}
              onChange={(e) => setLoginEmail(e.target.value)}
              placeholder="admin@kompenify.local"
              required
              className="flex h-10 w-full rounded-md border border-slate-800 bg-slate-950 px-3 py-2 text-sm text-slate-100 placeholder:text-slate-500 focus:outline-none focus:ring-2 focus:ring-sky-500 transition-all"
            />
          </div>

          <div className="space-y-1.5">
            <div className="flex items-center justify-between">
              <label className="text-sm font-medium text-slate-300">Password</label>
            </div>
            <input
              type="password"
              value={loginPassword}
              onChange={(e) => setLoginPassword(e.target.value)}
              placeholder="••••••••"
              required
              className="flex h-10 w-full rounded-md border border-slate-800 bg-slate-950 px-3 py-2 text-sm text-slate-100 placeholder:text-slate-500 focus:outline-none focus:ring-2 focus:ring-sky-500 transition-all"
            />
          </div>

          <button
            type="submit"
            disabled={loadingBtn}
            className="flex h-10 w-full items-center justify-center rounded-md bg-sky-500 px-4 py-2 text-sm font-bold text-slate-950 hover:bg-sky-400 transition-colors focus:outline-none focus:ring-2 focus:ring-sky-600 disabled:bg-slate-700 disabled:text-slate-400 cursor-pointer"
          >
            {loadingBtn ? 'Authenticating...' : 'Login Secure'}
          </button>
        </form>
      </div>
    </div>
  );
}

export default Login;