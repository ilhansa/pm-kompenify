<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Mahasiswa;
use App\Models\Dosen;
use App\Models\Kaprodi; // 📝 Panggil model Kaprodi
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str; // 📝 Wajib dipanggil untuk fitur UUID

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // ==========================================
        // 1. BUAT AKUN MAHASISWA
        // ==========================================
        $mhsId = Str::uuid(); // Generate UUID
        
        User::create([
            'id'       => $mhsId,
            'nama'     => 'Ilsa Ilmansyah', // name -> nama
            'nimNip'   => '244107060072',   // username -> nimNip
            'password' => Hash::make('password123'),
            'role'     => 'mhs'
        ]);

        Mahasiswa::create([
            'user_id' => $mhsId,
            'nim'     => '244107060072', // Samakan dengan nimNip biar rapi
            'prodi'   => 'D4 Sistem Informasi Bisnis',
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
            'nimNip'   => 'NIP001', // Samakan dengan tombol Quick Demo Flutter
            'password' => Hash::make('password123'), // Samakan password biar gampang
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
            'password' => Hash::make('password123'),
            'role'     => 'kaprodi'
        ]);

        Kaprodi::create([
            'user_id' => $kaprodiId,
            'nip'     => 'KAPRODI01'
        ]);

        // ==========================================
        // 4. BUAT AKUN ADMIN
        // ==========================================
        User::create([
            'id'       => Str::uuid(),
            'nama'     => 'Admin Jurusan',
            'nimNip'   => 'ADMIN001',
            'password' => Hash::make('password123'),
            'role'     => 'admin'
        ]);
    }
}