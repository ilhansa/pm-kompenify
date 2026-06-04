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
}