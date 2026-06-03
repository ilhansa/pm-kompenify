<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Assignment;
use Illuminate\Support\Str; // 📝 1. TAMBAHKAN BARIS INI UNTUK MEMANGGIL FUNGSI UUID

class AssignmentController extends Controller
{
    public function store(Request $request)
    {
        $userRole = $request->user()->role;
        if ($userRole !== 'dosen' && $userRole !== 'kaprodi') {
            return response()->json(['success' => false, 'message' => 'Akses ditolak!'], 403);
        }

        // 📝 2. VALIDASI 'id' DIHAPUS, KARENA KITA TIDAK MINTA DARI POSTMAN LAGI
        $request->validate([
            'judul'           => 'required|string',
            'deskripsi'       => 'required|string',
            'jam_kompen'      => 'required|integer',
            'tanggal_mulai'   => 'required|date',
            'tanggal_selesai' => 'required|date', 
        ]);

        try {
            $assignment = Assignment::create([
                // 📝 3. LARAVEL YANG BIKIN UUID-NYA OTOMATIS!
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
}