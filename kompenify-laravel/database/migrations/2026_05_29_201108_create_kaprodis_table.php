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
        $table->id(); // Auto-increment untuk primary key

        // Kolom foreign key untuk menyambung ke tabel users (UUID)
        $table->foreignUuId('user_id')->constrained('users')->onDelete('cascade');

        // Kolom tambahan pelengkap data kaprodi
        $table->string('nip')->unique();
        $table->string('tandaTanganPath')->nullable();

        $table->timestamps();
    });
}
};
