import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';

const LandingPage = () => {
  const navigate = useNavigate();
  const [activeFaq, setActiveFaq] = useState(null);

  // Palet Warna Google Premium - Dominasi Putih Bersih (90%)
  const theme = {
    bgMain: '#FFFFFF',        
    bgSec: '#F8F9FA',         
    bgCard: '#FFFFFF',        
    googleBiru: '#1A73E8',    
    googleKuning: '#FBBC05',  
    textDark: '#202124',      
    textSecondary: '#5F6368', 
    borderTipis: '#DADCE0',
    shadowHalus: '0 1px 2px 0 rgba(60,64,67,0.3), 0 1px 3.5px 1px rgba(60,64,67,0.15)'
  };

  const toggleFaq = (index) => {
    setActiveFaq(activeFaq === index ? null : index);
  };

  return (
    <div style={{ backgroundColor: theme.bgMain, color: theme.textDark, fontFamily: '"Google Sans", Roboto, Arial, sans-serif', minHeight: '100vh', overflowX: 'hidden', WebkitFontSmoothing: 'antialiased' }}>
      
      {/* ─── NAVBAR SECTION ─── */}
      <nav style={{ padding: '16px 40px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', backgroundColor: theme.bgCard, borderBottom: `1px solid ${theme.borderTipis}`, position: 'sticky', top: 0, zIndex: 100, boxShadow: '0 1px 3px 0 rgba(60,64,67,0.1)' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          {/* Icon Logo SVG murni */}
          <div style={{ backgroundColor: '#E8F0FE', padding: '8px', borderRadius: '8px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <svg style={{ width: '24px', height: '24px', color: theme.googleBiru }} fill="none" viewBox="0 0 24 24" strokeWidth="2.5" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" d="M4.26 10.174L10.74 2.147a1 1 0 011.52 0l6.48 8.027a1 1 0 01.144 1.005l-2.4 5.6A1 1 0 0115.54 17.5h-7.08a1 1 0 01-.944-.62l-2.4-5.6a1 1 0 01.144-1.005z" />
              <path strokeLinecap="round" strokeLinejoin="round" d="M12 7v5m0 3h.01" />
            </svg>
          </div>
          <div style={{ display: 'flex', flexDirection: 'column' }}>
            <span style={{ fontSize: '18px', fontWeight: '700', color: theme.googleBiru, letterSpacing: '-0.3px', lineHeight: '1.2' }}>E-KOMPENIFY</span>
            <span style={{ fontSize: '11px', color: theme.textSecondary, fontWeight: '500' }}>Platform Manajemen Kompensasi</span>
          </div>
        </div>
        
        {/* Menu Navigasi Tengah Kontemporer */}
        <div style={{ display: 'flex', gap: '28px', fontSize: '14px', fontWeight: '500' }}>
          <a href="#alur" style={{ color: theme.textSecondary, textDecoration: 'none', transition: 'color 0.2s' }} onMouseOver={(e) => e.target.style.color = theme.googleBiru} onMouseOut={(e) => e.target.style.color = theme.textSecondary}>Alur Sistem</a>
          <a href="#pengguna" style={{ color: theme.textSecondary, textDecoration: 'none', transition: 'color 0.2s' }} onMouseOver={(e) => e.target.style.color = theme.googleBiru} onMouseOut={(e) => e.target.style.color = theme.textSecondary}>Hak Akses</a>
          <a href="#fitur" style={{ color: theme.textSecondary, textDecoration: 'none', transition: 'color 0.2s' }} onMouseOver={(e) => e.target.style.color = theme.googleBiru} onMouseOut={(e) => e.target.style.color = theme.textSecondary}>Fitur Utama</a>
          <a href="#faq" style={{ color: theme.textSecondary, textDecoration: 'none', transition: 'color 0.2s' }} onMouseOver={(e) => e.target.style.color = theme.googleBiru} onMouseOut={(e) => e.target.style.color = theme.textSecondary}>FAQ</a>
        </div>

        <button 
          onClick={() => navigate('/login')} 
          style={{ backgroundColor: theme.googleBiru, color: '#FFFFFF', border: 'none', padding: '10px 24px', borderRadius: '4px', fontSize: '14px', fontWeight: '600', cursor: 'pointer', transition: 'background-color 0.2s ease', boxShadow: '0 1px 2px 0 rgba(60,64,67,0.3)' }}
          onMouseOver={(e) => e.target.style.backgroundColor = '#1557B0'}
          onMouseOut={(e) => e.target.style.backgroundColor = theme.googleBiru}
        >
          Masuk Sistem
        </button>
      </nav>

      {/* ─── HERO SECTION ─── */}
      <header style={{ padding: '80px 40px 40px 40px', maxWidth: '900px', margin: '0 auto', textAlign: 'center' }}>
        <div style={{ display: 'inline-flex', alignItems: 'center', gap: '6px', backgroundColor: '#FFF7E0', color: '#B06000', fontSize: '12px', fontWeight: '700', padding: '6px 16px', borderRadius: '4px', marginBottom: '28px', border: `1px solid ${theme.googleKuning}40` }}>
          <svg style={{ width: '14px', height: '14px', color: theme.googleKuning, flexShrink: 0 }} fill="currentColor" viewBox="0 0 24 24">
            <path d="M12 2L1 21h22L12 2zm0 4l7.53 13H4.47L12 6zm-1 6v4h2v-4h-2zm0-3v2h2V9h-2z"/>
          </svg>
          SOLUSI DIGITALISASI BIROKRASI JURUSAN
        </div>
        <h1 style={{ fontSize: '44px', fontWeight: '700', lineHeight: '1.25', color: theme.textDark, letterSpacing: '-1px', marginBottom: '24px' }}>
          Optimalisasi Kompensasi Mahasiswa <br />
          <span style={{ color: theme.googleBiru }}>Tanpa Hambatan Berkas Fisik</span>
        </h1>
        <p style={{ color: theme.textSecondary, fontSize: '16px', lineHeight: '1.6', maxWidth: '680px', margin: '0 auto 48px auto' }}>
          E-Kompenify hadir untuk mendigitalisasi seluruh proses pencatatan, pemantauan waktu pengerjaan tugas, hingga penerbitan Surat Bebas Kompensasi tervalidasi QR Code dalam satu ekosistem yang terintegrasi.
        </p>
        <div style={{ display: 'flex', gap: '12px', justifyContent: 'center' }}>
          <button 
            onClick={() => navigate('/login')}
            style={{ backgroundColor: theme.googleBiru, color: '#FFFFFF', border: 'none', padding: '12px 30px', borderRadius: '4px', fontSize: '14px', fontWeight: '600', cursor: 'pointer', boxShadow: '0 1px 3px 0 rgba(60,64,67,0.3)' }}
          >
            Akses Web Dashboard
          </button>
          <button 
            style={{ backgroundColor: theme.bgCard, color: theme.googleBiru, border: `1px solid ${theme.borderTipis}`, padding: '12px 30px', borderRadius: '4px', fontSize: '14px', fontWeight: '600', cursor: 'pointer' }}
            onClick={() => alert('Aplikasi Mobile E-Kompenify siap diunduh melalui platform internal program studi.')}
          >
            Unduh Aplikasi Android
          </button>
        </div>
      </header>

      {/* ─── SECTION: ANALYTICS DIGITAL ─── */}
      <section style={{ padding: '0 40px 60px 40px', maxWidth: '1050px', margin: '0 auto' }}>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '24px' }}>
          {[
            { num: '0%', txt: 'Penggunaan Kertas (Paperless)' },
            { num: '< 5 Menit', txt: 'Persetujuan Berkas Massal' },
            { num: '50 Jam', txt: 'Batas Maksimal Validasi Tugas' },
            { num: '100%', txt: 'Akurasi Sinkronisasi Server' }
          ].map((item, i) => (
            <div key={i} style={{ backgroundColor: theme.bgCard, padding: '24px', borderRadius: '8px', border: `1px solid ${theme.borderTipis}`, textAlign: 'center', boxShadow: '0 1px 2px 0 rgba(60,64,67,0.05)' }}>
              <h3 style={{ fontSize: '32px', fontWeight: '700', color: theme.googleBiru, margin: 0 }}>{item.num}</h3>
              <p style={{ color: theme.textSecondary, fontSize: '13px', fontWeight: '500', margin: '8px 0 0 0' }}>{item.txt}</p>
            </div>
          ))}
        </div>
      </section>

      {/* ─── THE PROBLEM SECTION ─── */}
      <section style={{ backgroundColor: theme.bgSec, padding: '80px 40px', borderTop: `1px solid ${theme.borderTipis}`, borderBottom: `1px solid ${theme.borderTipis}` }}>
        <div style={{ maxWidth: '1050px', margin: '0 auto', display: 'flex', gap: '24px', flexWrap: 'wrap' }}>
          <div style={{ flex: '1 1 450px', padding: '32px', borderRadius: '8px', backgroundColor: theme.bgCard, border: `1px solid ${theme.borderTipis}`, boxShadow: '0 1px 2px 0 rgba(60,64,67,0.05)' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '16px' }}>
              <svg style={{ width: '22px', height: '22px', color: theme.googleKuning, flexShrink: 0 }} fill="none" viewBox="0 0 24 24" strokeWidth="2" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" d="M12 9v3.75m9-.75a9 9 0 11-18 0 9 9 0 0118 0zm-9 3.75h.008v.008H12v-.008z" />
              </svg>
              <h3 style={{ fontSize: '18px', fontWeight: '600', color: theme.textDark, margin: 0 }}>Metode Konvensional</h3>
            </div>
            <p style={{ color: theme.textSecondary, fontSize: '14px', lineHeight: '1.6', margin: 0 }}>
              Prosedur manual memicu antrean fisik di administrasi jurusan, risiko kehilangan dokumen fisik, keterlambatan pengesahan akibat kesibukan pimpinan, serta potensi ketidakakuratan rekapitulasi sisa jam kompensasi.
            </p>
          </div>
          <div style={{ flex: '1 1 450px', padding: '32px', borderRadius: '8px', backgroundColor: theme.bgCard, border: `1px solid ${theme.borderTipis}`, boxShadow: '0 1px 2px 0 rgba(60,64,67,0.05)' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px', color: theme.googleBiru, marginBottom: '16px' }}>
              <svg style={{ width: '22px', height: '22px', flexShrink: 0 }} fill="none" viewBox="0 0 24 24" strokeWidth="2" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" d="M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              <h3 style={{ fontSize: '18px', fontWeight: '600', color: theme.textDark, margin: 0 }}>Solusi E-Kompenify</h3>
            </div>
            <p style={{ color: theme.textSecondary, fontSize: '14px', lineHeight: '1.6', margin: 0 }}>
              Menawarkan sistem alokasi tugas penugasan yang transparan, otomatisasi pencatatan waktu pengerjaan berbasis server, serta validasi tanda tangan elektronik pimpinan guna mewujudkan manajemen administrasi yang efisien.
            </p>
          </div>
        </div>
      </section>

      {/* ─── NEW SECTION: TARGET PENGGUNA EKOSISTEM (USER ROLES) ─── */}
      <section id="pengguna" style={{ padding: '80px 40px', maxWidth: '1050px', margin: '0 auto' }}>
        <h2 style={{ textAlign: 'center', fontSize: '28px', fontWeight: '700', marginBottom: '12px', color: theme.textDark }}>Manajemen Peran Pengguna</h2>
        <p style={{ textAlign: 'center', color: theme.textSecondary, fontSize: '15px', marginBottom: '48px' }}>Pembagian hak akses terstruktur guna menjaga integritas dan validitas data ekosistem.</p>
        
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '24px' }}>
          {/* Peran 1: Mahasiswa */}
          <div style={{ backgroundColor: theme.bgCard, padding: '32px', borderRadius: '8px', border: `1px solid ${theme.borderTipis}`, boxShadow: '0 1px 2px 0 rgba(60,64,67,0.02)' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
              <div style={{ backgroundColor: '#E8F0FE', color: theme.googleBiru, padding: '10px', borderRadius: '6px' }}>
                <svg style={{ width: '20px', height: '20px' }} fill="none" viewBox="0 0 24 24" strokeWidth="2" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M4.26 10.174L10.74 2.147a1 1 0 011.52 0l6.48 8.027a1 1 0 01.144 1.005l-2.4 5.6A1 1 0 0115.54 17.5h-7.08a1 1 0 01-.944-.62l-2.4-5.6a1 1 0 01.144-1.005z" />
                </svg>
              </div>
              <h3 style={{ fontSize: '16px', fontWeight: '700', color: theme.textDark, margin: 0 }}>Peran Mahasiswa</h3>
            </div>
            <p style={{ color: theme.textSecondary, fontSize: '13.5px', lineHeight: '1.6', margin: 0 }}>
              Melakukan pemantauan akumulasi sisa jam tanggungan secara dinamis, memilih penugasan aktif secara kompetitif (*war* slot), mengunggah berkas bukti penyelesaian, serta mengunduh Surat Bebas Kompensasi mandiri.
            </p>
          </div>

          {/* Peran 2: Dosen */}
          <div style={{ backgroundColor: theme.bgCard, padding: '32px', borderRadius: '8px', border: `1px solid ${theme.borderTipis}`, boxShadow: '0 1px 2px 0 rgba(60,64,67,0.02)' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
              <div style={{ backgroundColor: '#E8F0FE', color: theme.googleBiru, padding: '10px', borderRadius: '6px' }}>
                <svg style={{ width: '20px', height: '20px' }} fill="none" viewBox="0 0 24 24" strokeWidth="2" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M12 14l9-5-9-5-9 5 9 5zm0 0l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 14zm0 0zm0 0l-6.16-3.422a12.083 12.083 0 00-.665 6.479A11.952 11.952 0 0112 14z" />
                </svg>
              </div>
              <h3 style={{ fontSize: '16px', fontWeight: '700', color: theme.textDark, margin: 0 }}>Peran Dosen Pemberi Tugas</h3>
            </div>
            <p style={{ color: theme.textSecondary, fontSize: '13.5px', lineHeight: '1.6', margin: 0 }}>
              Memiliki wewenang penuh merilis spesifikasi sub-tugas penugasan baru, menyeleksi pelamar mahasiswa, melakukan verifikasi kelayakan hasil kerja, serta membubuhkan instan spesimen Tanda Tangan Elektronik (E-TTD) tahap awal.
            </p>
          </div>

          {/* Peran 3: Kaprodi */}
          <div style={{ backgroundColor: theme.bgCard, padding: '32px', borderRadius: '8px', border: `1px solid ${theme.borderTipis}`, boxShadow: '0 1px 2px 0 rgba(60,64,67,0.02)' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
              <div style={{ backgroundColor: '#E8F0FE', color: theme.googleBiru, padding: '10px', borderRadius: '6px' }}>
                <svg style={{ width: '20px', height: '20px' }} fill="none" viewBox="0 0 24 24" strokeWidth="2" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
                </svg>
              </div>
              <h3 style={{ fontSize: '16px', fontWeight: '700', color: theme.textDark, margin: 0 }}>Peran Ketua Program Studi</h3>
            </div>
            <p style={{ color: theme.textSecondary, fontSize: '13.5px', lineHeight: '1.6', margin: 0 }}>
              Bertindak sebagai otoritas pengawas tertinggi (Mata Dewa), melakukan pengesahan (*approval*) final kolektif seluruh berkas kompen se-jurusan, serta menyematkan E-TTD pamungkas yang otomatis memotong akumulasi sisa jam wajib mahasiswa.
            </p>
          </div>
        </div>
      </section>

      {/* ─── ALUR KERJA TERINTEGRASI (STEP-BY-STEP) ─── */}
      <section id="alur" style={{ backgroundColor: theme.bgSec, padding: '80px 40px', borderTop: `1px solid ${theme.borderTipis}`, borderBottom: `1px solid ${theme.borderTipis}` }}>
        <div style={{ maxWidth: '850px', margin: '0 auto' }}>
          <h2 style={{ textAlign: 'center', fontSize: '28px', fontWeight: '700', marginBottom: '12px', color: theme.textDark }}>Alur Kerja Ekosistem Digital</h2>
          <p style={{ textAlign: 'center', color: theme.textSecondary, fontSize: '15px', marginBottom: '48px' }}>Mekanisme integrasi data yang menghubungkan Dosen, Mahasiswa, dan Ketua Program Studi.</p>
          
          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            {[
              { step: '1', title: 'Publikasi Tugas oleh Dosen', desc: 'Dosen pengampu merilis tugas kompensasi baru beserta bobot jam kontribusi melalui dashboard admin internal.' },
              { step: '2', title: 'Alokasi Pengajuan & Pelacakan Waktu', desc: 'Sistem secara otomatis mencatat tanggal mulai pengerjaan pada server database sesaat setelah dosen menyetujui pelamar tugas.' },
              { step: '3', title: 'Validasi Akhir & Penerbitan Dokumen', desc: 'Setelah tugas diselesaikan, validasi dilakukan berjenjang melalui Tanda Tangan Elektronik sah untuk menerbitkan Surat Bebas Kompensasi format PDF.' }
            ].map((item, index) => (
              <div key={index} style={{ display: 'flex', gap: '20px', backgroundColor: theme.bgCard, padding: '24px', borderRadius: '8px', border: `1px solid ${theme.borderTipis}`, alignItems: 'center', boxShadow: '0 1px 2px 0 rgba(60,64,67,0.02)' }}>
                <div style={{ backgroundColor: '#E8F0FE', color: theme.googleBiru, width: '36px', height: '36px', borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: '700', flexShrink: 0, fontSize: '15px' }}>{item.step}</div>
                <div>
                  <h4 style={{ margin: '0 0 6px 0', fontSize: '15px', fontWeight: '600', color: theme.textDark }}>{item.title}</h4>
                  <p style={{ margin: 0, color: theme.textSecondary, fontSize: '13.5px', lineHeight: '1.5' }}>{item.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ─── FEATURES SECTION ─── */}
      <section id="fitur" style={{ padding: '80px 40px', maxWidth: '1050px', margin: '0 auto' }}>
        <h2 style={{ textAlign: 'center', fontSize: '28px', fontWeight: '700', color: theme.textDark, marginBottom: '48px' }}>Fitur Utama Sistem</h2>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: '24px' }}>
          
          {/* Card 1 */}
          <div style={{ backgroundColor: theme.bgCard, padding: '28px', borderRadius: '8px', border: `1px solid ${theme.borderTipis}`, boxShadow: '0 1px 2px 0 rgba(60,64,67,0.05)' }}>
            <div style={{ width: '40px', height: '40px', borderRadius: '4px', backgroundColor: '#E8F0FE', color: theme.googleBiru, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: '20px' }}>
              <svg style={{ width: '20px', height: '20px' }} fill="none" viewBox="0 0 24 24" strokeWidth="2" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" d="M15 19.128a9.38 9.38 0 002.625.372 9.337 9.337 0 004.121-.952 4.125 4.125 0 00-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 018.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0111.964-3.07M12 6.375a3.375 3.375 0 11-6.75 0 3.375 3.375 0 016.75 0zm8.25 2.25a2.625 2.625 0 11-5.25 0 2.625 2.625 0 015.25 0z" />
              </svg>
            </div>
            <h4 style={{ fontSize: '16px', fontWeight: '600', marginBottom: '10px', color: theme.textDark }}>Alokasi Penugasan</h4>
            <p style={{ color: theme.textSecondary, fontSize: '13px', lineHeight: '1.6', margin: 0 }}>Fasilitas distribusi tugas kompensasi secara transparan yang dapat diakses oleh mahasiswa secara kompetitif dan real-time.</p>
          </div>

          {/* Card 2 */}
          <div style={{ backgroundColor: theme.bgCard, padding: '28px', borderRadius: '8px', border: `1px solid ${theme.borderTipis}`, boxShadow: '0 1px 2px 0 rgba(60,64,67,0.05)' }}>
            <div style={{ width: '40px', height: '40px', borderRadius: '4px', backgroundColor: '#E8F0FE', color: theme.googleBiru, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: '20px' }}>
              <svg style={{ width: '20px', height: '20px' }} fill="none" viewBox="0 0 24 24" strokeWidth="2" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
            </div>
            <h4 style={{ fontSize: '16px', fontWeight: '600', marginBottom: '10px', color: theme.textDark }}>Pelacakan Otomatis</h4>
            <p style={{ color: theme.textSecondary, fontSize: '13px', lineHeight: '1.6', margin: 0 }}>Pencatatan tanggal mulai dan batas waktu penyelesaian terkonfigurasi otomatis menggunakan standardisasi server host.</p>
          </div>

          {/* Card 3 */}
          <div style={{ backgroundColor: theme.bgCard, padding: '28px', borderRadius: '8px', border: `1px solid ${theme.borderTipis}`, boxShadow: '0 1px 2px 0 rgba(60,64,67,0.05)' }}>
            <div style={{ width: '40px', height: '40px', borderRadius: '4px', backgroundColor: '#E8F0FE', color: theme.googleBiru, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: '20px' }}>
              <svg style={{ width: '20px', height: '20px' }} fill="none" viewBox="0 0 24 24" strokeWidth="2" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" d="M16.862 4.487l1.687-1.688a1.875 1.875 0 112.652 2.652L10.582 16.07a4.5 4.5 0 01-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 011.13-1.897l8.932-8.931zm0 0L19.5 7.125M18 14v4.75A2.25 2.25 0 0115.75 21H5.25A2.25 2.25 0 013 18.75V8.25A2.25 2.25 0 015.25 6H10" />
              </svg>
            </div>
            <h4 style={{ fontSize: '16px', fontWeight: '600', marginBottom: '10px', color: theme.textDark }}>Pengesahan Elektronik</h4>
            <p style={{ color: theme.textSecondary, fontSize: '13px', lineHeight: '1.6', margin: 0 }}>Ketua Program Studi dapat melakukan pengesahan dokumen kelulusan kompensasi secara kolektif dalam satu tindakan.</p>
          </div>

          {/* Card 4 */}
          <div style={{ backgroundColor: theme.bgCard, padding: '28px', borderRadius: '8px', border: `1px solid ${theme.borderTipis}`, boxShadow: '0 1px 2px 0 rgba(60,64,67,0.05)' }}>
            <div style={{ width: '40px', height: '40px', borderRadius: '4px', backgroundColor: '#E8F0FE', color: theme.googleBiru, display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: '20px' }}>
              <svg style={{ width: '20px', height: '20px' }} fill="none" viewBox="0 0 24 24" strokeWidth="2" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 00-3.375-3.375h-1.5A1.125 1.125 0 0113.5 7.125v-1.5a3.375 3.375 0 00-3.375-3.375H8.25m2.25 0H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 00-9-9z" />
              </svg>
            </div>
            <h4 style={{ fontSize: '16px', fontWeight: '600', marginBottom: '10px', color: theme.textDark }}>Pelaporan Terverifikasi</h4>
            <p style={{ color: theme.textSecondary, fontSize: '13px', lineHeight: '1.6', margin: 0 }}>Ekspor surat bebas kompensasi ke format dokumen PDF resmi yang dilengkapi dengan enkripsi token QR-Code guna mencegah pemalsuan.</p>
          </div>

        </div>
      </section>

      {/* ─── FAQ INTERAKTIF ─── */}
      <section id="faq" style={{ backgroundColor: theme.bgSec, padding: '80px 40px', borderTop: `1px solid ${theme.borderTipis}`, borderBottom: `1px solid ${theme.borderTipis}` }}>
        <div style={{ maxWidth: '800px', margin: '0 auto' }}>
          <h2 style={{ textAlign: 'center', fontSize: '28px', fontWeight: '700', marginBottom: '40px', color: theme.textDark }}>Pertanyaan yang Sering Diajukan</h2>
          
          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            {[
              { q: 'Apakah pelacakan tanggal pengerjaan terjamin keamanannya?', a: 'Seluruh pencatatan tanggal menggunakan stempel waktu server (internal server timestamp) pada backend Laravel saat aksi verifikasi dieksekusi. Hal ini meminimalkan risiko manipulasi waktu dari perangkat lokal.' },
              { q: 'Bagaimana cara memverifikasi keabsahan berkas PDF yang dicetak?', a: 'Pihak administrasi jurusan dapat melakukan pemindaian pada QR Code yang tertera di dokumen fisik. Sistem akan mencocokkan token enkripsi untuk memastikan orisinalitas dokumen.' },
              { q: 'Apakah terdapat batasan pengisian nilai jam kompensasi?', a: 'Benar. Guna menjaga standarisasi beban kerja, sistem membatasi alokasi jam kompensasi maksimal sebesar 50 jam untuk setiap satu sub-tugas penugasan.' }
            ].map((faq, idx) => (
              <div key={idx} style={{ backgroundColor: theme.bgCard, borderRadius: '8px', border: `1px solid ${theme.borderTipis}`, overflow: 'hidden' }}>
                <button 
                  onClick={() => toggleFaq(idx)}
                  style={{ width: '100%', padding: '20px 24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', backgroundColor: 'transparent', border: 'none', textAlign: 'left', fontWeight: '600', fontSize: '15px', cursor: 'pointer', color: theme.textDark }}
                >
                  <span>{faq.q}</span>
                  <svg style={{ width: '16px', height: '16px', transform: activeFaq === idx ? 'rotate(180deg)' : 'rotate(0deg)', transition: 'transform 0.2s', color: theme.textSecondary }} fill="none" viewBox="0 0 24 24" strokeWidth="2.5" stroke="currentColor">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M19.5 8.25l-7.5 7.5-7.5-7.5" />
                  </svg>
                </button>
                {activeFaq === idx && (
                  <div style={{ padding: '0 24px 20px 24px', color: theme.textSecondary, fontSize: '13.5px', lineHeight: '1.6', borderTop: `1px solid ${theme.borderTipis}`, paddingTop: '16px', backgroundColor: '#FAFAFA' }}>
                    {faq.a}
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ─── FOOTER CTA ─── */}
      <footer style={{ textAlign: 'center', padding: '50px 40px', backgroundColor: theme.bgCard }}>
        <p style={{ fontSize: '14px', color: theme.textSecondary, marginBottom: '16px' }}>Siap mendigitalisasi birokrasi kompensasi di lingkungan program studi Anda?</p>
        <div style={{ fontSize: '13px', fontWeight: '600', color: theme.googleBiru }}>Dikembangkan secara profesional oleh Tim PBL Kelompok 4 © 2026</div>
      </footer>

    </div>
  );
};

export default LandingPage;