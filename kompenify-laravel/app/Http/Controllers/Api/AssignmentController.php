<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Assignment;

class AssignmentController extends Controller
{
    public function store(Request $request)
    {
        // 1. Validasi data yang masuk
        $request->validate([
            'id'              => 'required|string', 
            'judul'           => 'required|string',
            'deskripsi'       => 'required|string',
            'jam_kompen'      => 'required|integer',
            'tanggal_mulai'   => 'required|date',
            'tanggal_selesai' => 'required|date', 
        ]);

        try {
            // 2. Simpan ke database
            $assignment = Assignment::create([
                'id'              => $request->id, // ID bentuk UUID dari Flutter
                'judul'           => $request->judul,
                'deskripsi'       => $request->deskripsi,
                'jam_kompen'      => $request->jam_kompen,
                'tanggal_mulai'   => $request->tanggal_mulai,
                'tanggal_selesai' => $request->tanggal_selesai,
                'status'          => 'aktif', // Otomatis aktif saat dibuat
                
                // Mengambil ID Dosen otomatis dari token user yang sedang login
                'dosen_id'        => $request->user()->id, 
            ]);

            // 3. Kembalikan respon sukses
            return response()->json([
                'success' => true,
                'message' => 'Assignment berhasil dibuat!',
                'data'    => $assignment
            ], 201);

        } catch (\Exception $e) {
            // Jika gagal, kembalikan pesan error
            return response()->json([
                'success' => false,
                'message' => 'Gagal membuat assignment: ' . $e->getMessage()
            ], 500);
        }
    }
}