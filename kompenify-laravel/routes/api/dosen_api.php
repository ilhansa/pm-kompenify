<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AssignmentController;

Route::prefix('dosen')->group(function () {
    
    // 1. Dosen membuat assignment baru
    // Method: POST | URL: http://localhost:8000/api/dosen/assignments
    Route::post('/assignments', [AssignmentController::class, 'store']);
    
    // 2. Dosen melihat assignment
    
    // get all
    Route::get('/assignments', [AssignmentController::class, 'index']);
    // get detail
    Route::get('/assignments/{id}', [AssignmentController::class, 'show']);
    
    // 3. Dosen mengedit assignment
    Route::put('/assignments/{id}', [AssignmentController::class, 'update']);
    
    // 4. Dosen menghapus assignment
    Route::delete('/assignments/{id}', [AssignmentController::class, 'destroy']);

});