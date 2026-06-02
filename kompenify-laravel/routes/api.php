<?php

use App\Http\Controllers\Api\AuthController;
use Illuminate\Support\Facades\Route;

// Route untuk memproses Login form React
Route::post('/login', [AuthController::class, 'login']);

// Route untuk Menampilkan Daftar User di Tabel Dashboard
Route::get('/admin/users', function() {
    return response()->json([
        'success' => true,
        'data' => \App\Models\User::orderBy('created_at', 'desc')->get()
    ], 200);
});

// Route Aksi Kelola Akun (Tambah, Edit, Hapus)
Route::post('/admin/users', [AuthController::class, 'registerAkun']);
Route::put('/admin/users/{id}', [AuthController::class, 'editAkun']);
Route::delete('/admin/users/{id}', [AuthController::class, 'hapusAkun']);
