<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
    {
        Schema::create('bukti_kompens', function (Blueprint $table) {
            $table->uuid('id')->primary();
            
            // Foreign Key yang menunjuk ke tabel pengajuan_kompens
            $table->foreignUuid('pengajuan_id')->constrained('pengajuan_kompen')->cascadeOnDelete();
            
            $table->string('file_path');
            $table->string('tipe_file');
            $table->timestamps(); 
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bukti_kompens');
    }
};
