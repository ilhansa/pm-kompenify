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

        // 3. Validasi Password (Mendukung hash otomatis Laravel 11 ATAU teks polos jika enkripsi eror)
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
            // JALUR DATA KAPRODI (Sesuai Class Diagram & phpMyAdmin)
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
                'kaprodi' => $kaprodiData,
                'admin' => $adminData,
            ]
        ], 200);
    }

    // ==================== 1. FUNGSI registerAkun() ====================
    public function registerAkun(Request $request)
{
    // 1. Validasi fleksibel (menangkap field dari React: nimNip ATAU username)
    $usernameInput = $request->input('nimNip') ?? $request->input('username');

    if (!$usernameInput) {
        return response()->json([
            'success' => false,
            'message' => 'Kolom NIM/NIP/Username wajib diisi, Bang!'
        ], 400);
    }

    // Cek apakah username/NIM sudah terdaftar
    $isExist = User::where('nimNip', $usernameInput)->exists();
    if ($isExist) {
        return response()->json([
            'success' => false,
            'message' => 'NIM/NIP ini sudah terdaftar di sistem!'
        ], 400);
    }

    // 2. Buat data user di tabel induk users
    $user = User::create([
        'id'       => \Illuminate\Support\Str::uuid(),
        'nimNip'   => $usernameInput,
        'nama'     => $request->nama ?? $request->namaLengkap, // antisipasi beda penamaan field di React
        'password' => $request->password ?? 'password123',
        'role'     => $request->role ?? 'mhs'
    ]);

    // 3. Masukkan data otomatis ke tabel anak sesuai role aksesnya
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
    } elseif ($user->role === 'dosen') {
        DB::table('dosens')->insert([
            'id' => \Illuminate\Support\Str::uuid(),
            'user_id' => $user->id,
            'nip' => $user->nimNip,
            'created_at' => now(),
            'updated_at' => now()
        ]);
    } elseif ($user->role === 'kaprodi') {
        DB::table('kaprodis')->insert([
            'id' => \Illuminate\Support\Str::uuid(),
            'user_id' => $user->id,
            'nip' => $user->nimNip,
            'tandaTanganPath' => null,
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
        // Cari user induknya dulu
        $user = User::find($id);
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'User tidak ditemukan.'], 404);
        }

        // Hanya hapus tabel anak yang sesuai dengan role aslinya
        if ($user->role === 'admin') {
            DB::table('admins')->where('id', $id)->delete();
        } elseif ($user->role === 'mhs') {
            DB::table('mahasiswas')->where('user_id', $id)->delete();
        } elseif ($user->role === 'dosen') {
            DB::table('dosens')->where('user_id', $id)->delete();
        } elseif ($user->role === 'kaprodi') {
            DB::table('kaprodis')->where('id', $id)->delete();
        }

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
            // PERBAIKAN: Ambil data profil kaprodi secara spesifik
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
