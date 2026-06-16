import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import LandingPage from './pages/LandingPage'; // 🚀 IMPORT HALAMAN PROMOSI BARU LORR
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';

export default function App() {
    return (
        <Router>
            <Routes>
                {/* 🚀 SET LANDING PAGE JADI HALAMAN UTAMA UTK PROMOSI LORR */}
                <Route path="/" element={<LandingPage />} />

                {/* Menggeser halaman Login kalian ke rute /login lorr */}
                <Route path="/login" element={<Login />} />

                {/* Halaman Dashboard Admin tetap aman lorr */}
                <Route path="/dashboard" element={<Dashboard />} />
            </Routes>
        </Router>
    );
}