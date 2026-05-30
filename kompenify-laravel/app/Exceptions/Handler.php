<?php

namespace App\Exceptions;

use Illuminate\Foundation\Exceptions\Handler as ExceptionHandler;
use Throwable;
use Illuminate\Auth\AuthenticationException; // 📝 1. TAMBAHKAN IMPORT INI DI ATAS

class Handler extends ExceptionHandler
{
    /**
     * The list of the inputs that are never flashed to the session on validation exceptions.
     *
     * @var array<int, string>
     */
    protected $dontFlash = [
        'current_password',
        'password',
        'password_confirmation',
    ];

    /**
     * Register the exception handling callbacks for the application.
     */
    public function register(): void
    {
        $this->reportable(function (Throwable $e) {
            //
        });

        // 📝 2. TAMBAHKAN BLOK SAKTI INI DI SINI, BOS!
        // Berfungsi memotong error rute web dan memaksanya menjadi respon JSON rapi untuk REST API
        $this->renderable(function (Throwable $e, $request) {
            if ($request->is('api/*')) {
                
                // Jika error dipicu karena user belum login / token hangus / tidak sah
                if ($e instanceof AuthenticationException) {
                    return response()->json([
                        'message' => 'Sesi Anda telah berakhir atau tidak sah, silakan login ulang.'
                    ], 401);
                }

                // Untuk error umum lainnya (salah password, username tidak ketemu, rute salah, dll)
                return response()->json([
                    'message' => $e->getMessage() ?: 'Terjadi kesalahan pada server API.'
                ], 400);
            }
        });
    }
}