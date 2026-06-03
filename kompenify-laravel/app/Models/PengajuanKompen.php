<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PengajuanKompen extends Model
{
    use HasFactory;

    protected $table = 'pengajuan_kompen';

    protected $fillable = [
        'id',
        'mahasiswa_id',
        'assignment_id',
        'status',
    ];

    public $incrementing = false; // karena pakai UUID
    protected $keyType = 'string';
}