<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * UUID config
     */
    public $incrementing = false;
    protected $keyType = 'string';

    /**
     * Fillable fields
     */
    protected $fillable = [
        'id',
        'nimNip',
        'nama',
        'password',
        'role',
    ];

    /**
     * Hidden fields
     */
    protected $hidden = [
        'password',
        'remember_token',
        'created_at',
        'updated_at',
    ];

    /**
     * Casts
     */
    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];

    /*
    |--------------------------------------------------------------------------
    | ROLE HELPERS
    |--------------------------------------------------------------------------
    */

    public function isMahasiswa()
    {
        return $this->role === 'mahasiswa';
    }

    public function isDosen()
    {
        return $this->role === 'dosen';
    }

    public function isAdmin()
    {
        return $this->role === 'admin';
    }

    /*
    |--------------------------------------------------------------------------
    | RELATIONS
    |--------------------------------------------------------------------------
    */

    public function admin()
    {
        return $this->hasOne(Admin::class, 'id', 'id');
    }

    public function mahasiswa()
    {
        return $this->hasOne(Mahasiswa::class, 'user_id', 'id');
    }

    public function dosen()
    {
        return $this->hasOne(Dosen::class, 'user_id', 'id');
    }

    public function kaprodi()
    {
        return $this->hasOne(Kaprodi::class, 'user_id', 'id');
    }

    /**
     * Relasi ke pengajuan kompen (MAHASISWA)
     */
    public function pengajuanKompen()
    {
        return $this->hasMany(PengajuanKompen::class, 'mahasiswa_id', 'id');
    }
}