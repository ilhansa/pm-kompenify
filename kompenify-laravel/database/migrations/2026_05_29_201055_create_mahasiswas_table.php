<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('mahasiswas', function (Blueprint $table) {
            $table->id();
            // Menghubungkan ke tabel users, jika user dihapus, data mhs ikut terhapus (cascade)
            $table->foreignUuid('user_id')->constrained('users')->onDelete('cascade');
            $table->string('nim')->unique();
            $table->string('prodi')->nullable(); // Contoh kolom tambahan spesifik mhs
            $table->integer('total_jam_kompen')->default(1000);
            $table->integer('sisa_jam_kompen')->default(999);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('mahasiswas');
    }
};
