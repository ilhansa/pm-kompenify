<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Mahasiswa;
use App\Models\Dosen;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Buat Akun Mahasiswa
        $mhsUser = User::create([
            'name' => 'Ilsa Ilmansyah',
            'username' => '244107060072', // Kita samakan username dengan NIM biar gampang login
            'password' => Hash::make('password123'),
            'role' => 'mhs'
        ]);

        // Extend/Hubungkan ke tabel mahasiswa + Tambah Data Jam Kompen
        Mahasiswa::create([
            'user_id' => $mhsUser->id,
            'nim' => '244107060072',
            'prodi' => 'Sistem Informasi Bisnis',
            'total_jam_kompen' => 10, // Contoh: Ilsa punya tunggakan 10 jam
            'sisa_jam_kompen' => 10,  // Karena belum dikerjakan, sisanya masih 10 jam
        ]);

        // 2. Buat Akun Dosen
        $dosenUser = User::create([
            'name' => 'Pak Dosen Kompen',
            'username' => '198501012020', // Pakai NIP untuk username
            'password' => Hash::make('dosen123'),
            'role' => 'dosen'
        ]);

        // Extend/Hubungkan ke tabel dosen (Dosen tidak punya kolom jam kompen)
        Dosen::create([
            'user_id' => $dosenUser->id,
            'nip' => '198501012020'
        ]);
    }
}