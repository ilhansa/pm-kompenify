<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Assignment;
use Illuminate\Support\Str; // 📝 1. TAMBAHKAN BARIS INI UNTUK MEMANGGIL FUNGSI UUID

class AssignmentController extends Controller
{
    // Create
    public function store(Request $request)
    {
        $userRole = $request->user()->role;
        if ($userRole !== 'dosen' && $userRole !== 'kaprodi') {
            return response()->json(['success' => false, 'message' => 'Akses ditolak!'], 403);
        }

        $request->validate([
            'judul'           => 'required|string',
            'deskripsi'       => 'required|string',
            'jam_kompen'      => 'required|integer',
            'tanggal_mulai'   => 'required|date',
            'tanggal_selesai' => 'required|date', 
        ]);

        try {
            $assignment = Assignment::create([
                'id'              => Str::uuid()->toString(), 
                
                'judul'           => $request->judul,
                'deskripsi'       => $request->deskripsi,
                'jam_kompen'      => $request->jam_kompen,
                'tanggal_mulai'   => $request->tanggal_mulai,
                'tanggal_selesai' => $request->tanggal_selesai,
                'status'          => 'aktif', 
                'dosen_id'        => $request->user()->id, 
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Assignment berhasil dibuat!',
                'data'    => $assignment
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal membuat assignment: ' . $e->getMessage()
            ], 500);
        }
    }

    // Update
    public function update(Request $request, $id)
    {
        // 1. Cek Role (Sama kayak Create)
        $userRole = $request->user()->role;
        if ($userRole !== 'dosen') {
            return response()->json(['success' => false, 'message' => 'Akses ditolak!'], 403);
        }

        // 2. Cari tugasnya di database berdasarkan ID (UUID) yang dikirim di URL
        $assignment = Assignment::find($id);

        // Kalau tugasnya nggak ketemu
        if (!$assignment) {
            return response()->json(['success' => false, 'message' => 'Data assignment tidak ditemukan!'], 404);
        }

        // 3. Cek apakah dosen_id di tugas tersebut SAMA DENGAN id dosen yang lagi login
        if ($assignment->dosen_id !== $request->user()->id) {
            return response()->json([
                'success' => false, 
                'message' => 'Anda tidak berhak mengedit assignment milik dosen lain!'
            ], 403);
        }

        // 4. Validasi inputan baru (pakai 'sometimes' agar dosen boleh update sebagian data saja)
        $request->validate([
            'judul'           => 'sometimes|required|string',
            'deskripsi'       => 'sometimes|required|string',
            'jam_kompen'      => 'sometimes|required|integer',
            'tanggal_mulai'   => 'sometimes|required|date',
            'tanggal_selesai' => 'sometimes|required|date',
            'status'          => 'sometimes|required|string', // Bisa buat update status ke 'selesai'
        ]);

        try {
            // 5. Eksekusi Update ke Database
            // Fungsi update() otomatis menimpa data lama dengan data baru dari $request
            $assignment->update($request->all());

            return response()->json([
                'success' => true,
                'message' => 'Assignment berhasil diperbarui!',
                'data'    => $assignment // Menampilkan wujud data setelah diedit
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengupdate assignment: ' . $e->getMessage()
            ], 500);
        }
    }

    // Delete
    public function destroy(Request $request, $id)
    {
        // 1. PENJAGA PINTU ROLE
        $userRole = $request->user()->role;
        if ($userRole !== 'dosen') {
            return response()->json(['success' => false, 'message' => 'Akses ditolak!'], 403);
        }

        // 2. CARI TUGAS BERDASARKAN UUID
        $assignment = Assignment::find($id);

        if (!$assignment) {
            return response()->json(['success' => false, 'message' => 'Data assignment tidak ditemukan!'], 404);
        }

        // 3. Cek id
        if ($assignment->dosen_id !== $request->user()->id) {
            return response()->json([
                'success' => false, 
                'message' => 'Anda tidak berhak menghapus assignment milik dosen lain!'
            ], 403);
        }

        try {
            // 4. EKSEKUSI HAPUS DARI DATABASE
            $assignment->delete();

            return response()->json([
                'success' => true,
                'message' => 'Assignment berhasil dihapus selamanya!'
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal menghapus assignment: ' . $e->getMessage()
            ], 500);
        }
    }

    // Get View
    // Get All
    public function index(Request $request)
    {
        // 1. Cek Role
        $userRole = $request->user()->role;
        if ($userRole !== 'dosen') {
            return response()->json(['success' => false, 'message' => 'Akses ditolak!'], 403);
        }

        try {
            // 2. Ambil data HANYA yang dosen_id-nya cocok dengan dosen yang login
            // orderBy('created_at', 'desc') supaya tugas yang paling baru ada di paling atas
            $assignments = Assignment::where('dosen_id', $request->user()->id)
                                     ->orderBy('created_at', 'desc')
                                     ->get();

            return response()->json([
                'success' => true,
                'message' => 'Berhasil mengambil daftar assignment',
                'data'    => $assignments
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data: ' . $e->getMessage()
            ], 500);
        }
    }

    // Get Detail
    public function show(Request $request, $id)
    {
        // 1. Cek Role
        $userRole = $request->user()->role;
        if ($userRole !== 'dosen') {
            return response()->json(['success' => false, 'message' => 'Akses ditolak!'], 403);
        }

        // 2. Cari tugasnya
        $assignment = Assignment::find($id);

        if (!$assignment) {
            return response()->json(['success' => false, 'message' => 'Data tidak ditemukan!'], 404);
        }

        // 3. Cek Kepemilikan (Jangan sampai dosen ngintip tugas dosen lain)
        if ($assignment->dosen_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Akses ditolak! Ini bukan assignment Anda.'], 403);
        }

        return response()->json([
            'success' => true,
            'message' => 'Berhasil mengambil detail assignment',
            'data'    => $assignment
        ], 200);
    }
}