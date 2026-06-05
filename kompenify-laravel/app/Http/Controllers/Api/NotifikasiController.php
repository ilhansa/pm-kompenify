<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Notifikasi; // 👈 Panggil Modelnya di sini biar rapi

class NotifikasiController extends Controller
{
    // GET: LIHAT DAFTAR NOTIFIKASI USER
    public function getNotifikasi(Request $request)
    {
        $user = $request->user();

        try {
            // Ambil notifikasi milik user yang sedang login, urutkan dari yang terbaru
            $notifikasis = Notifikasi::where('user_id', $user->id)
                                     ->orderBy('created_at', 'desc')
                                     ->get();

            // Hitung ada berapa pesan yang belum dibaca (Buat nampilin angka merah di ikon Lonceng)
            $unreadCount = Notifikasi::where('user_id', $user->id)
                                     ->where('is_read', false)
                                     ->count();

            return response()->json([
                'success' => true,
                'message' => 'Berhasil mengambil notifikasi',
                'unread_count' => $unreadCount,
                'data'    => $notifikasis
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil notifikasi: ' . $e->getMessage()
            ], 500);
        }
    }

    // PUT: TANDAI NOTIFIKASI SUDAH DIBACA
    public function markAsRead(Request $request, $id)
    {
        $user = $request->user();

        try {
            // Cari notifikasi berdasarkan ID dan pastikan itu milik user yang sedang login
            $notifikasi = Notifikasi::where('id', $id)
                                    ->where('user_id', $user->id)
                                    ->first();

            if (!$notifikasi) {
                return response()->json(['success' => false, 'message' => 'Notifikasi tidak ditemukan'], 404);
            }

            // Ubah status jadi sudah dibaca
            $notifikasi->update(['is_read' => true]);

            return response()->json([
                'success' => true,
                'message' => 'Notifikasi telah dibaca'
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengupdate notifikasi: ' . $e->getMessage()
            ], 500);
        }
    }

    // PUT: TANDAI SEMUA NOTIFIKASI SUDAH DIBACA (read all)
    public function markAllAsRead(Request $request)
    {
        $user = $request->user();

        try {
            // Langsung update semua notifikasi milik user ini yang masih false menjadi true
            Notifikasi::where('user_id', $user->id)
                      ->where('is_read', false)
                      ->update(['is_read' => true]);

            return response()->json([
                'success' => true,
                'message' => 'Semua notifikasi telah dibaca'
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengupdate notifikasi: ' . $e->getMessage()
            ], 500);
        }
    }
}