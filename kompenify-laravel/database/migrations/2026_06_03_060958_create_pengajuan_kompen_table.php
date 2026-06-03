<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pengajuan_kompen', function (Blueprint $table) {
            $table->uuid('id')->primary();

            // MAHASISWA (bigInteger FK, sesuai $table->id() di mahasiswas)
            $table->foreignId('mahasiswa_id')
                ->constrained('mahasiswas')
                ->cascadeOnDelete();

            // ASSIGNMENT (UUID FK)
            $table->uuid('assignment_id');
            $table->foreign('assignment_id')
                ->references('id')
                ->on('assignments')
                ->cascadeOnDelete();

            $table->string('status')->default('pending');

            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pengajuan_kompen');
    }
};