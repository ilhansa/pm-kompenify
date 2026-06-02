<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * Pengaturan UUID agar tidak dianggap Integer Auto-Increment oleh Laravel
     */
    public $incrementing = false; // Matikan auto-increment angka biasa
    protected $keyType = 'string'; // Beritahu Laravel kalau primary key berupa string (UUID)

    /**
     * The attributes that are mass assignable.
     * Kolom yang diizinkan untuk diisi secara massal (Mass Assignment).
     */
    protected $fillable = [
        'id',        // Wajib dimasukkan karena id UUID diisi manual dari aplikasi
        'nimNip',    // Diubah dari 'username' sesuai Class Diagram
        'nama',      // Diubah dari 'name' sesuai Class Diagram
        'password',  // Tetap password
        'role'       // Tetap role (RoleEnum)
    ];

    /**
     * Relasi ke Admin (Sesuai panah Extends di Class Diagram)
     */
    public function admin()
    {
        // Relasi One-to-One: id admin merujuk ke id user
        return $this->hasOne(Admin::class, 'id', 'id');
    }

    /**
     * Relasi ke Mahasiswa (Sesuai Class Diagram)
     */
    public function mahasiswa()
    {
        // Menentukan foreign_key 'user_id' secara eksplisit karena kita pakai UUID
        return $this->hasOne(Mahasiswa::class, 'user_id', 'id');
    }

    /**
     * Relasi ke Dosen (Sesuai Class Diagram)
     */
    public function dosen()
    {
        // Menentukan foreign_key 'user_id' secara eksplisit karena kita pakai UUID
        return $this->hasOne(Dosen::class, 'user_id', 'id');
    }

    /**
     * PERBAIKAN: Relasi ke Kaprodi (Sesuai dengan Tabel kaprodis di phpMyAdmin & Class Diagram Extends)
     */
    public function kaprodi()
    {
        // Menghubungkan kolom user_id di tabel kaprodis ke id di tabel users
        return $this->hasOne(Kaprodi::class, 'user_id', 'id');
    }

    /**
     * The attributes that should be hidden for serialization.
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * The attributes that should be cast.
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed', // Password otomatis di-hash aman oleh Laravel 11
    ];
}
