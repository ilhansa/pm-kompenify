<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AssignmentController;
use App\Http\Controllers\Api\PengajuanKompenController;

Route::prefix('dosen')->group(function () {
    
    // 1. Dosen membuat assignment baru
    Route::post('/assignments', [AssignmentController::class, 'store']);
    
    // 2. Dosen melihat assignment
    // get all
    Route::get('/assignments', [AssignmentController::class, 'index']);
    // get detail
    Route::get('/assignments/{id}', [AssignmentController::class, 'show']);
    
    // 3. Dosen mengedit assignment
    Route::put('/assignments/{id}', [AssignmentController::class, 'update']);
    
    // 4. Dosen menghapus assignment
    Route::delete('/assignments/{id}', [AssignmentController::class, 'destroy']);

    // 5. melihat daftar pengajuan kompen (get all)
    Route::get('/pengajuan-kompen', [PengajuanKompenController::class, 'indexPemberiKompen']);

    // 6. Melihat daftar pengajuan kompen (get details)
    Route::get('/assignments/{assignment_id}/pengajuan-kompen', [PengajuanKompenController::class, 'pengajuanKompenByAssignment']);

    // 7. menerima/menolak pengajuan
    Route::put('/pengajuan-kompen/{id}/status', [PengajuanKompenController::class, 'updateStatus']);
});