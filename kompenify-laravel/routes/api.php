<?php

use App\Http\Controllers\Api\AuthController;
use Illuminate\Support\Facades\Route;

// Route untuk Login
Route::post('/login', [AuthController::class, 'login']);