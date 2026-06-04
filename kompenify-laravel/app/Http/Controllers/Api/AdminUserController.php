<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class AdminUserController extends Controller
{
    public function lihatDaftarAkun()
    {
        $users = DB::table('users')
        ->leftJoin('mahasiswas', 'users.id', '=', 'mahasiswas.user_id')
        ->select('users.id', 'users.nimNip', 'users.nama', 'users.role', 'mahasiswas.prodi')
        ->orderBy('users.created_at', 'desc')
        ->get();

        return response()->json([
            'success' => true,
            'data' => $users
        ], 200);
    }

    public function registerAkun(Request $request)
    {
        $usernameInput = $request->input('nimNip') ?? $request->input('username');

        if (!$usernameInput) {
            return response()->json([
                'success' => false,
                'message' => 'Kolom NIM/NIP/Username wajib diisi, Bang!'
            ], 400);
        }

        $isExist = User::where('nimNip', $usernameInput)->exists();
        if ($isExist) {
            return response()->json([
                'success' => false,
                'message' => 'NIM/NIP ini sudah terdaftar di sistem!'
            ], 400);
        }

        $user = User::create([
            'id'       => Str::uuid(),
            'nimNip'   => $usernameInput,
            'nama'     => $request->nama ?? $request->namaLengkap,
            'password' => $request->password ?? 'password123',
            'role'     => $request->role ?? 'mhs'
        ]);

        if ($user->role === 'admin') {
            DB::table('admins')->insert([
                'id'         => $user->id,
                'created_at' => now(),
                'updated_at' => now()
            ]);
        } elseif ($user->role === 'mhs') {
            DB::table('mahasiswas')->insert([
                'user_id'          => $user->id,
                'nim'              => $user->nimNip,
                'prodi'            => $request->input('prodi'),
                'total_jam_kompen' => 0,
                'sisa_jam_kompen'  => 0,
                'created_at'       => now(),
                'updated_at'       => now()
            ]);
        } elseif ($user->role === 'dosen') {
            DB::table('dosens')->insert([
                'user_id'    => $user->id,
                'nip'        => $user->nimNip,
                'created_at' => now(),
                'updated_at' => now()
            ]);
        } elseif ($user->role === 'kaprodi') {
            DB::table('kaprodis')->insert([
                'user_id'         => $user->id,
                'nip'             => $user->nimNip,
                'tandaTanganPath' => null,
                'created_at'      => now(),
                'updated_at'      => now()
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Akun baru berhasil didaftarkan ke sistem!'
        ], 201);
    }

   public function editAkun(Request $request, $id)
{
    $user = User::find($id);
    if (!$user) {
        return response()->json(['success' => false, 'message' => 'User tidak ditemukan.'], 404);
    }

    $request->validate([
        'nimNip'   => 'required|unique:users,nimNip,'.$id,
        'nama'     => 'required',
        'role'     => 'required|in:mhs,dosen,kaprodi,admin',
        'password' => 'nullable|min:4'
    ]);

    $updateData = [
        'nimNip' => $request->nimNip,
        'nama'   => $request->nama,
        'role'   => $request->role
    ];

    if ($request->filled('password')) {
        $updateData['password'] = $request->password;
    }

    // Update tabel users
    $user->update($updateData);

    // Bersihkan data di tabel child
    DB::table('mahasiswas')->where('user_id', $id)->delete();
    DB::table('dosens')->where('user_id', $id)->delete();
    DB::table('kaprodis')->where('user_id', $id)->delete();
    DB::table('admins')->where('id', $id)->delete();

    // Migrasi data ke tabel child baru
    if ($user->role === 'mhs') {
        DB::table('mahasiswas')->insert([
            'user_id'          => $id,
            'nim'              => $request->nimNip,
            'prodi'            => $request->input('prodi'),
            'total_jam_kompen' => 0,
            'sisa_jam_kompen'  => 0,
            'created_at'       => now(),
            'updated_at'       => now()
        ]);
    } elseif ($user->role === 'dosen') {
        DB::table('dosens')->insert([
            'user_id'    => $id,
            'nip'        => $request->nimNip,
            'created_at' => now(),
            'updated_at' => now()
        ]);
    } elseif ($user->role === 'kaprodi') {
        DB::table('kaprodis')->insert([
            'user_id'         => $id,
            'nip'             => $request->nimNip,
            'tandaTanganPath' => null,
            'created_at'      => now(),
            'updated_at'      => now()
        ]);
    } elseif ($user->role === 'admin') {
        DB::table('admins')->insert([
            'id'         => $id,
            'created_at' => now(),
            'updated_at' => now()
        ]);
    }

    return response()->json([
        'success' => true,
        'message' => 'Akun telah diperbarui!'
    ], 200);
}

    public function hapusAkun($id)
    {
        $user = User::find($id);
        if (!$user) {
            return response()->json(['success' => false, 'message' => 'User tidak ditemukan.'], 404);
        }

        if ($user->role === 'admin') {
            DB::table('admins')->where('id', $id)->delete();
        } elseif ($user->role === 'mhs') {
            DB::table('mahasiswas')->where('user_id', $id)->delete();
        } elseif ($user->role === 'dosen') {
            DB::table('dosens')->where('user_id', $id)->delete();
        } elseif ($user->role === 'kaprodi') {
            DB::table('kaprodis')->where('user_id', $id)->delete();
        }

        $user->delete();

        return response()->json([
            'success' => true,
            'message' => 'Akun berhasil dihapus dari sistem!'
        ], 200);
    }
}
