<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Assignment extends Model
{
    use HasFactory;

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'judul',
        'deskripsi',
        'jam_kompen',
        'tanggal_mulai',
        'tanggal_selesai',
        'status',
        'dosen_id',
    ];

    // Relasi ke User (dosen)
    public function dosen()
    {
        return $this->belongsTo(User::class, 'dosen_id');
    }

    // 1. Relasi ke Pengajuan (Satu Tugas punya Banyak Pengajuan)
    public function pengajuans()
    {
        return $this->hasMany(PengajuanKompen::class, 'assignment_id');
    }

    // 2. Kalau Tugas dihapus, pengajuannya juga kehapus (lewat Laravel)
    protected static function boot()
    {
        parent::boot();

        static::deleting(function ($assignment) {
            $assignment->pengajuans->each->delete();
        });
    }
}