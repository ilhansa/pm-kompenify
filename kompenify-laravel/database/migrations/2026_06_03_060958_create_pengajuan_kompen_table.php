<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pengajuan_kompen', function (Blueprint $table) {
            // Menggunakan UUID sebagai Primary Key bawaan tim kalian
            $table->uuid('id')->primary();

            // FK MAHASISWA (Relasi ke tabel mahasiswas)
            $table->foreignId('mahasiswa_id')
                ->constrained('mahasiswas')
                ->cascadeOnDelete();

            // FK ASSIGNMENT (Relasi UUID ke tabel assignments)
            $table->uuid('assignment_id');
            $table->foreign('assignment_id')
                ->references('id')
                ->on('assignments')
                ->cascadeOnDelete();

            // ✅ STATUS UTAMA: Tetap pakai alur aman bawaan awal backend (pending / diterima / ditolak)
            $table->string('status')->default('pending');

            // 🚀 FITUR BARU: Kolom penampung kode hash/token QR unik setelah dosen/kaprodi klik TTD
            // Statusnya nullable() karena baru terisi setelah status pengajuan di-ACC menjadi 'diterima'
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