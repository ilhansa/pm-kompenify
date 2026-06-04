<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\PengajuanKompen;
use App\Models\Mahasiswa;
use Illuminate\Support\Str;

class PengajuanKompenController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'assignment_id' => 'required|uuid', // Atau 'string' tergantung rules kamu sebelumnya
        ]);

        $user = $request->user();

        // 1. Cek Role Mahasiswa
        if ($user->role !== 'mhs') {
            return response()->json([
                'success' => false,
                'message' => 'Hanya mahasiswa yang bisa mengajukan kompen'
            ], 403);
        }

        // 2. Ambil profil mahasiswa berdasarkan user yang login
        $mahasiswa = Mahasiswa::where('user_id', $user->id)->first();

        if (!$mahasiswa) {
            return response()->json([
                'success' => false,
                'message' => 'Data mahasiswa tidak ditemukan'
            ], 404);
        }

        // 3. cek duplikasi
        $sudahPernahDaftar = PengajuanKompen::where('mahasiswa_id', $mahasiswa->id)
                                            ->where('assignment_id', $request->assignment_id)
                                            ->exists(); // exists() akan menghasilkan nilai true/false

        if ($sudahPernahDaftar) {
            return response()->json([
                'success' => false,
                'message' => 'Anda sudah mengajukan kompen untuk tugas ini! Menunggu persetujuan Dosen.'
            ], 409); // Status 409 Conflict (Data bentrok/sudah ada)
        }

        // 4. SIMPAN KE DATABASE JIKA LOLOS
        $pengajuan = PengajuanKompen::create([
            'id' => Str::uuid()->toString(),
            'mahasiswa_id' => $mahasiswa->id, 
            'assignment_id' => $request->assignment_id,
            'status' => 'pending',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pengajuan kompen berhasil dikirim',
            'data' => $pengajuan
        ], 201);
    }

    // view
    // get all
    public function index(Request $request)
    {
        $user = $request->user();

        // 1. Pastikan ini Mahasiswa
        if ($user->role !== 'mhs') {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak! Hanya mahasiswa yang diizinkan.'
            ], 403);
        }

        // 2. Cari data mahasiswa di tabel mahasiswas
        $mahasiswa = Mahasiswa::where('user_id', $user->id)->first();

        if (!$mahasiswa) {
            return response()->json([
                'success' => false,
                'message' => 'Data profil mahasiswa tidak ditemukan'
            ], 404);
        }

        try {
            // 3. Ambil semua pengajuan milik mahasiswa ini
            // (Ditambah orderBy supaya pengajuan terbaru ada di paling atas)
            $riwayatPengajuan = PengajuanKompen::where('mahasiswa_id', $mahasiswa->id)
                                               ->orderBy('created_at', 'desc')
                                               ->get();

            return response()->json([
                'success' => true,
                'message' => 'Berhasil mengambil riwayat pengajuan kompen',
                'data' => $riwayatPengajuan
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data: ' . $e->getMessage()
            ], 500);
        }
    }

    // get details
    public function show(Request $request, $id)
    {
        $user = $request->user();

        // 1. Pastikan ini Mahasiswa
        if ($user->role !== 'mhs') {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak! Hanya mahasiswa yang diizinkan.'
            ], 403);
        }

        // 2. Cari data mahasiswa
        $mahasiswa = Mahasiswa::where('user_id', $user->id)->first();

        if (!$mahasiswa) {
            return response()->json(['success' => false, 'message' => 'Data profil mahasiswa tidak ditemukan'], 404);
        }

        // 3. Cari detail pengajuan berdasarkan ID UUID
        $pengajuan = PengajuanKompen::find($id);

        if (!$pengajuan) {
            return response()->json(['success' => false, 'message' => 'Data pengajuan tidak ditemukan!'], 404);
        }

        // 4. PENJAGA KEPEMILIKAN
        // Cek apakah pengajuan ini benar-benar milik mahasiswa yang sedang login
        if ($pengajuan->mahasiswa_id !== $mahasiswa->id) {
            return response()->json([
                'success' => false, 
                'message' => 'Akses ditolak! Anda tidak bisa melihat pengajuan mahasiswa lain.'
            ], 403);
        }

        return response()->json([
            'success' => true,
            'message' => 'Berhasil mengambil detail pengajuan',
            'data' => $pengajuan
        ], 200);
    }

    //  DELETE (BATALKAN PENGAJUAN)
    public function destroy(Request $request, $id)
    {
        $user = $request->user();

        // 1. Pastikan ini Mahasiswa
        if ($user->role !== 'mhs') {
            return response()->json(['success' => false, 'message' => 'Akses ditolak! Hanya mahasiswa yang diizinkan.'], 403);
        }

        $mahasiswa = Mahasiswa::where('user_id', $user->id)->first();
        if (!$mahasiswa) {
            return response()->json(['success' => false, 'message' => 'Data profil mahasiswa tidak ditemukan'], 404);
        }

        // 2. Cari data pengajuannya
        $pengajuan = PengajuanKompen::find($id);
        if (!$pengajuan) {
            return response()->json(['success' => false, 'message' => 'Data pengajuan tidak ditemukan!'], 404);
        }

        // 3. CEK KEPEMILIKAN (Cuma boleh batalin pengajuan sendiri)
        if ($pengajuan->mahasiswa_id !== $mahasiswa->id) {
            return response()->json([
                'success' => false, 
                'message' => 'Akses ditolak! Anda tidak berhak membatalkan pengajuan orang lain.'
            ], 403);
        }

        // 4. CEK STATUS (Cuma boleh dibatalkan kalau masih pending)
        if ($pengajuan->status !== 'pending') {
            return response()->json([
                'success' => false, 
                'message' => "Pengajuan gagal dibatalkan karena sudah diproses dosen (Status saat ini: $pengajuan->status)."
            ], 403);
        }

        try {
            // 5. Eksekusi Hapus dari Database
            $pengajuan->delete();

            return response()->json([
                'success' => true,
                'message' => 'Pengajuan kompen berhasil dibatalkan!'
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal membatalkan pengajuan: ' . $e->getMessage()
            ], 500);
        }
    }

    // GET: LIHAT DAFTAR PELAMAR (KHUSUS DOSEN/KAPRODI)
    public function indexPemberiKompen(Request $request)
    {
        $user = $request->user();
        $userRole = $user->role;
        $jalurMasuk = $request->segment(2); // Cek URL (dosen/kaprodi)

        // 1. Satpam Pintu Masuk
        if ($userRole !== 'dosen' && $userRole !== 'kaprodi') {
            return response()->json(['success' => false, 'message' => 'Akses ditolak!'], 403);
        }

        if ($userRole !== $jalurMasuk) {
            return response()->json([
                'success' => false, 
                'message' => "Nyasar Bos! Anda login sebagai $userRole, dilarang mengakses jalur $jalurMasuk."
            ], 403);
        }

        try {
            // 2. KUMPULKAN SEMUA ID TUGAS MILIK PEMBERI KOMPEN INI
            $assignmentIds = \App\Models\Assignment::where('dosen_id', $user->id)->pluck('id');

            // 3. CARI PENGAJUAN YANG MASUK KE TUGAS-TUGAS TERSEBUT
            $pengajuans = PengajuanKompen::whereIn('assignment_id', $assignmentIds)
                                         ->with(['mahasiswa', 'assignment']) 
                                         ->orderBy('created_at', 'desc')
                                         ->get();

            return response()->json([
                'success' => true,
                'message' => 'Berhasil mengambil daftar pelamar kompen',
                'data'    => $pengajuans
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data pelamar: ' . $e->getMessage()
            ], 500);
        }
    }

    // GET: LIHAT DAFTAR PENGAJUAN KOMPEN BERDASARKAN 1 ASSIGNMENT SPESIFIK
    public function pengajuanKompenByAssignment(Request $request, $assignment_id)
    {
        $user = $request->user();
        $userRole = $user->role;
        $jalurMasuk = $request->segment(2); // Cek URL (dosen/kaprodi)

        // 1. Satpam Pintu Masuk
        if ($userRole !== 'dosen' && $userRole !== 'kaprodi') {
            return response()->json(['success' => false, 'message' => 'Akses ditolak!'], 403);
        }

        if ($userRole !== $jalurMasuk) {
            return response()->json([
                'success' => false, 
                'message' => "Nyasar Bos! Anda login sebagai $userRole, dilarang mengakses jalur $jalurMasuk."
            ], 403);
        }

        // 2. Cari tugasnya dulu
        $assignment = \App\Models\Assignment::find($assignment_id);

        if (!$assignment) {
            return response()->json(['success' => false, 'message' => 'Data assignment tidak ditemukan!'], 404);
        }

        // 3. Satpam Kepemilikan Tugas
        if ($assignment->dosen_id !== $user->id) {
            return response()->json([
                'success' => false, 
                'message' => 'Akses ditolak! Anda tidak bisa melihat pengajuan di tugas milik dosen lain.'
            ], 403);
        }

        try {
            // 4. Ambil semua pengajuan KHUSUS untuk assignment_id ini saja
            $pengajuans = PengajuanKompen::where('assignment_id', $assignment_id)
                                      ->with('mahasiswa') 
                                      ->orderBy('created_at', 'desc')
                                      ->get();

            return response()->json([
                'success' => true,
                'message' => 'Berhasil mengambil daftar pengajuan kompen untuk tugas ini',
                'data'    => $pengajuans
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data pengajuan kompen: ' . $e->getMessage()
            ], 500);
        }
    }

    // UPDATE: STATUS TERIMA ATAU TOLAK PENGAJUAN (KHUSUS DOSEN/KAPRODI)
    public function updateStatus(Request $request, $id)
    {
        $user = $request->user();
        $userRole = $user->role;
        $jalurMasuk = $request->segment(2); // Cek URL (dosen/kaprodi)

        // 1. Satpam Pintu Masuk
        if ($userRole !== 'dosen' && $userRole !== 'kaprodi') {
            return response()->json(['success' => false, 'message' => 'Akses ditolak!'], 403);
        }

        if ($userRole !== $jalurMasuk) {
            return response()->json([
                'success' => false, 
                'message' => "Nyasar Bos! Anda login sebagai $userRole, dilarang mengakses jalur $jalurMasuk."
            ], 403);
        }

        // 2. Validasi inputan dari Flutter/Postman
        // Hanya menerima kata 'diterima' atau 'ditolak'
        $request->validate([
            'status' => 'required|in:diterima,ditolak'
        ]);

        // 3. Cari pengajuan sekaligus bawa data tugasnya (pakai with)
        $pengajuan = PengajuanKompen::with('assignment')->find($id);

        if (!$pengajuan) {
            return response()->json(['success' => false, 'message' => 'Data pengajuan tidak ditemukan!'], 404);
        }

        // 4. SATPAM KEPEMILIKAN 👮‍♂️
        // Cek: Apakah tugas yang dilamar ini benar-benar buatan dosen yang lagi login?
        if ($pengajuan->assignment->dosen_id !== $user->id) {
            return response()->json([
                'success' => false, 
                'message' => 'Akses ditolak! Anda tidak bisa memproses pengajuan di tugas milik dosen lain.'
            ], 403);
        }

        // 5. Cek apakah status sudah pernah diproses (Opsional, biar dosen ga plin-plan)
        if ($pengajuan->status !== 'pending') {
            return response()->json([
                'success' => false, 
                'message' => "Pengajuan ini sudah diproses sebelumnya (Status: $pengajuan->status)."
            ], 400);
        }

        try {
            // 6. Eksekusi ubah status
            $pengajuan->update([
                'status' => $request->status
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Status pengajuan mahasiswa berhasil diubah menjadi ' . $request->status,
                'data'    => $pengajuan
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengubah status pengajuan: ' . $e->getMessage()
            ], 500);
        }
    }
}