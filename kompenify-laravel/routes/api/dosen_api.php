<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AssignmentController;

// ==========================================
// RUTE KHUSUS DOSEN
// URL otomatis diawali dengan: /api/dosen/...
// ==========================================
Route::prefix('dosen')->group(function () {
    
    // 1. Dosen membuat assignment baru
    // Method: POST | URL: http://localhost:8000/api/dosen/assignments
    Route::post('/assignments', [AssignmentController::class, 'store']);

    // ---------------------------------------------------------
    // 💡 CONTOH UNTUK RUTE SELANJUTNYA (Bisa kamu buka nanti):
    // ---------------------------------------------------------
    
    // 2. Dosen melihat semua assignment miliknya
    // Route::get('/assignments', [AssignmentController::class, 'index']);
    
    // 3. Dosen mengedit assignment
    // Route::put('/assignments/{id}', [AssignmentController::class, 'update']);
    
    // 4. Dosen menghapus assignment
    // Route::delete('/assignments/{id}', [AssignmentController::class, 'destroy']);

});