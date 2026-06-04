<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\AdminUserController;
use Illuminate\Support\Facades\Route;

// Route untuk Menampilkan Daftar User di Tabel Dashboard
Route::get('/admin/users', [AdminUserController::class, 'lihatDaftarAkun']);

// Route Aksi Kelola Akun (Tambah, Edit, Hapus)
Route::post('/admin/users', [AdminUserController::class, 'registerAkun']);
Route::put('/admin/users/{id}', [AdminUserController::class, 'editAkun']);
Route::delete('/admin/users/{id}', [AdminUserController::class, 'hapusAkun']);
