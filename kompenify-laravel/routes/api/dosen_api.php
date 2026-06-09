<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AssignmentController;
use App\Http\Controllers\Api\PengajuanKompenController;

Route::prefix('dosen')->group(function () {
    // 1. Dosen membuat assignment baru
    Route::post('/assignments', [AssignmentController::class, 'store']);

    // 2. Dosen melihat list assignment buatan mereka
    Route::get('/assignments', [AssignmentController::class, 'index']);

    // 3. Dosen melihat detail satu assignment
    Route::get('/assignments/{id}', [AssignmentController::class, 'show']);

    // 4. Dosen mengedit assignment
    Route::put('/assignments/{id}', [AssignmentController::class, 'update']);

    // 5. Dosen menghapus assignment
    Route::delete('/assignments/{id}', [AssignmentController::class, 'destroy']);

    // 6. Ambil daftar tugas yang butuh di-ACC (Menampilkan status: pending, sedang dikerjakan, menunggu_ttd_dosen)
    Route::get('/pengajuan-kompen/menunggu-verifikasi', [PengajuanKompenController::class, 'indexMenungguVerifikasi']);

    // 7. Menggunakan method POST agar seragam dan aman saat di-request dari Flutter
    Route::post('/pengajuan-kompen/{id}/status', [PengajuanKompenController::class, 'updateStatus']);

    // 8. Eksekusi penerbitan QR Token E-TTD Dosen setelah berkas sah dinyatakan lolos verifikasi kerjaan
    Route::post('/pengajuan-kompen/{id}/ttd', [PengajuanKompenController::class, 'berikanTandaTangan']);

    // GET | Dosen melihat antrean tugas (status 'pending' & 'menunggu_ttd_dosen')
    Route::get('/pengajuan-kompen/menunggu-verifikasi', [PengajuanKompenController::class, 'indexMenungguVerifikasi']);

    // PUT | Eksekusi Verifikasi Dosen (ACC War / ACC Hasil Kerja / Tolak)
    Route::put('/pengajuan-kompen/{id}/verifikasi', [PengajuanKompenController::class, 'verifikasi']);

    // Tambahkan di dalam Route::prefix('dosen')->group(function () { ... });
Route::get('/assignments/{assignment_id}/pengajuan-kompen', [PengajuanKompenController::class, 'pengajuanKompenByAssignment']);

});
