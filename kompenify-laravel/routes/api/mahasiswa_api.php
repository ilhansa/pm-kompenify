<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\PengajuanKompenController;
use App\Http\Controllers\Api\AssignmentController;

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

});