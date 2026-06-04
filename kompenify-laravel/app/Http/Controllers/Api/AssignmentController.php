<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Assignment;
use Illuminate\Support\Str;

class AssignmentController extends Controller
{
    // CREATE
    public function store(Request $request)
    {
        $userRole = $request->user()->role;
        $jalurMasuk = $request->segment(2); // Membaca URL (dosen/kaprodi)

        if ($userRole !== 'dosen' && $userRole !== 'kaprodi') {
            return response()->json(['success' => false, 'message' => 'Akses ditolak! Hanya Dosen dan Kaprodi yang diizinkan.'], 403);
        }

        if ($userRole !== $jalurMasuk) {
            return response()->json([
                'success' => false, 
                'message' => "Nyasar Bos! Anda login sebagai $userRole, dilarang mengakses jalur $jalurMasuk."
            ], 403);
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

    // UPDATE
    public function update(Request $request, $id)
    {
        $userRole = $request->user()->role;
        $jalurMasuk = $request->segment(2);

        if ($userRole !== 'dosen' && $userRole !== 'kaprodi') {
            return response()->json([
                'success' => false, 
                'message' => 'Akses ditolak! Hanya Dosen dan Kaprodi yang diizinkan.'
            ], 403);
        }

        if ($userRole !== $jalurMasuk) {
            return response()->json([
                'success' => false, 
                'message' => "Nyasar Bos! Anda login sebagai $userRole, dilarang mengakses jalur $jalurMasuk."
            ], 403);
        }

        $assignment = Assignment::find($id);

        if (!$assignment) {
            return response()->json(['success' => false, 'message' => 'Data assignment tidak ditemukan!'], 404);
        }

        if ($assignment->dosen_id !== $request->user()->id) {
            return response()->json([
                'success' => false, 
                'message' => 'Anda tidak berhak mengedit assignment milik orang lain!'
            ], 403);
        }

        $request->validate([
            'judul'           => 'sometimes|required|string',
            'deskripsi'       => 'sometimes|required|string',
            'jam_kompen'      => 'sometimes|required|integer',
            'tanggal_mulai'   => 'sometimes|required|date',
            'tanggal_selesai' => 'sometimes|required|date',
            'status'          => 'sometimes|required|string', 
        ]);

        try {
            $assignment->update($request->all());

            return response()->json([
                'success' => true,
                'message' => 'Assignment berhasil diperbarui!',
                'data'    => $assignment 
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengupdate assignment: ' . $e->getMessage()
            ], 500);
        }
    }

    // DELETE
    public function destroy(Request $request, $id)
    {
        $userRole = $request->user()->role;
        $jalurMasuk = $request->segment(2);

        if ($userRole !== 'dosen' && $userRole !== 'kaprodi') {
            return response()->json(['success' => false, 'message' => 'Akses ditolak! Hanya Dosen dan Kaprodi yang diizinkan.'], 403);
        }

        if ($userRole !== $jalurMasuk) {
            return response()->json([
                'success' => false, 
                'message' => "Nyasar Bos! Anda login sebagai $userRole, dilarang mengakses jalur $jalurMasuk."
            ], 403);
        }

        $assignment = Assignment::find($id);

        if (!$assignment) {
            return response()->json(['success' => false, 'message' => 'Data assignment tidak ditemukan!'], 404);
        }

        if ($assignment->dosen_id !== $request->user()->id) {
            return response()->json([
                'success' => false, 
                'message' => 'Anda tidak berhak menghapus assignment milik orang lain!'
            ], 403);
        }

        try {
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

    // ==========================================
    // GET ALL
    // ==========================================
    public function index(Request $request)
    {
        $userRole = $request->user()->role;
        $jalurMasuk = $request->segment(2);

        if ($userRole !== 'dosen' && $userRole !== 'kaprodi') {
            return response()->json(['success' => false, 'message' => 'Akses ditolak! Hanya Dosen dan Kaprodi yang diizinkan.'], 403);
        }

        if ($userRole !== $jalurMasuk) {
            return response()->json([
                'success' => false, 
                'message' => "Nyasar Bos! Anda login sebagai $userRole, dilarang mengakses jalur $jalurMasuk."
            ], 403);
        }

        try {
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

    // ==========================================
    // GET DETAIL
    // ==========================================
    public function show(Request $request, $id)
    {
        $userRole = $request->user()->role;
        $jalurMasuk = $request->segment(2);

        if ($userRole !== 'dosen' && $userRole !== 'kaprodi') {
            return response()->json(['success' => false, 'message' => 'Akses ditolak! Hanya Dosen dan Kaprodi yang diizinkan.'], 403);
        }

        if ($userRole !== $jalurMasuk) {
            return response()->json([
                'success' => false, 
                'message' => "Nyasar Bos! Anda login sebagai $userRole, dilarang mengakses jalur $jalurMasuk."
            ], 403);
        }

        $assignment = Assignment::find($id);

        if (!$assignment) {
            return response()->json(['success' => false, 'message' => 'Data tidak ditemukan!'], 404);
        }

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