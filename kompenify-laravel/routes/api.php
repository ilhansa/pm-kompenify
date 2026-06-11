<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\NotifikasiController;
use App\Http\Controllers\Api\ValidasiController;


// 1. GERBANG PUBLIK (Bisa diakses tanpa login / tanpa token)
Route::post('/login', [AuthController::class, 'login']);
// GET: URL untuk di-scan oleh kamera HP guna mengecek keaslian token E-TTD
Route::get('/validasi-dokumen/{token}', [ValidasiController::class, 'cekDokumen']);
// Rute Umum untuk Validasi QR Code Scan (Bisa diakses tanpa login)
Route::get('/validasi-dokumen/{token}', [ValidasiController::class, 'validasiDokumen']);

// 2. GERBANG PRIVAT (Wajib Lolos Autentikasi & Bawa Token Sanctum)
Route::middleware('auth:sanctum')->group(function () {

    // FITUR PROFIL GLOBAL: Wajib ada untuk satpam pengingat sesi di React & Flutter!
    Route::get('/profile', [AuthController::class, 'getProfile']);

    // Fitur Logout Global
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::get('/notifikasi', [NotifikasiController::class, 'getNotifikasi']);
    Route::put('/notifikasi/{id}/read', [NotifikasiController::class, 'markAsRead']);
    Route::put('/notifikasi/read-all', [NotifikasiController::class, 'markAllAsRead']);

    // OTOMATIS MEMANGGIL SEMUA FILE API YANG KAMU BUAT TADI
    require __DIR__ . '/api/admin_api.php';
    require __DIR__ . '/api/mahasiswa_api.php';
    require __DIR__ . '/api/dosen_api.php';
    require __DIR__ . '/api/kaprodi_api.php';

});
