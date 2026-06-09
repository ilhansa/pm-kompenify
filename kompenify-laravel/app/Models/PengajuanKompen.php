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
    'qr_token_dosen',   
    'qr_token_kaprodi', 
];

    public $incrementing = false;
    protected $keyType = 'string';

    // Relasi ke tabel assignments
    public function assignment()
    {
        return $this->belongsTo(Assignment::class, 'assignment_id');
    }

    // Relasi ke tabel mahasiswas
    public function mahasiswa()
    {
        return $this->belongsTo(Mahasiswa::class, 'mahasiswa_id');
    }

    public function bukti()
    {
        return $this->hasMany(BuktiKompen::class, 'pengajuan_id');
    }
}