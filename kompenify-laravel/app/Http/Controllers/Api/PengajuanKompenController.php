<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\PengajuanKompen;
use App\Models\Mahasiswa;
use App\Models\Notifikasi;
use Illuminate\Support\Str;

class PengajuanKompenController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'assignment_id' => 'required|uuid',
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
                                            ->exists();

        if ($sudahPernahDaftar) {
            return response()->json([
                'success' => false,
                'message' => 'Anda sudah mengajukan kompen untuk tugas ini! Menunggu persetujuan Dosen.'
            ], 409);
        }

        try {
            // 4. SIMPAN KE DATABASE JIKA LOLOS
            $pengajuan = PengajuanKompen::create([
                'id' => Str::uuid()->toString(),
                'mahasiswa_id' => $mahasiswa->id, 
                'assignment_id' => $request->assignment_id,
                'status' => 'pending',
            ]);

            // 5. KIRIM NOTIFIKASI KE DOSEN PEMILIK TUGAS
            $assignment = \App\Models\Assignment::find($request->assignment_id);
            
            if ($assignment) {
                \App\Models\Notifikasi::create([
                    'id'      => Str::uuid()->toString(),
                    'user_id' => $assignment->dosen_id, // Dikirim ke akun user si dosen
                    'judul'   => 'Ada Pelamar Baru!',
                    'pesan'   => "Mahasiswa dengan NIM {$mahasiswa->nim} baru saja melamar untuk tugas '{$assignment->judul}'. Segera cek daftar pelamar!",
                ]);
            }

            return response()->json([
                'success' => true,
                'message' => 'Pengajuan kompen berhasil dikirim',
                'data' => $pengajuan
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal membuat pengajuan: ' . $e->getMessage()
            ], 500);
        }
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
            // 3. Ambil semua pengajuan milik mahasiswa ini beserta tugas dan buktinya
            $riwayatPengajuan = PengajuanKompen::where('mahasiswa_id', $mahasiswa->id)
                                               ->with(['assignment', 'bukti'])
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
        $pengajuan = PengajuanKompen::with('bukti')->find($id);

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

            // 3. CARI PENGAJUAN YANG MASUK KE TUGAS-TUGAS TERSEBUT (KHUSUS PENDING)
            $pengajuans = PengajuanKompen::whereIn('assignment_id', $assignmentIds)
                                         ->where('status', 'pending')
                                         ->with(['mahasiswa', 'assignment'])
                                         ->orderBy('created_at', 'desc')
                                         ->get();

            return response()->json([
                'success' => true,
                'message' => 'Berhasil mengambil daftar pelamar baru',
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
                                      ->with(['mahasiswa', 'bukti'])
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
        $jalurMasuk = $request->segment(2); 

        if ($userRole !== 'dosen' && $userRole !== 'kaprodi') {
            return response()->json(['success' => false, 'message' => 'Akses ditolak!'], 403);
        }

        if ($userRole !== $jalurMasuk) {
            return response()->json(['success' => false, 'message' => "Nyasar Bos!"], 403);
        }

        $request->validate([
            'status' => 'required|in:diterima,ditolak'
        ]);

        // Bawa relasi assignment DAN mahasiswa sekaligus biar gampang ambil user_id
        $pengajuan = PengajuanKompen::with(['assignment', 'mahasiswa'])->find($id);

        if (!$pengajuan) {
            return response()->json(['success' => false, 'message' => 'Data pengajuan tidak ditemukan!'], 404);
        }

        if ($pengajuan->assignment->dosen_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Akses ditolak! Bukan tugas Anda.'], 403);
        }

        if ($pengajuan->status !== 'pending') {
            return response()->json(['success' => false, 'message' => "Pengajuan sudah diproses."], 400);
        }

        try {
            // 1. Eksekusi ubah status
            $pengajuan->update([
                'status' => $request->status
            ]);

            // 2. KIRIM NOTIFIKASI KE MAHASISWA YANG DIPROSES
            Notifikasi::create([
                'id'      => Str::uuid()->toString(),
                'user_id' => $pengajuan->mahasiswa->user_id,
                'judul'   => $request->status === 'diterima' ? '🎉 Pengajuan Diterima!' : '❌ Pengajuan Ditolak',
                'pesan'   => "Pengajuan kompen Anda untuk tugas '{$pengajuan->assignment->judul}' telah " . $request->status . ".",
            ]);

            // 3. AUTO-REJECT & NOTIF PATAH HATI BUAT MAHASISWA LAIN
            if ($request->status === 'diterima') {
                // Cari mahasiswa lain yang berstatus pending
                $pengajuanLain = PengajuanKompen::where('assignment_id', $pengajuan->assignment_id)
                               ->where('id', '!=', $pengajuan->id)
                               ->where('status', 'pending')
                               ->with('mahasiswa')
                               ->get();
                
                foreach ($pengajuanLain as $pLain) {
                    $pLain->update(['status' => 'ditolak']);

                    // Kirim notifikasi ke mereka
                    Notifikasi::create([
                        'id'      => Str::uuid()->toString(),
                        'user_id' => $pLain->mahasiswa->user_id,
                        'judul'   => 'Maaf, Kuota Tugas Penuh',
                        'pesan'   => "Tugas '{$pengajuan->assignment->judul}' sudah ditugaskan ke mahasiswa lain. Yuk cari tugas lain!",
                    ]);
                }
                
                $pengajuan->assignment->update([
                    'status' => 'sedang dikerjakan' 
                ]);
            }

            return response()->json([
                'success' => true,
                'message' => 'Status pengajuan berhasil diubah menjadi ' . $request->status,
                'data'    => $pengajuan
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal memproses: ' . $e->getMessage()
            ], 500);
        }
    }
    
    // PUT: TANDAI TUGAS SELESAI OLEH MAHASISWA
    public function tandaiSelesai(Request $request, $id)
    {
        $user = $request->user();

        if ($user->role !== 'mhs') {
            return response()->json(['success' => false, 'message' => 'Akses ditolak!'], 403);
        }

        // 1. Cari data pengajuannya
        $pengajuan = PengajuanKompen::find($id);

        if (!$pengajuan) {
            return response()->json(['success' => false, 'message' => 'Data tidak ditemukan!'], 404);
        }

        // 2. Satpam Keamanan: Cek apakah ini benar-benar tugas miliknya
        $mahasiswa = \App\Models\Mahasiswa::where('user_id', $user->id)->first();
        if ($pengajuan->mahasiswa_id !== $mahasiswa->id) {
             return response()->json(['success' => false, 'message' => 'Bukan tugasmu, Bos!'], 403);
        }

        // 3. Update statusnya
        // Catatan: Pastikan teks status ini sesuai dengan yang kamu izinkan di database (enum)
        // Biasanya kalau mahasiswa yang submit, statusnya berubah jadi 'menunggu_verifikasi' atau 'selesai'
        try {
            $pengajuan->update([
                'status' => 'menunggu_verifikasi'
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Tugas berhasil disubmit! Menunggu penilaian dari Dosen.',
                'data' => $pengajuan
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengubah status: ' . $e->getMessage()
            ], 500);
        }
    }
}