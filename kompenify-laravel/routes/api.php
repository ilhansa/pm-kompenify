<?php

use App\Http\Controllers\Api\AuthController;
use Illuminate\Support\Facades\Route;

// Route untuk Login
Route::get('/admin/users', function() {
    return response()->json([
        'success' => true,
        'data' => \App\Models\User::orderBy('created_at', 'desc')->get()
    ], 200);
});
Route::post('/admin/users', [\App\Http\Controllers\Api\AuthController::class, 'registerAkun']);
Route::put('/admin/users/{id}', [AuthController::class, 'editAkun']);
Route::delete('/admin/users/{id}', [AuthController::class, 'hapusAkun']);
