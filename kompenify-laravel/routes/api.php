<?php

use App\Http\Controllers\Api\AuthController;
use Illuminate\Support\Facades\Route;

// Route untuk Login
Route::post('/login', [AuthController::class, 'login']);

// Route Terproteksi (Wajib menyertakan Token Bearer hasil login)
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/profile', [AuthController::class, 'getProfile']);
    Route::post('/logout', [AuthController::class, 'logout']);
});