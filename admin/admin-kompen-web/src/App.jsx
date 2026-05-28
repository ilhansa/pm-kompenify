// src/App.jsx
import { useState, useEffect } from 'react';
import { db } from './firebase'; 
import { collection, onSnapshot } from 'firebase/firestore';
import Login from './components/Login';
import Dashboard from './components/Dashboard';

function App() {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [adminName, setAdminName] = useState('Admin');
  const [dataUser, setDataUser] = useState([]);
  const [loading, setLoading] = useState(false); // Default false dulu

  // Stream data dari Firebase HANYA AKAN NYALA kalau admin sudah berhasil login!
  useEffect(() => {
    if (!isLoggedIn) return; // Jika belum login, jangan lancang membaca database users

    setLoading(true);
    const usersCollection = collection(db, 'users'); 
    const unsubscribe = onSnapshot(usersCollection, (snapshot) => {
      const listData = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      setDataUser(listData);
      setLoading(false);
    }, (error) => {
      console.error("Gagal ambil data Firebase setelah login:", error);
      setLoading(false);
    });

    return () => unsubscribe();
  }, [isLoggedIn]); // Menunggu trigger state isLoggedIn berubah jadi true

  const handleLoginSuccess = (name) => {
    setAdminName(name);
    setIsLoggedIn(true);
  };

  const handleLogoutSuccess = () => {
    setIsLoggedIn(false);
    setDataUser([]); // Bersihkan data demi keamanan saat logout
  };

  return (
    <>
      {isLoggedIn ? (
        <Dashboard 
          adminName={adminName} 
          dataUser={dataUser} 
          loading={loading} 
          onLogout={handleLogoutSuccess} 
        />
      ) : (
        <Login 
          onLogin={handleLoginSuccess} 
        />
      )}
    </>
  );
}

export default App;