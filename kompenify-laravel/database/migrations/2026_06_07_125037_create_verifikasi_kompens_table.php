<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('verifikasi_kompens', function (Blueprint $table) {
            // Kita pakai UUID agar seragam dengan tabel pengajuan kamu
            $table->uuid('id')->primary();

            // FK ke tabel pengajuan_kompen (UUID)
            $table->uuid('pengajuan_id');
            $table->foreign('pengajuan_id')
                ->references('id')
                ->on('pengajuan_kompen')
                ->cascadeOnDelete();

            // FK ke tabel users (siapa dosen/kaprodi yang ttd/acc)
            // Sesuaikan dengan tipe data ID di tabel users kamu (biasanya foreignId jika bigInteger)
            $table->uuid('user_id'); 
            $table->foreign('user_id')
                  ->references('id')
                  ->on('users')
                  ->cascadeOnDelete();

            $table->string('status'); // 'diterima' atau 'ditolak'
            $table->text('catatan')->nullable(); // Catatan dari dosen kalau ditolak
            $table->string('file_ttd')->nullable(); // Alamat/path gambar scan TTD atau string coretan jika pakai Opsi 1

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('verifikasi_kompens');
    }
};