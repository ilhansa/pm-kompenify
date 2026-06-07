<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pengajuan_kompen', function (Blueprint $table) {
            $table->uuid('id')->primary(); // UUID bawaan kelompok lu

            // Foreign Key Mahasiswa
            $table->foreignId('mahasiswa_id')
                ->constrained('mahasiswas')
                ->cascadeOnDelete();

            // Foreign Key Assignment
            $table->uuid('assignment_id');
            $table->foreign('assignment_id')
                ->references('id')
                ->on('assignments')
                ->cascadeOnDelete();

            // 🚀 KUNCI ENUM DI SINI: Hanya 6 status ini yang boleh masuk database!
            $table->enum('status', [
                'pending',
                'sedang dikerjakan',
                'menunggu_ttd_dosen',
                'menunggu_ttd_kaprodi',
                'diterima',
                'ditolak'
            ])->default('pending'); // Pas war slot otomatis 'pending'

            // Kolom Token QR E-TTD Digital
            $table->string('qr_token_dosen')->nullable();
            $table->string('qr_token_kaprodi')->nullable();

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pengajuan_kompen');
    }
};
