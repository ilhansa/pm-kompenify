// src/components/Dashboard.jsx
import { useState } from 'react';
import { getAuth, createUserWithEmailAndPassword } from 'firebase/auth';
import { db } from '../firebase';
import { doc, setDoc, updateDoc, deleteDoc } from 'firebase/firestore';

function Dashboard({ adminName, dataUser, loading, onLogout }) {
  const [nimNip, setNimNip] = useState('');
  const [nama, setNama] = useState('');
  const [password, setPassword] = useState('');
  const [role, setRole] = useState('mahasiswa');
  const [editId, setEditId] = useState(null);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!nimNip || !nama || !password) return alert('Semua data wajib diisi, Bang!');

    try {
      const payload = { nimNip, nama, password, role };

      if (editId) {
        // --- PROSES EDIT DATA ---
        const userDocRef = doc(db, 'users', editId);
        await updateDoc(userDocRef, payload);
        setEditId(null);
        alert('Akun berhasil diperbarui di Database!');
      } else {
        // --- PROSES REGISTER BARU (AUTH + FIRESTORE) ---
        const auth = getAuth();
        
        // 1. Buat format email otomatis dari NIM/NIP untuk kebutuhan Firebase Auth
        const emailOtomatis = `${nimNip}@kompenify.local`;

        // 2. Daftarkan ke Firebase Authentication resmi
        const userCredential = await createUserWithEmailAndPassword(auth, emailOtomatis, password);
        const newUid = userCredential.user.uid; // Mengambil UID unik dari Auth

        // 3. Simpan biodata ke Firestore menggunakan UID Auth sebagai ID Dokumen
        // Ini wajib supya mematuhi Rules 'request.auth.uid == userId' milik teman abang
        await setDoc(doc(db, 'users', newUid), payload);
        
        alert(`Akun ${nama} berhasil diregistrasi ke Auth & Database! Siap login di Flutter.`);
      }

      // Reset form input
      setNimNip('');
      setNama('');
      setPassword('');
      setRole('mahasiswa');
    } catch (error) {
      console.error("Error simpan data:", error);
      if (error.code === 'auth/email-already-in-use') {
        alert('NIM/NIP ini sudah terdaftar di Firebase Authentication, Bang!');
      } else if (error.code === 'auth/weak-password') {
        alert('Password terlalu lemah, minimal 6 karakter ya, Bang!');
      } else {
        alert('Gagal memproses data: ' + error.message);
      }
    }
  };

  const handleEditClick = (user) => {
    setEditId(user.id);
    setNimNip(user.nimNip || '');
    setNama(user.nama || '');
    setPassword(user.password || '');
    setRole(user.role || 'mahasiswa');
  };

  const handleBatalEdit = () => {
    setEditId(null);
    setNimNip('');
    setNama('');
    setPassword('');
    setRole('mahasiswa');
  };

  const handleHapusAkun = async (userId) => {
    if (window.confirm('Yakin mau menghapus akun ini dari database?')) {
      try {
        const userDocRef = doc(db, 'users', userId);
        await deleteDoc(userDocRef);
        alert('Akun berhasil dihapus dari Database!\n\nNote: Untuk menghapus data Auth-nya secara total, silakan hapus juga di Firebase Console menu Authentication.');
      } catch (error) {
        console.error("Gagal menghapus akun:", error);
        alert('Gagal menghapus akun: Insufficient Permissions.');
      }
    }
  };

  return (
    <div style={styles.mainLayout}>
      {/* SIDEBAR */}
      <div style={styles.sidebar}>
        <div style={{ fontSize: '20px', fontWeight: 'bold', color: '#f59e0b', marginBottom: '40px' }}>⚡ E-KOMPEN ADMIN</div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
          <div style={styles.sidebarActiveItem}>👥 Manajemen Akun</div>
        </div>
        <button onClick={onLogout} style={styles.logoutBtn}>🚪 Logout Sistem</button>
      </div>

      {/* CONTENT RIGHT */}
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column' }}>
        {/* HEADER */}
        <div style={styles.header}>
          <div>{loading ? <span style={{ color: '#f59e0b' }}>Connecting...</span> : <span style={{ color: '#10b981', fontWeight: '600' }}>🟢 Live Sync Firebase</span>}</div>
          <div style={{ fontSize: '14px', fontWeight: '600' }}>{adminName} (Admin)</div>
        </div>

        {/* CONTAINER */}
        <div style={styles.container}>
          {/* FORM */}
          <div style={styles.cardForm}>
            <h3 style={{ margin: '0 0 20px 0', color: '#f59e0b' }}>{editId ? '📝 Edit Akun User' : '➕ Register Akun Baru'}</h3>
            <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              <div>
                <label style={styles.fieldLabel}>NIM / NIP</label>
                {/* Kita disable NIM/NIP saat edit karena UID Auth tidak bisa diubah sembarangan */}
                <input type="text" value={nimNip} onChange={(e) => setNimNip(e.target.value)} disabled={!!editId} style={{...styles.inputField, opacity: editId ? 0.5 : 1}} placeholder="Masukkan NIM/NIP..." />
              </div>
              <div>
                <label style={styles.fieldLabel}>Nama Lengkap</label>
                <input type="text" value={nama} onChange={(e) => setNama(e.target.value)} style={styles.inputField} placeholder="Masukkan nama..." />
              </div>
              <div>
                <label style={styles.fieldLabel}>Password</label>
                <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} style={styles.inputField} placeholder="Masukkan password..." />
              </div>
              <div>
                <label style={styles.fieldLabel}>Role</label>
                <select value={role} onChange={(e) => setRole(e.target.value)} style={styles.inputField}>
                  <option value="mahasiswa">Mahasiswa</option>
                  <option value="dosen">Dosen</option>
                  <option value="admin">Admin</option>
                </select>
              </div>
              <button type="submit" style={styles.submitBtn}>{editId ? 'Simpan Perubahan' : 'Register Akun'}</button>
              {editId && <button type="button" onClick={handleBatalEdit} style={styles.cancelBtn}>Batal Edit</button>}
            </form>
          </div>

          {/* TABEL */}
          <div style={styles.cardTable}>
            <h3 style={{ margin: '0 0 20px 0', color: '#38bdf8' }}>🎓 Daftar Akun Terdaftar</h3>
            {dataUser.length === 0 ? (
              <div style={{ textAlign: 'center', padding: '20px', color: '#64748b' }}>Belum ada akun terdaftar.</div>
            ) : (
              <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
                <thead>
                  <tr style={{ borderBottom: '2px solid #334155', color: '#38bdf8', fontSize: '14px' }}>
                    <th style={{ padding: '12px' }}>NIM/NIP</th>
                    <th style={{ padding: '12px' }}>Nama</th>
                    <th style={{ padding: '12px' }}>Role</th>
                    <th style={{ padding: '12px', textAlign: 'center' }}>Aksi</th>
                  </tr>
                </thead>
                <tbody>
                  {dataUser.map((user) => (
                    <tr key={user.id} style={{ borderBottom: '1px solid #334155', fontSize: '14px' }}>
                      <td style={{ padding: '12px', fontFamily: 'monospace' }}>{user.nimNip}</td>
                      <td style={{ padding: '12px', fontWeight: '500' }}>{user.nama}</td>
                      <td style={{ padding: '12px' }}>
                        <span style={{ 
                          backgroundColor: user.role === 'admin' ? '#78350f' : user.role === 'dosen' ? '#1e3a8a' : '#312e81', 
                          color: user.role === 'admin' ? '#f59e0b' : user.role === 'dosen' ? '#93c5fd' : '#c7d2fe', 
                          padding: '2px 8px', 
                          borderRadius: '4px', 
                          fontSize: '12px' 
                        }}>
                          {user.role || 'mahasiswa'}
                        </span>
                      </td>
                      <td style={{ padding: '12px', display: 'flex', gap: '10px', justifyContent: 'center' }}>
                        <button onClick={() => handleEditClick(user)} style={styles.editBtn}>Edit</button>
                        <button onClick={() => handleHapusAkun(user.id)} style={styles.deleteBtn}>Hapus</button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

// --- SEPARATE STYLES OBJECT ---
const styles = {
  mainLayout: { display: 'flex', backgroundColor: '#0f172a', color: '#f8fafc', minHeight: '100vh', fontFamily: '"Inter", sans-serif' },
  sidebar: { width: '260px', backgroundColor: '#1e293b', borderRight: '1px solid #334155', padding: '24px', display: 'flex', flexDirection: 'column' },
  sidebarActiveItem: { padding: '12px 16px', backgroundColor: '#0f172a', color: '#f59e0b', borderRadius: '8px', fontWeight: '600' },
  logoutBtn: { marginTop: 'auto', padding: '10px', backgroundColor: '#475569', color: '#fff', border: 'none', borderRadius: '6px', cursor: 'pointer', fontWeight: 'bold' },
  header: { height: '70px', backgroundColor: '#1e293b', borderBottom: '1px solid #334155', display: 'flex', alignItems: 'center', justifyBetween: 'space-between', padding: '0 40px' },
  container: { padding: '40px', flex: 1, overflowY: 'auto', display: 'flex', gap: '30px' },
  cardForm: { width: '350px', backgroundColor: '#1e293b', padding: '24px', borderRadius: '12px', border: '1px solid #334155', height: 'fit-content' },
  cardTable: { flex: 1, backgroundColor: '#1e293b', padding: '24px', borderRadius: '12px', border: '1px solid #334155' },
  fieldLabel: { fontSize: '13px', color: '#94a3b8', display: 'block', marginBottom: '6px' },
  inputField: { width: '100%', padding: '10px', borderRadius: '6px', backgroundColor: '#0f172a', border: '1px solid #334155', color: '#fff', boxSizing: 'border-box' },
  submitBtn: { padding: '12px', backgroundColor: '#38bdf8', color: '#0f172a', border: 'none', borderRadius: '6px', fontWeight: 'bold', cursor: 'pointer', marginTop: '10px' },
  cancelBtn: { padding: '8px', backgroundColor: '#64748b', color: '#fff', border: 'none', borderRadius: '6px', cursor: 'pointer', marginTop: '5px' },
  editBtn: { padding: '6px 12px', backgroundColor: '#f59e0b', color: '#0f172a', border: 'none', borderRadius: '4px', fontWeight: '600', cursor: 'pointer' },
  deleteBtn: { padding: '6px 12px', backgroundColor: '#475569', color: '#fff', border: 'none', borderRadius: '4px', cursor: 'pointer' }
};

export default Dashboard;