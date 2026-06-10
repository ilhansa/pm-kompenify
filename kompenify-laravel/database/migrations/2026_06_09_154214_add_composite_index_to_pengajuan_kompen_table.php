<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('pengajuan_kompen', function (Blueprint $table) {
            // Kita pasang composite index agar pencarian per mahasiswa 
            // berdasarkan statusnya jadi sangat cepat (O(1) secara teknis)
            $table->index(['mahasiswa_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::table('pengajuan_kompen', function (Blueprint $table) {
            $table->dropIndex(['mahasiswa_id', 'status']);
        });
    }
};