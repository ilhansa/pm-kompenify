<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\PengajuanKompen;
use App\Models\BuktiKompen;
use Illuminate\Support\Str;

class BuktiKompenController extends Controller
{
    // ==========================================
    // POST: UPLOAD BANYAK BUKTI FOTO SEKALIGUS
    // ==========================================
    public function uploadBukti(Request $request, $id)
    {
        $user = $request->user();

        if ($user->role !== 'mhs') {
            return response()->json(['success' => false, 'message' => 'Akses ditolak!'], 403);
        }

        $pengajuan = PengajuanKompen::find($id);

        if (!$pengajuan) {
            return response()->json(['success' => false, 'message' => 'Data tidak ditemukan!'], 404);
        }

        // Satpam Status Pengajuan
        if ($pengajuan->status === 'selesai' || $pengajuan->status === 'ditolak') {
            return response()->json([
                'success' => false, 
                'message' => 'Telat Bos! Tugas ini sudah selesai atau ditolak, tidak bisa upload bukti lagi.'
            ], 403);
        }

        // Validasi Batas Maksimal File (Max 5 Foto & Max 5MB per foto)
        $request->validate([
            'bukti_foto'   => 'required|array|max:5', 
            'bukti_foto.*' => 'image|mimes:jpeg,png,jpg|max:5120' 
        ], [
            'bukti_foto.max' => 'Bos, maksimal upload cuma 5 foto ya!'
        ]);

        try {
            $uploadedData = [];

            foreach ($request->file('bukti_foto') as $file) {
                $tipe_file = $file->getClientMimeType();
                $nama_file = time() . '_' . Str::random(5) . '_' . $file->getClientOriginalName();
                
                $path = $file->storeAs('bukti_kompen', $nama_file, 'public');

                $bukti = BuktiKompen::create([
                    'id'           => Str::uuid()->toString(),
                    'pengajuan_id' => $pengajuan->id,
                    'file_path'    => $path,
                    'tipe_file'    => $tipe_file
                ]);

                $uploadedData[] = [
                    'id'       => $bukti->id,
                    'foto_url' => asset('storage/' . $path)
                ];
            }

            return response()->json([
                'success' => true,
                'message' => 'Berhasil mengupload ' . count($uploadedData) . ' foto bukti!',
                'data'    => $uploadedData
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengupload bukti: ' . $e->getMessage()
            ], 500);
        }
    }

    // ==========================================
    // DELETE: HAPUS 1 FOTO BUKTI SPESIFIK
    // ==========================================
    public function destroyBukti(Request $request, $id)
    {
        $user = $request->user();

        if ($user->role !== 'mhs') {
            return response()->json(['success' => false, 'message' => 'Akses ditolak!'], 403);
        }

        // 1. Cari data fotonya
        $bukti = BuktiKompen::with('pengajuan')->find($id);

        if (!$bukti) {
            return response()->json(['success' => false, 'message' => 'Foto tidak ditemukan!'], 404);
        }

        $pengajuan = $bukti->pengajuan;

        // 2. Satpam Keamanan: Cari profil mahasiswa dulu, baru bandingkan
        $mahasiswa = \App\Models\Mahasiswa::where('user_id', $user->id)->first();
        
        if (!$mahasiswa) {
            return response()->json(['success' => false, 'message' => 'Profil mahasiswa tidak ditemukan!'], 404);
        }

        if ($pengajuan->mahasiswa_id !== $mahasiswa->id) {
             return response()->json(['success' => false, 'message' => 'Bukan foto milikmu, Bos!'], 403);
        }

        // 3. Satpam Status: Kalau udah selesai/ditolak, foto udah dikunci (nggak boleh dihapus)
        if ($pengajuan->status === 'selesai' || $pengajuan->status === 'ditolak') {
            return response()->json([
                'success' => false, 
                'message' => 'Tugas sudah selesai atau ditolak, foto tidak bisa dihapus lagi.'
            ], 403);
        }

        try {
            // 4. Eksekusi Hapus! 
            // (Catatan: Fitur Auto-Clean di model BuktiKompen otomatis akan menghapus fisik file di folder storage)
            $bukti->delete();

            return response()->json([
                'success' => true,
                'message' => 'Bukti foto berhasil dihapus!'
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal menghapus foto: ' . $e->getMessage()
            ], 500);
        }
    }
}