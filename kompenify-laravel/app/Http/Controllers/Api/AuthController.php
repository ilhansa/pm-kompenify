<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller; // Menghubungkan ke Controller induk
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate([
            'username' => 'required',
            'password' => 'required',
        ]);

        // 1. Cari di tabel users berdasarkan username
        $user = User::where('username', $request->username)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Username atau password salah.'
            ], 401);
        }

        // 2. Siapkan data detail berdasarkan role
        $detailData = [];
        if ($user->role === 'mhs') {
            $detailData = [
                'nim' => $user->mahasiswa ? $user->mahasiswa->nim : null,
                'prodi' => $user->mahasiswa ? $user->mahasiswa->prodi : null,
                'total_jam_kompen' => $user->mahasiswa ? $user->mahasiswa->total_jam_kompen : null,
                'sisa_jam_kompen' => $user->mahasiswa ? $user->mahasiswa->sisa_jam_kompen : null,
            ];
        } elseif ($user->role === 'dosen') {
            $detailData = [
                'nip' => $user->dosen ? $user->dosen->nip : null,
            ];
        }

        // 3. Buat Token
        $user->tokens()->delete();
        
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil!',
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => array_merge([
                'id' => $user->id,
                'name' => $user->name,
                'username' => $user->username,
                'role' => $user->role,
            ], $detailData)
        ], 200);
    }

    // Fungsi baru untuk mengambil data profil user yang sedang login
    public function getProfile(Request $request)
    {
        $user = $request->user(); // Mengambil data user saat ini berdasarkan Token Sanctum

        // Ambil detail data tambahan sesuai role
        $detailData = [];
        if ($user->role === 'mhs') {
            $detailData = [
                'nim' => $user->mahasiswa ? $user->mahasiswa->nim : null,
                'prodi' => $user->mahasiswa ? $user->mahasiswa->prodi : null,
                'total_jam_kompen' => $user->mahasiswa ? $user->mahasiswa->total_jam_kompen : 0,
                'sisa_jam_kompen' => $user->mahasiswa ? $user->mahasiswa->sisa_jam_kompen : 0,
            ];
        } elseif ($user->role === 'dosen') {
            $detailData = [
                'nip' => $user->dosen ? $user->dosen->nip : null,
            ];
        }

        return response()->json([
            'success' => true,
            'message' => 'Data profil berhasil diambil.',
            'user' => array_merge([
                'id' => $user->id,
                'name' => $user->name,
                'username' => $user->username,
                'role' => $user->role,
            ], $detailData)
        ], 200);
    }

    public function logout(Request $request)
    {
        // Menghapus token yang saat ini sedang digunakan untuk login
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Berhasil logout, token berhasil dihapus!'
        ], 200);
    }
}
