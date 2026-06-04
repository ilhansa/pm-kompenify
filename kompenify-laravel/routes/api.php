<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;

/*
|--------------------------------------------------------------------------
| API Routes Utama - E-Kompenify
|--------------------------------------------------------------------------
*/

// 1. GERBANG PUBLIK (Bisa diakses tanpa login / tanpa token)
Route::post('/login', [AuthController::class, 'login']);


// 2. GERBANG PRIVAT (Wajib Lolos Autentikasi & Bawa Token Sanctum)
Route::middleware('auth:sanctum')->group(function () {

    // FITUR PROFIL GLOBAL: Wajib ada untuk satpam pengingat sesi di React & Flutter!
    Route::get('/profile', [AuthController::class, 'getProfile']);

    // Fitur Logout Global
    Route::post('/logout', [AuthController::class, 'logout']);

    // OTOMATIS MEMANGGIL SEMUA FILE API YANG KAMU BUAT TADI
    require __DIR__ . '/api/admin_api.php';
    require __DIR__ . '/api/mahasiswa_api.php';
    require __DIR__ . '/api/dosen_api.php';
    require __DIR__ . '/api/kaprodi_api.php';

});
