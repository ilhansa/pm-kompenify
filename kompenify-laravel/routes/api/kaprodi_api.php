<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AssignmentController;
use App\Http\Controllers\Api\PengajuanKompenController;

Route::prefix('kaprodi')->group(function () {

    // Rute CRUD Assignment

    // view
    // get all
    Route::get('/assignments', [AssignmentController::class, 'index']);
    // get details
    Route::get('/assignments/{id}', [AssignmentController::class, 'show']);
    // create
    Route::post('/assignments', [AssignmentController::class, 'store']);
    // update
    Route::put('/assignments/{id}', [AssignmentController::class, 'update']);
    // delete
    Route::delete('/assignments/{id}', [AssignmentController::class, 'destroy']);
    // melihat daftar pengajuan kompen (get all)
    Route::get('/pengajuan-kompen', [PengajuanKompenController::class, 'indexPemberiKompen']);
    // Melihat daftar pengajuan kompen di 1 tugas spesifik (get details)
    Route::get('/assignments/{assignment_id}/pengajuan-kompen', [PengajuanKompenController::class, 'pengajuanKompenByAssignment']);
    // menerima/menolak pengajuan
    Route::put('/pengajuan-kompen/{id}/status', [PengajuanKompenController::class, 'updateStatus']);
    // GET | Lihat daftar tugas yang menunggu ACC/TTD
    Route::get('/pengajuan-kompen/menunggu-verifikasi', [PengajuanKompenController::class, 'indexMenungguVerifikasi']);
    // kasih ttd
    Route::post('/pengajuan-kompen/{id}/ttd', [PengajuanKompenController::class, 'berikanTandaTangan']);
});
