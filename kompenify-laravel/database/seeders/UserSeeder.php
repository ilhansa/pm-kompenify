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

        // Extend/Hubungkan ke tabel mahasiswa

        Mahasiswa::create([

            'user_id' => $mhsUser->id,

            'nim' => '244107060072',

            'prodi' => 'Sistem Informasi Bisnis'

        ]);



        // 2. Buat Akun Dosen

        $dosenUser = User::create([

            'name' => 'Pak Dosen Kompen',

            'username' => '198501012020', // Pakai NIP untuk username

            'password' => Hash::make('dosen123'),

            'role' => 'dosen'

        ]);

        // Extend/Hubungkan ke tabel dosen

        Dosen::create([

            'user_id' => $dosenUser->id,

            'nip' => '198501012020'

        ]);

    }

}