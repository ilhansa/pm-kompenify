<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Assignment extends Model
{
    use HasFactory;

    // 📝 1. TAMBAHKAN DUA BARIS INI WAJIB!
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',             // Pastikan id masuk ke fillable
        'judul',
        'deskripsi',
        'jam_kompen',
        'tanggal_mulai',
        'tanggal_selesai',
        'status',
        'dosen_id',
    ];
}