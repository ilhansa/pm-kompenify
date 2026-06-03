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
            'assignment_id' => 'required|uuid',
        ]);

        $user = $request->user();

        if ($user->role !== 'mhs') {
            return response()->json([
                'message' => 'Hanya mahasiswa yang bisa mengajukan kompen'
            ], 403);
        }

        // Ambil mahasiswa berdasarkan user yang login
        $mahasiswa = Mahasiswa::where('user_id', $user->id)->first();

        if (!$mahasiswa) {
            return response()->json([
                'message' => 'Data mahasiswa tidak ditemukan'
            ], 404);
        }

        $pengajuan = PengajuanKompen::create([
            'id' => Str::uuid()->toString(),
            'mahasiswa_id' => $mahasiswa->id, // ← integer dari tabel mahasiswas
            'assignment_id' => $request->assignment_id,
            'status' => 'pending',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pengajuan kompen berhasil dikirim',
            'data' => $pengajuan
        ], 201);
    }
}