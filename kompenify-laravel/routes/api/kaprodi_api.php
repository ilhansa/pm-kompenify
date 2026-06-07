<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AssignmentController;
use App\Http\Controllers\Api\PengajuanKompenController;

Route::prefix('kaprodi')->group(function () {

    // 1. Kaprodi membuat assignment baru
    Route::post('/assignments', [AssignmentController::class, 'store']);

    // 2. Kaprodi melihat list assignment buatan mereka
    Route::get('/assignments', [AssignmentController::class, 'index']);

    // 3. Kaprodi melihat detail satu assignment
    Route::get('/assignments/{id}', [AssignmentController::class, 'show']);

    // 4. Kaprodi mengedit assignment
    Route::put('/assignments/{id}', [AssignmentController::class, 'update']);

    // 5. Kaprodi menghapus assignment
    Route::delete('/assignments/{id}', [AssignmentController::class, 'destroy']);

    // 6. Ambil antrean tugas kompen rilisannya Kaprodi yang butuh dicek statusnya
    Route::get('/pengajuan-kompen/menunggu-verifikasi', [PengajuanKompenController::class, 'indexMenungguVerifikasi']);

    // 7. Aksi Mengubah Status (Kaprodi milih mhs pas war slot ATAU ACC hasil kerjaan tugas buatannya sendiri)l
    Route::post('/pengajuan-kompen/{id}/status', [PengajuanKompenController::class, 'updateStatus']);

    // 8. Eksekusi pengesahan final kompen untuk menerbitkan QR Token Kaprodi (Mengubah status final ke 'diterima')
    Route::post('/pengajuan-kompen/{id}/ttd', [PengajuanKompenController::class, 'berikanTandaTangan']);
});
