<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('persetujuan_kaprodis', function (Blueprint $table) {
            $table->uuid('id')->primary();

            // Relasi ke Pengajuan Kompen
            $table->uuid('pengajuan_id');
            $table->foreign('pengajuan_id')
                ->references('id')
                ->on('pengajuan_kompen')
                ->cascadeOnDelete();

            // Relasi ke Kaprodi (Sesuai dengan tipe data tabel users kamu yang pakai UUID)
            $table->uuid('kaprodi_id');
            $table->foreign('kaprodi_id')
                ->references('id')
                ->on('users') // Mengarah ke tabel users dengan role kaprodi
                ->cascadeOnDelete();

            $table->string('keputusan'); // Isinya: 'diterima' atau 'ditolak'
            
            // Menggantikan created_at/updated_at bawaan agar namanya sesuai ERD (disetujui_pada)
            $table->timestamp('disetujui_pada')->useCurrent();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('persetujuan_kaprodis');
    }
};