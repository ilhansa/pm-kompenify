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
        Schema::create('kaprodis', function (Blueprint $table) {
            $table->id(); // ID bawaan tabel kaprodi (Auto Increment biasa)
            
            // 1. Kolom user_id (WAJIB pakai tipe uuid karena tabel users pakai UUID)
            $table->uuid('user_id'); 
            
            // 2. Kolom NIP
            $table->string('nip')->unique(); 

            // 3. (Opsional tapi sangat disarankan) Foreign Key untuk keamanan data
            // Artinya: Kalau data user dihapus, data kaprodi ini ikut terhapus otomatis (cascade)
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('kaprodis');
    }
};