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

    // FUNGSI 1: MURNI WORKFLOW STATUS VERIFIKASI (DOSEN)
    public function updateStatus(Request $request, $id)
    {
        $user = $request->user();
        $userRole = $user->role;
        $jalurMasuk = $request->segment(2); // Memastikan rute /api/dosen/

        if ($userRole !== 'dosen' || $jalurMasuk !== 'dosen') {
            return response()->json(['success' => false, 'message' => 'Akses khusus Dosen!'], 403);
        }

        $request->validate([
            'status' => 'required|in:diterima,ditolak' // Kembali ke khittah: hanya terima/tolak
        ]);

        $pengajuan = PengajuanKompen::with(['assignment', 'mahasiswa'])->find($id);

        if (!$pengajuan) {
            return response()->json(['success' => false, 'message' => 'Data tidak ditemukan!'], 404);
        }

        if ($pengajuan->assignment->dosen_id !== $user->id) {
            return response()->json(['success' => false, 'message' => 'Akses ditolak! Bukan tugas Anda.'], 403);
        }

        try {
            // ─── 🛠️ FASE A: DOSEN PILIH MAHASISWA PAS WAR (pending -> sedang dikerjakan) ───
            if ($request->status === 'diterima' && $pengajuan->status === 'pending') {

                $pengajuan->update(['status' => 'sedang dikerjakan']);

                // Auto-reject mahasiswa lain yang ikut rebutan slot war
                $pengajuanLain = PengajuanKompen::where('assignment_id', $pengajuan->assignment_id)
                    ->where('id', '!=', $pengajuan->id)
                    ->where('status', 'pending')
                    ->get();

                foreach ($pengajuanLain as $pLain) {
                    $pLain->update(['status' => 'ditolak']);
                }

                // Update status tugas utama di tabel assignments
                $pengajuan->assignment->update(['status' => 'sedang dikerjakan']);

                return response()->json(['success' => true, 'message' => 'Mahasiswa resmi mulai bekerja!']);
            }

            // ─── 🛠️ FASE B: DOSEN ACC HASIL KERJAAN (menunggu_ttd_dosen -> menunggu_ttd_kaprodi) ───
            if ($request->status === 'diterima' && $pengajuan->status === 'menunggu_ttd_dosen') {

                // Murni oper status ke meja Kaprodi, BELUM mengisi token E-TTD Dosen!
                $pengajuan->update(['status' => 'menunggu_ttd_kaprodi']);

                return response()->json(['success' => true, 'message' => 'Hasil kerja VALID, berkas dikirim ke antrean TTD!']);
            }

            // ─── 🛠️ FASE C: DOSEN TOLAK HASIL KERJAAN (menunggu_ttd_dosen -> sedang dikerjakan) ───
            if ($request->status === 'ditolak' && $pengajuan->status === 'menunggu_ttd_dosen') {

                // Kembalikan ke 'sedang dikerjakan' agar mahasiswa bisa revisi dan upload ulang bukti
                $pengajuan->update(['status' => 'sedang dikerjakan']);

                return response()->json(['success' => true, 'message' => 'Hasil kerja ditolak, mahasiswa diminta revisi.']);
            }

            return response()->json(['success' => false, 'message' => 'Transisi status tidak valid dengan fase saat ini!'], 400);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    // FUNGSI 2: KHUSUS PENERBITAN KODE QR E-TTD DIGITAL (DOSEN & KAPRODI)
    public function berikanTandaTangan(Request $request, $id)
    {
        $user = $request->user();
        $userRole = $user->role;

        $pengajuan = PengajuanKompen::find($id);

        if (!$pengajuan) {
            return response()->json(['success' => false, 'message' => 'Data pengajuan tidak ditemukan!'], 404);
        }

        if ($pengajuan->status !== 'menunggu_ttd_kaprodi') {
            return response()->json(['success' => false, 'message' => 'Berkas belum masuk fase penandatanganan sah!'], 400);
        }

        try {
            // 1. JALUR BUBURKAN TTD DOSEN
            if ($userRole === 'dosen') {
                if ($pengajuan->assignment->dosen_id !== $user->id) {
                    return response()->json(['success' => false, 'message' => 'Akses ditolak! Bukan tugas Anda.'], 403);
                }

                if (!is_null($pengajuan->qr_token_dosen)) {
                    return response()->json(['success' => false, 'message' => 'Anda sudah menandatangani dokumen ini!'], 400);
                }

                // Sematkan token unik berstempel waktu untuk Dosen
                $pengajuan->update([
                    'qr_token_dosen' => 'E-KOMPEN-DSN-' . strtoupper(Str::random(10)) . '-' . time()
                ]);

                return response()->json(['success' => true, 'message' => '✓ Sukses menyematkan E-TTD Dosen!']);
            }

            // 2. JALUR SAHKAN TTD KAPRODI (FINALISASI)
            if ($userRole === 'kaprodi') {
                if (is_null($pengajuan->qr_token_dosen)) {
                    return response()->json(['success' => false, 'message' => 'Gagal! Dosen yang bersangkutan belum menandatangani berkas ini.'], 400);
                }

                if (!is_null($pengajuan->qr_token_kaprodi)) {
                    return response()->json(['success' => false, 'message' => 'Kaprodi sudah menyetujui dokumen ini!'], 400);
                }

                // Kaprodi ttd, otomatis status enum berubah jadi 'diterima' (Lunas Mutlak!)
                $pengajuan->update([
                    'status' => 'diterima',
                    'qr_token_kaprodi' => 'E-KOMPEN-KPR-' . strtoupper(Str::random(10)) . '-' . time()
                ]);

                return response()->json(['success' => true, 'message' => '✓ Kompen resmi SAH & LUNAS TOTAL di tingkat program studi!']);
            }

            return response()->json(['success' => false, 'message' => 'Role Anda tidak memiliki otoritas E-TTD!'], 403);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
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
                'status' => 'menunggu_ttd_dosen'
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

    // ==========================================
    // GET: DAFTAR TUGAS MENUNGGU VERIFIKASI (DOSEN & KAPRODI)
    // ==========================================
    public function indexMenungguVerifikasi(Request $request)
    {
        $user = $request->user();
        $query = PengajuanKompen::with(['assignment', 'bukti', 'mahasiswa']);

        if ($user->role === 'dosen') {
            // Dosen biasa: Cuma lihat tugas bikinannya sendiri yang butuh diproses
            $query->whereIn('status', ['pending', 'menunggu_ttd_dosen'])
                ->whereHas('assignment', function ($q) use ($user) {
                    $q->where('dosen_id', $user->id);
                });
        } else if ($user->role === 'kaprodi') {
            // Kaprodi: Punya "Mata Dewa" (Bisa lihat 2 jenis antrean sekaligus)
            $query->where(function ($q) use ($user) {
                // Antrean 1: Tugas yang Kaprodi bikin sendiri (Bertindak sbg Dosen)
                $q->whereIn('status', ['pending', 'menunggu_ttd_dosen'])
                    ->whereHas('assignment', function ($q2) use ($user) {
                        $q2->where('dosen_id', $user->id);
                    });
            })->orWhere(function ($q) {
                // Antrean 2: Semua tugas se-kampus yang nunggu TTD Final (Bertindak sbg Bos Besar)
                $q->where('status', 'menunggu_ttd_kaprodi');
            });
        } else {
            return response()->json(['success' => false, 'message' => 'Akses ditolak!'], 403);
        }

        return response()->json(['success' => true, 'data' => $query->orderBy('updated_at', 'desc')->get()], 200);
    }

    // PUT: VERIFIKASI TUGAS
    public function verifikasi(Request $request, $id)
    {
        $user = $request->user();

        if (!in_array($user->role, ['dosen', 'kaprodi'])) {
            return response()->json(['success' => false, 'message' => 'Akses ditolak!'], 403);
        }

        $pengajuan = PengajuanKompen::with('assignment')->find($id);
        if (!$pengajuan) {
            return response()->json(['success' => false, 'message' => 'Data pengajuan tidak ditemukan!'], 404);
        }

        $request->validate([
            'status' => 'required|in:diterima,ditolak',
        ]);

        try {
            $updateData = [];
            $pesan = '';

            // ─── FASE 1: PERANG SLOT PELAMAR (pending -> sedang dikerjakan) ───
            if ($pengajuan->status === 'pending') {
                if ($pengajuan->assignment->dosen_id !== $user->id) {
                    return response()->json(['success' => false, 'message' => 'Bukan tugas kompen Anda!'], 403);
                }

                if ($request->status === 'diterima') {
                    $updateData['status'] = 'sedang dikerjakan';
                    $pesan = 'Mahasiswa resmi mulai bekerja!';

                    // Auto-reject pelamar lain
                    PengajuanKompen::where('assignment_id', $pengajuan->assignment_id)
                        ->where('id', '!=', $pengajuan->id)
                        ->where('status', 'pending')
                        ->update(['status' => 'ditolak']);

                    $pengajuan->assignment->update(['status' => 'sedang dikerjakan']);
                } else {
                    $updateData['status'] = 'ditolak';
                    $pesan = 'Lamaran mahasiswa ditolak.';
                }
            }

            // ─── FASE 2: VERIFIKASI PEMBUAT TUGAS (menunggu_ttd_dosen -> menunggu_ttd_kaprodi) ───
            else if ($pengajuan->status === 'menunggu_ttd_dosen') {
                if ($pengajuan->assignment->dosen_id !== $user->id) {
                    return response()->json(['success' => false, 'message' => 'Bukan tugas kompen Anda!'], 403);
                }

                if ($request->status === 'diterima') {
                    $updateData['status'] = 'menunggu_ttd_kaprodi';
                    // 🚀 Di sini Token TTD Digital Dosen langsung disematkan ke kolom database!
                    $updateData['qr_token_dosen'] = 'E-KOMPEN-DSN-' . strtoupper(Str::random(10)) . '-' . time();
                    $pesan = 'Hasil kerja VALID, E-TTD Dosen berhasil disematkan! Berkas dikirim ke antrean Kaprodi.';
                } else {
                    $updateData['status'] = 'sedang dikerjakan';
                    $pesan = 'Hasil kerja ditolak, mahasiswa diminta revisi.';
                }
            }

            // ─── FASE 3: TTD FINAL KAPRODI (menunggu_ttd_kaprodi -> diterima) ───
            else if ($pengajuan->status === 'menunggu_ttd_kaprodi') {
                if ($user->role !== 'kaprodi') {
                    return response()->json(['success' => false, 'message' => 'Hanya Kaprodi!'], 403);
                }

                if ($request->status === 'diterima') {
                    // Load relasi mahasiswa jika belum di-load
                    if (!$pengajuan->mahasiswa) {
                        $pengajuan->load('mahasiswa');
                    }

                    $mahasiswa = $pengajuan->mahasiswa;

                    if ($mahasiswa) {
                        // Log nilai sebelum dikurangi untuk memastikan (cek di storage/logs/laravel.log)
                        $jumlahJam = $pengajuan->assignment->jam_kompen;

                        \Illuminate\Support\Facades\Log::info("DEBUG: Mahasiswa ID {$mahasiswa->id} | Sisa Jam Awal: {$mahasiswa->sisa_jam_kompen} | Jam yang akan dikurangi: {$jumlahJam}");

                        // Kurangi jamnya
                        $mahasiswa->sisa_jam_kompen -= $jumlahJam;
                        $mahasiswa->save();
                    } else {
                        return response()->json(['success' => false, 'message' => 'Data mahasiswa tidak ditemukan!'], 404);
                    }

                    $updateData['status'] = 'diterima';
                    $updateData['qr_token_kaprodi'] = 'E-KOMPEN-KPR-' . strtoupper(Str::random(10)) . '-' . time();
                    $pesan = '✓ Kompen SAH & LUNAS TOTAL! Jam kompen berhasil dikurangi.';
                } else {
                    $updateData['status'] = 'sedang dikerjakan';
                    $pesan = 'Ditolak oleh Kaprodi, mahasiswa diminta revisi.';
                }
            }

            // ─── EKSEKUSI UPDATE SATU PINTU ───
            $pengajuan->update($updateData);

            return response()->json([
                'success' => true,
                'message' => $pesan,
                'data'    => $pengajuan
            ], 200);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Gagal memverifikasi: ' . $e->getMessage()], 500);
        }
    }

// ==========================================
    // GET: CETAK PDF + DETEKTIF LOG EROR SAKTI
    // ==========================================
    public function cetakSurat(Request $request, $id)
    {
        // 🚀 LOG 1: Deteksi apakah request dari Flutter Sultan beneran masuk ke fungsi ini
        \Illuminate\Support\Facades\Log::info("=== DETEKTIF PDF: ADA TEMBAKAN MASUK ===");
        \Illuminate\Support\Facades\Log::info("ID Pengajuan yang dicari: " . $id);
        
        try {
            // 1. Tarik data dari database
            $pengajuan = PengajuanKompen::with(['mahasiswa.user', 'assignment'])->find($id);

            // 🚀 LOG 2: Cek apakah datanya ketemu di database Laragon
            if (!$pengajuan) {
                \Illuminate\Support\Facades\Log::error("❌ DETEKTIF PDF: ID Pengajuan {$id} TIDAK KETEMU di database!");
                return response()->json(['success' => false, 'message' => 'Data pengajuan tidak ditemukan!'], 404);
            }

            \Illuminate\Support\Facades\Log::info("✅ DETEKTIF PDF: Data ketemu! Status saat ini: " . $pengajuan->status);

            // 2. Kunci Validasi Status
            if ($pengajuan->status !== 'diterima') {
                \Illuminate\Support\Facades\Log::warning("⚠️ DETEKTIF PDF: Gagal cetak karena status belum 'diterima'!");
                return response()->json([
                    'success' => false,
                    'message' => 'Gagal cetak! Surat belum disahkan atau masih dalam proses.'
                ], 400);
            }

            // 3. Proses Render URL QR Code
            $urlValidasiDosen = url('/api/validasi-dokumen/' . $pengajuan->qr_token_dosen);
            $urlValidasiKaprodi = url('/api/validasi-dokumen/' . $pengajuan->qr_token_kaprodi);

            // 4. Proses Kompilasi DomPDF
            \Illuminate\Support\Facades\Log::info("⏳ DETEKTIF PDF: Mulai merender file HTML Blade ke DomPDF...");
            
            $pdf = \Barryvdh\DomPDF\Facade\Pdf::loadView('pdf.surat_kompen', compact('pengajuan', 'urlValidasiDosen', 'urlValidasiKaprodi'));
            $pdf->setPaper('a4', 'portrait');

            $namaMhs = isset($pengajuan->mahasiswa->user->nama) ? str_replace(' ', '_', $pengajuan->mahasiswa->user->nama) : 'mahasiswa';
            $namaFile = 'Surat_Bebas_Kompen_' . $namaMhs . '.pdf';

            \Illuminate\Support\Facades\Log::info("🎉 DETEKTIF PDF: RENDER SUKSES! Mengirim file {$namaFile} ke Flutter...");

            return $pdf->download($namaFile);

        } catch (\Exception $e) {
            // 🚀 LOG 3: JIKA CRASH, TULIS PENYEBAB ASLINYA DI SINI JINK!
            \Illuminate\Support\Facades\Log::error("💥 DETEKTIF PDF CRASH SECARA INTERNAL! Alasan: " . $e->getMessage());
            \Illuminate\Support\Facades\Log::error("Line Eror: " . $e->getLine() . " di file " . $e->getFile());
            
            return response()->json(['success' => false, 'message' => 'Gagal mencetak PDF: ' . $e->getMessage()], 500);
        }
    }

    // BUAT AI ANJING INI NAMANYA INDEX BUAT LIAT ASSIGNMENT YG UDAH MAHASISWA SELESAIIN
    public function indexRiwayatSelesai(Request $request)
{
    $user = $request->user();

    // 1. Ambil data mahasiswa
    $mahasiswa = Mahasiswa::where('user_id', $user->id)->first();
    
    // 2. Ambil pengajuan yang sudah 'diterima'
    // Menggunakan relasi 'assignment' biar mahasiswa tahu dia selesai tugas apa saja
    $riwayat = PengajuanKompen::where('mahasiswa_id', $mahasiswa->id)
        ->where('status', 'diterima') // Filter cuma yang sudah LUNAS
        ->with(['assignment']) 
        ->orderBy('updated_at', 'desc')
        ->get();

    return response()->json([
        'success' => true,
        'message' => 'Daftar tugas yang sudah diselesaikan',
        'data' => $riwayat
    ], 200);
}


}
