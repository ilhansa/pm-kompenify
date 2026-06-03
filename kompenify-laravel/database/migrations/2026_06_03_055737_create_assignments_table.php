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
        Schema::create('assignments', function (Blueprint $table) {
            $table->uuid('id')->primary(); 
            
            $table->string('judul');
            $table->text('deskripsi');
            $table->integer('jam_kompen');
            $table->date('tanggal_mulai');
            $table->date('tanggal_selesai'); 
            $table->string('status')->default('aktif'); 
            
            // Relasi ke Dosen (Tabel Users) juga pakai UUID
            $table->uuid('dosen_id');
            $table->foreign('dosen_id')->references('id')->on('users')->onDelete('cascade');

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('assignments');
    }
};