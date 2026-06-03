<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Mahasiswa;
use App\Models\Dosen;
use App\Models\Kaprodi;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB; // 📝 Wajib dipanggil untuk insert tabel admins biasa
use Illuminate\Support\Str;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // ==========================================
        // 1. BUAT AKUN MAHASISWA
        // ==========================================
        $mhsId = Str::uuid();

        User::create([
            'id'       => $mhsId,
            'nama'     => 'Ilsa Ilmansyah',
            'nimNip'   => '244107060072',
            'password' => 'password123', // Cukup teks polos, otomatis di-hash oleh model User!
            'role'     => 'mhs'
        ]);

        Mahasiswa::create([
            'user_id'          => $mhsId,
            'nim'              => '244107060072',
            'prodi'            => 'D4 Sistem Informasi Bisnis',
            'total_jam_kompen' => 10,
            'sisa_jam_kompen'  => 10,
        ]);

        // ==========================================
        // 2. BUAT AKUN DOSEN
        // ==========================================
        $dosenId = Str::uuid();

        User::create([
            'id'       => $dosenId,
            'nama'     => 'Pak Dosen Kompen',
            'nimNip'   => 'NIP001',
            'password' => 'password123',
            'role'     => 'dosen'
        ]);

        Dosen::create([
            'user_id' => $dosenId,
            'nip'     => 'NIP001'
        ]);

        // ==========================================
        // 3. BUAT AKUN KAPRODI
        // ==========================================
        $kaprodiId = Str::uuid();

        User::create([
            'id'       => $kaprodiId,
            'nama'     => 'Bapak Kaprodi JTI',
            'nimNip'   => 'KAPRODI01',
            'password' => 'password123',
            'role'     => 'kaprodi'
        ]);

        Kaprodi::create([
            'user_id' => $kaprodiId,
            'nip'     => 'KAPRODI01'
        ]);

        // ==========================================
        // 4. BUAT AKUN ADMIN (DIPERBAIKI)
        // ==========================================
        $adminId = Str::uuid(); // Ikat UUID-nya dulu biar singkron

        User::create([
            'id'       => $adminId,
            'nama'     => 'Admin Jurusan',
            'nimNip'   => 'ADMIN001', // Gunakan ini buat login admin di web nanti!
            'password' => 'password123',
            'role'     => 'admin'
        ]);

        // SUNTIK TABEL ANAK ADMINS: Mencegah error foreign key constraint di MySQL!
        DB::table('admins')->insert([
            'id'         => $adminId,
            'created_at' => now(),
            'updated_at' => now()
        ]);
    }
}
