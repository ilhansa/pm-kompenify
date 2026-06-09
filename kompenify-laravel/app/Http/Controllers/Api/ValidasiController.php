<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PengajuanKompen;
use Illuminate\Http\Request;

class ValidasiController extends Controller
{
    public function cekDokumen($token)
    {
        // 1. Cari pengajuan yang token Dosen ATAU token Kaprodinya cocok sama yang di-scan
        $pengajuan = PengajuanKompen::with(['mahasiswa.user', 'assignment'])
            ->where('qr_token_dosen', $token)
            ->orWhere('qr_token_kaprodi', $token)
            ->first();

        // 2. Kalau tokennya hasil karangan mahasiswa nakal (nggak ada di database)
        if (!$pengajuan) {
            return response()->json([
                'success' => false,
                'message' => '❌ DOKUMEN PALSU ATAU TIDAK VALID! Token tidak ditemukan di sistem.'
            ], 404);
        }

        // 3. Cari tahu ini token milik Dosen atau Kaprodi agar pesan dinamis
        $pemilikTtd = ($pengajuan->qr_token_kaprodi === $token) ? 'Kepala Program Studi' : 'Dosen Pemberi Tugas';

        // 4. Kembalikan bukti kalau dokumen ini sah (sekarang plus Jam Kompen)
        return response()->json([
            'success' => true,
            'message' => 'DOKUMEN SAH & TERVERIFIKASI',
            'data' => [
                'nama_mahasiswa'      => $pengajuan->mahasiswa->user->nama ?? 'Data Tidak Ditemukan',
                'nim'                 => $pengajuan->mahasiswa->nim ?? '-',
                'tugas_kompen'        => $pengajuan->assignment->judul,
                'jam_kompen'          => $pengajuan->assignment->jam_kompen . ' Jam',
                'status_saat_ini'     => $pengajuan->status,
                'ditandatangani_oleh' => $pemilikTtd,
                'waktu_validasi'      => $pengajuan->updated_at->format('d F Y H:i:s'),
            ]
        ], 200);
    }
}