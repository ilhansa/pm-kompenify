<?php

namespace App\Http\Middleware;

use Illuminate\Auth\Middleware\Authenticate as Middleware;
use Illuminate\Http\Request;

class Authenticate extends Middleware
{
    /**
     * Get the path the user should be redirected to when they are not authenticated.
     */
protected function redirectTo(Request $request): ?string
{
    // ✅ Jika request meminta format JSON atau dikirim dari API (Flutter), jangan lempar rute login!
    return $request->expectsJson() ? null : null; 
}
}
