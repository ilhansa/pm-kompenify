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

        $user = User::where('nimNip', $request->username)->first();

        if (!$user || (!Hash::check($request->password, $user->password) && $request->password !== $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Username atau password salah, Bang.'
            ], 401);
        }

        $mahasiswaData = null;
        $dosenData = null;
        $adminData = null;
        $kaprodiData = null;

        if ($user->role === 'mhs' && $user->mahasiswa) {
            $mahasiswaData = [
                'id' => $user->mahasiswa->id,
                'user_id' => $user->mahasiswa->user_id,
                'nim' => $user->mahasiswa->nim,
                'prodi' => $user->mahasiswa->prodi,
                'total_jam_kompen' => (int) $user->mahasiswa->total_jam_kompen,
                'sisa_jam_kompen' => (int) $user->mahasiswa->sisa_jam_kompen,
            ];
        } elseif ($user->role === 'dosen' && $user->dosen) {
            $dosenData = [
                'id' => $user->dosen->id,
                'user_id' => $user->dosen->user_id,
                'nip' => $user->dosen->nip,
                'prodi' => $user->dosen->prodi,
                'signature_base64' => $user->dosen->signature_base64,
            ];
        } elseif ($user->role === 'kaprodi' && $user->kaprodi) {
            $kaprodiData = [
                'id' => $user->kaprodi->id,
                'user_id' => $user->kaprodi->user_id,
                'nip' => $user->kaprodi->nip,
                'tandaTanganPath' => $user->kaprodi->tandaTanganPath,
            ];
        } elseif ($user->role === 'admin' && $user->admin) {
            $adminData = [
                'id' => $user->admin->id,
            ];
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil.',
            'access_token' => $token,
            'token_type' => 'Bearer',
            'user' => [
                'id' => $user->id,
                'nama' => $user->nama,
                'nimNip' => $user->nimNip,
                'role' => $user->role,
                'mahasiswa' => $mahasiswaData,
                'dosen' => $dosenData,
                'kaprodi' => $kaprodiData,
                'admin' => $adminData,
            ]
        ], 200);
    }

    public function getProfile(Request $request)
    {
        $user = $request->user();

        $mahasiswaData = null;
        $dosenData = null;
        $adminData = null;
        $kaprodiData = null;

        if ($user->role === 'mhs' && $user->mahasiswa) {
            $mahasiswaData = [
                'id' => $user->mahasiswa->id,
                'user_id' => $user->mahasiswa->user_id,
                'nim' => $user->mahasiswa->nim,
                'prodi' => $user->mahasiswa->prodi,
                'total_jam_kompen' => (int) $user->mahasiswa->total_jam_kompen,
                'sisa_jam_kompen' => (int) $user->mahasiswa->sisa_jam_kompen,
            ];
        } elseif ($user->role === 'dosen' && $user->dosen) {
            $dosenData = [
                'id' => $user->dosen->id,
                'user_id' => $user->dosen->user_id,
                'nip' => $user->dosen->nip,
                'prodi' => $user->dosen->prodi,
                'signature_base64' => $user->dosen->signature_base64,
            ];
        } elseif ($user->role === 'kaprodi' && $user->kaprodi) {
            $kaprodiData = [
                'id' => $user->kaprodi->id,
                'user_id' => $user->kaprodi->user_id,
                'nip' => $user->kaprodi->nip,
                'tandaTanganPath' => $user->kaprodi->tandaTanganPath,
            ];
        } elseif ($user->role === 'admin' && $user->admin) {
            $adminData = [
                'id' => $user->admin->id,
            ];
        }

        return response()->json([
            'success' => true,
            'message' => 'Data profil berhasil diambil.',
            'user' => [
                'id' => $user->id,
                'nama' => $user->nama,
                'nimNip' => $user->nimNip,
                'role' => $user->role,
                'mahasiswa' => $mahasiswaData,
                'dosen' => $dosenData,
                'kaprodi' => $kaprodiData,
                'admin' => $adminData,
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
