<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        // 1. Validasi inputan dari Axios React / Flutter
        $request->validate([
            'username' => 'required',
            'password' => 'required',
        ]);

        // 2. Cari user berdasarkan nimNip di database (Sesuai Class Diagram)
        $user = User::where('nimNip', $request->username)->first();

        // 3. Validasi Password
        if (!$user || (!Hash::check($request->password, $user->password) && $request->password !== $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Username atau password salah, Bang.'
            ], 401);
        }

        // 4. Kondisional load data berdasarkan Role yang login
        $mahasiswaData = null;
        $dosenData = null;
        $adminData = null;

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
        } elseif ($user->role === 'admin' && $user->admin) {
            $adminData = [
                'id' => $user->admin->id,
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
                'nama' => $user->nama,
                'nimNip' => $user->nimNip,
                'role' => $user->role,
                'mahasiswa' => $mahasiswaData,
                'dosen' => $dosenData,
                'admin' => $adminData,
            ]
        ], 200);
    }

    // ==================== 1. FUNGSI registerAkun() ====================
    public function registerAkun(Request $request)
    {
        $request->validate([
            'nimNip'   => 'required|unique:users,nimNip',
            'nama'     => 'required',
            'password' => 'required|min:4',
            'role'     => 'required|in:mhs,dosen,kaprodi,admin'
        ]);

        $user = User::create([
            'id'       => \Illuminate\Support\Str::uuid(),
            'nimNip'   => $request->nimNip,
            'nama'     => $request->nama,
            'password' => $request->password,
            'role'     => $request->role
        ]);

        if ($user->role === 'admin') {
            DB::table('admins')->insert(['id' => $user->id, 'created_at' => now(), 'updated_at' => now()]);
        } elseif ($user->role === 'mhs') {
            DB::table('mahasiswas')->insert([
                'user_id' => $user->id,
                'nim' => $user->nimNip,
                'total_jam_kompen' => 0,
                'sisa_jam_kompen' => 0,
                'created_at' => now(),
                'updated_at' => now()
            ]);
        } elseif ($user->role === 'dosen' || $user->role === 'kaprodi') {
            DB::table('dosens')->insert([
                'id' => \Illuminate\Support\Str::uuid(),
                'user_id' => $user->id,
                'nip' => $user->nimNip,
                'created_at' => now(),
                'updated_at' => now()
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Akun baru berhasil didaftarkan ke sistem!'
        ], 201);
    }

    // ==================== 2. FUNGSI editAkun() ====================
    public function editAkun(Request $request, $id)
    {
        $user = User::find($id);
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'User tidak ditemukan.'], 404);
        }

        $request->validate([
            'nimNip' => 'required|unique:users,nimNip,'.$id,
            'nama'   => 'required',
            'role'   => 'required|in:mhs,dosen,kaprodi,admin'
        ]);

        $user->update([
            'nimNip' => $request->nimNip,
            'nama'   => $request->nama,
            'role'   => $request->role
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Akun berhasil diperbarui!'
        ], 200);
    }

    // ==================== 3. FUNGSI hapusAkun() ====================
    public function hapusAkun($id)
    {
        $user = User::find($id);
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'User tidak ditemukan.'], 404);
        }

        DB::table('admins')->where('id', $id)->delete();
        DB::table('mahasiswas')->where('user_id', $id)->delete();
        DB::table('dosens')->where('user_id', $id)->delete();

        $user->delete();

        return response()->json([
            'success' => true,
            'message' => 'Akun berhasil dihapus dari sistem!'
        ], 200);
    }

    public function getProfile(Request $request)
    {
        $user = $request->user();

        $mahasiswaData = null;
        $dosenData = null;
        $adminData = null;

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
