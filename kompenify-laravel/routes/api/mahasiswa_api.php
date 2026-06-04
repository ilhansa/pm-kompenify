<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\PengajuanKompenController;

// ==========================================
// RUTE KHUSUS MAHASISWA
// URL otomatis diawali dengan: /api/mahasiswa/...
// ==========================================
Route::prefix('mahasiswa')->group(function () {
    
    // Mahasiswa mengajukan kompen
    // Method: POST | URL: http://localhost:8000/api/mahasiswa/pengajuan-kompen
    
    // create
    Route::post('/pengajuan-kompen', [PengajuanKompenController::class, 'store']);

    // get all
    Route::get('/pengajuan-kompen', [PengajuanKompenController::class, 'index']);
    // get detail
    Route::get('/pengajuan-kompen/{id}', [PengajuanKompenController::class, 'show']);
    // delete
    Route::delete('/pengajuan-kompen/{id}', [PengajuanKompenController::class, 'destroy']);

});