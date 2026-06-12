<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PengajuanKompen;
use App\Models\User;
use Illuminate\Http\Request;

class ValidasiController extends Controller
{
    // Jika kamu masih butuh endpoint JSON untuk internal mobile apps (Opsional)
    public function cekDokumen($token)
    {
        $pengajuan = PengajuanKompen::with(['mahasiswa.user', 'assignment.dosen'])
            ->where('qr_token_dosen', $token)
            ->orWhere('qr_token_kaprodi', $token)
            ->first();

        if (!$pengajuan) {
            return response()->json([
                'success' => false,
                'message' => '❌ DOKUMEN PALSU ATAU TIDAK VALID! Token tidak ditemukan.'
            ], 404);
        }

        if ($pengajuan->qr_token_kaprodi === $token) {
            $jabatan = 'Kepala Program Studi';
            $namaPenandatangan = User::where('role', 'kaprodi')->first()->nama ?? 'Kepala Program Studi';
        } else {
            $jabatan = 'Dosen Pemberi Tugas';
            $namaPenandatangan = $pengajuan->assignment->dosen->nama ?? 'Dosen Pemberi Tugas';
        }

        return response()->json([
            'success' => true,
            'message' => 'DOKUMEN SAH & TERVERIFIKASI',
            'data' => [
                'nama_mahasiswa'      => $pengajuan->mahasiswa->user->nama ?? 'Data Tidak Ditemukan',
                'nim'                 => $pengajuan->mahasiswa->nim ?? '-',
                'tugas_kompen'        => $pengajuan->assignment->judul,
                'jam_kompen'          => $pengajuan->assignment->jam_kompen . ' Jam',
                'status_saat_ini'     => $pengajuan->status,
                'ditandatangani_oleh' => $namaPenandatangan,
                'jabatan'             => $jabatan,
                'waktu_validasi'      => $pengajuan->updated_at->format('d F Y H:i:s'),
            ]
        ], 200);
    }

    // ==========================================
    // GET: HALAMAN WEB VERIFIKASI QR CODE DI HP USER (TAMPILAN PAS DISCAN)
    // ==========================================
    public function validasiDokumen($token)
    {
        // 🚀 Mengambil data lengkap beserta dosen pemberi tugas
        $pengajuan = PengajuanKompen::with(['mahasiswa.user', 'assignment.dosen'])
            ->where('qr_token_dosen', $token)
            ->orWhere('qr_token_kaprodi', $token)
            ->first();

        // 1. Jika token palsu atau tidak ketemu
        if (!$pengajuan) {
            return response("
                <div style='text-align:center; margin-top:50px; font-family:sans-serif; padding: 20px;'>
                    <h1 style='color:#e74c3c;'>❌ DOKUMEN TIDAK VALID!</h1>
                    <p style='color:#555;'>Kode QR ini tidak terdaftar di sistem Kompenify.</p>
                    <p style='font-size:13px; color:#999;'>Waspada terhadap tindakan pemalsuan surat bebas kompensasi.</p>
                </div>
            ", 404);
        }

        // 2. DETEKSI OTOMATIS PEMILIK TTD & JABATANNYA
        if ($pengajuan->qr_token_kaprodi === $token) {
            $jabatan = 'Kepala Program Studi';
            // Mencari user dengan role kaprodi untuk mengambil namanya secara dinamis
            $namaPenandatangan = User::where('role', 'kaprodi')->first()->nama ?? 'Kepala Program Studi';
        } else {
            $jabatan = 'Dosen Pemberi Tugas';
            // Mengambil nama dosen pemberi tugas dari relasi assignment
            $namaPenandatangan = $pengajuan->assignment->dosen->nama ?? ($pengajuan->assignment->dosen->user->nama ?? 'Dosen Pemberi Tugas');
        }

        $namaMhs = $pengajuan->mahasiswa->user->nama ?? 'Data Tidak Ditemukan';
        $nim = $pengajuan->mahasiswa->nim ?? '-';
        $tugas = $pengajuan->assignment->judul;
        $jam = $pengajuan->assignment->jam_kompen;
        $status = strtoupper($pengajuan->status);
        $waktuSah = $pengajuan->updated_at->format('d M Y - HH:mm') . ' WIB';

        return response("
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset='UTF-8'>
                <meta name='viewport' content='width=device-width, initial-scale=1.0'>
                <title>Verifikasi Digital Kompenify</title>
                <style>
                    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f4f6f9; color: #333; padding: 20px; display: flex; justify-content: center; margin: 0; }
                    .card { background: white; padding: 25px; border-radius: 16px; box-shadow: 0 10px 25px rgba(0,0,0,0.05); max-width: 440px; width: 100%; border-top: 8px solid #2ecc71; margin-top: 10px; }
                    .badge { background: #2ecc71; color: white; padding: 6px 14px; border-radius: 20px; font-size: 11px; font-weight: bold; display: inline-block; margin-bottom: 18px; text-transform: uppercase; letter-spacing: 0.5px; }
                    h3 { margin: 0 0 10px 0; color: #2c3e50; font-size: 20px; }
                    .desc { font-size: 13px; color: #7f8c8d; line-height: 1.5; margin-bottom: 20px; }
                    .section-title { font-size: 11px; font-weight: bold; color: #b2bec3; text-transform: uppercase; letter-spacing: 1px; margin-top: 15px; margin-bottom: 5px; border-bottom: 1px solid #f1f2f6; padding-bottom: 3px; }
                    table { width: 100%; border-collapse: collapse; }
                    td { padding: 6px 0; font-size: 14px; vertical-align: top; }
                    .label { color: #7f8c8d; width: 35%; }
                    .value { color: #2d3436; font-weight: 500; }
                    .footer { text-align: center; margin-top: 30px; font-size: 11px; color: #a4b0be; border-top: 1px dashed #eceff1; padding-top: 15px; line-height: 1.4; }
                </style>
            </head>
            <body>
                <div class='card'>
                    <div class='badge'>✓ Verified Digital</div>
                    <h3>Validasi Surat Sah</h3>
                    <div class='desc'>Dokumen Surat Keterangan Bebas Kompensasi ini dinyatakan <strong>ASLI & VALID</strong> secara hukum oleh sistem akademik Kompenify.</div>
                    
                    <div class='section-title'>Informasi Mahasiswa</div>
                    <table>
                        <tr><td class='label'>Nama</td><td class='value'>: {$namaMhs}</td></tr>
                        <tr><td class='label'>NIM</td><td class='value'>: {$nim}</td></tr>
                    </table>

                    <div class='section-title'>Detail Tugas Kompen</div>
                    <table>
                        <tr><td class='label'>Tugas</td><td class='value'>: {$tugas}</td></tr>
                        <tr><td class='label'>Bobot Waktu</td><td class='value'>: {$jam} Jam</td></tr>
                        <tr><td class='label'>Status Berkas</td><td class='value' style='color:#2ecc71; font-weight:bold;'>: {$status}</td></tr>
                    </table>

                    <div class='section-title'>Otoritas Penandatangan</div>
                    <table>
                        <tr><td class='label'>Nama</td><td class='value'>: <strong>{$namaPenandatangan}</strong></td></tr>
                        <tr><td class='label'>Jabatan</td><td class='value'>: {$jabatan}</td></tr>
                        <tr><td class='label'>Waktu Sah</td><td class='value'>: {$waktuSah}</td></tr>
                    </table>

                    <div class='footer'>
                        Dokumen ini diamankan dengan kriptografi token digital terpusat.<br>
                        <strong>Kompenify Security System @ 2026</strong>
                    </div>
                </div>
            </body>
            </html>
        ");
    }
}