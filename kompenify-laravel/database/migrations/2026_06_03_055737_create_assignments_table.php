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
            // Menggunakan UUID sebagai Primary Key karena Flutter mengirim data Uuid().v4()
            $table->uuid('id')->primary(); 
            
            $table->string('judul');
            $table->text('deskripsi');
            $table->integer('jam_kompen');
            $table->date('tanggal_mulai');
            $table->date('tanggal_selesai'); // Di gambar ERD tertulis tanggal_selesai
            
            // Status bisa diatur defaultnya, misal: 'aktif', 'penuh', 'selesai'
            $table->string('status')->default('aktif'); 
            
            // Foreign key ke tabel users (karena dosen_id di Flutter mengambil dari user.id)
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