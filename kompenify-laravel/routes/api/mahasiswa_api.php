<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\PengajuanKompenController;

/*
|--------------------------------------------------------------------------
| MAHASISWA API
| Semua sudah otomatis auth:sanctum dari api.php
|--------------------------------------------------------------------------
*/

// 🔥 Mahasiswa mengajukan kompen
Route::post('/pengajuan-kompen', [PengajuanKompenController::class, 'store']);