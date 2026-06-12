<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\PengajuanKompenController;
use App\Http\Controllers\Api\AssignmentController;
use App\Http\Controllers\Api\BuktiKompenController;

// ==========================================
// RUTE KHUSUS MAHASISWA
// URL otomatis diawali dengan: /api/mahasiswa/...
// ==========================================
Route::prefix('mahasiswa')->group(function () {

    // Daftar assignment aktif untuk mahasiswa
    // GET | http://localhost:8000/api/mahasiswa/assignments
    Route::get('/assignments', [AssignmentController::class, 'indexMahasiswa']);

    // Pengajuan kompen
    // POST   | http://localhost:8000/api/mahasiswa/pengajuan-kompen
    Route::post('/pengajuan-kompen', [PengajuanKompenController::class, 'store']);

    // GET    | http://localhost:8000/api/mahasiswa/pengajuan-kompen
    Route::get('/pengajuan-kompen', [PengajuanKompenController::class, 'index']);

    // GET    | http://localhost:8000/api/mahasiswa/pengajuan-kompen/{id}
    Route::get('/pengajuan-kompen/{id}', [PengajuanKompenController::class, 'show']);

    // DELETE | http://localhost:8000/api/mahasiswa/pengajuan-kompen/{id}
    Route::delete('/pengajuan-kompen/{id}', [PengajuanKompenController::class, 'destroy']);

    // POST   | upload foto
    Route::post('/pengajuan-kompen/{id}/upload-bukti', [BuktiKompenController::class, 'uploadBukti']);

    // DELETE | hapus 1 bukti foto spesifik
    Route::delete('/bukti-kompen/{id}', [BuktiKompenController::class, 'destroyBukti']);

    // PUT | Tandai tugas selesai oleh mahasiswa
    Route::put('/pengajuan-kompen/{id}/selesai', [PengajuanKompenController::class, 'tandaiSelesai']);

    // GET | INDEX ASSIGNMENT YG UDAH DISELESAIIN MAHASISWA
    Route::get('/pengajuan-kompen/riwayat-selesai', [PengajuanKompenController::class, 'indexRiwayatSelesai']);

    // GET | TEMPAT BUAT MAHASISWA AMBIL DATA UNTUK DI CETAK SURATNYA
    Route::get('/pengajuan-kompen/{id}/cetak-surat', [PengajuanKompenController::class, 'cetakSurat'])->name('api.cetak-surat');
});
