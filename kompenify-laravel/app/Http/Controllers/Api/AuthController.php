<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
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

        // 1. Cari user berdasarkan username di tabel users
        $user = User::where('username', $request->username)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Username atau password salah.'
            ], 401);
        }

        // 2. Kondisional load data berdasarkan Role yang login
        $mahasiswaData = null;
        $dosenData = null;

        if ($user->role === 'mhs' && $user->mahasiswa) {
            $mahasiswaData = [
                'id' => $user->mahasiswa->id,
                'user_id' => $user->mahasiswa->user_id,
                'nim' => $user->mahasiswa->nim,
                'prodi' => $user->mahasiswa->prodi,
                'total_jam_kompen' => (int) $user->mahasiswa->total_jam_kompen,
                'sisa_jam_kompen' => (int) $user->mahasiswa->sisa_jam_kompen,
            ];
        } elseif (($user->role === 'dosen' || $user->role === 'kaprodi') && $user->dosen) {
            // JALUR DATA DOSEN / KAPRODI
            $dosenData = [
                'id' => $user->dosen->id,
                'user_id' => $user->dosen->user_id,
                'nip' => $user->dosen->nip,
                'prodi' => $user->dosen->prodi,
                'signature_base64' => $user->dosen->signature_base64,
            ];
        }

        // Buat token Sanctum
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil.',
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'username' => $user->username,
                'role' => $user->role,
                'mahasiswa' => $mahasiswaData,
                'dosen' => $dosenData, // Data dosen ikut dikirim rapi di sini!
            ]
        ], 200);
    }

    public function getProfile(Request $request)
    {
        $user = $request->user();

        $mahasiswaData = null;
        $dosenData = null;

        if ($user->role === 'mhs' && $user->mahasiswa) {
            $mahasiswaData = [
                'id' => $user->mahasiswa->id,
                'user_id' => $user->mahasiswa->user_id,
                'nim' => $user->mahasiswa->nim,
                'prodi' => $user->mahasiswa->prodi,
                'total_jam_kompen' => (int) $user->mahasiswa->total_jam_kompen,
                'sisa_jam_kompen' => (int) $user->mahasiswa->sisa_jam_kompen,
            ];
        } elseif (($user->role === 'dosen' || $user->role === 'kaprodi') && $user->dosen) {
            $dosenData = [
                'id' => $user->dosen->id,
                'user_id' => $user->dosen->user_id,
                'nip' => $user->dosen->nip,
                'prodi' => $user->dosen->prodi,
                'signature_base64' => $user->dosen->signature_base64,
            ];
        }

        return response()->json([
            'success' => true,
            'message' => 'Data profil berhasil diambil.',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'username' => $user->username,
                'role' => $user->role,
                'mahasiswa' => $mahasiswaData,
                'dosen' => $dosenData, // Sinkronkan juga di rute ambil profil
            ]
        ], 200);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil.'
        ], 200);
    }
}