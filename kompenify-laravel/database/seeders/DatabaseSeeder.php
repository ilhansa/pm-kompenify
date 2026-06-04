<?php

namespace Database\Seeders;

// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // PERINTAH INI WAJIB ADA AGAR USERSEEDER DIEKSEKUSI
        $this->call([
            UserSeeder::class, 
        ]);
    }
}
