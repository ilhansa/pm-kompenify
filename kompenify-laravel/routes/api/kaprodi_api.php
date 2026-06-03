<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AssignmentController;

Route::prefix('kaprodi')->group(function () {
    
    // Rute CRUD Assignment
    
    // view
    // get all
    Route::get('/assignments', [AssignmentController::class, 'index']);
    // get details
    Route::get('/assignments/{id}', [AssignmentController::class, 'show']);
    // create
    Route::post('/assignments', [AssignmentController::class, 'store']);
    // update
    Route::put('/assignments/{id}', [AssignmentController::class, 'update']);
    // delete
    Route::delete('/assignments/{id}', [AssignmentController::class, 'destroy']);

});