<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class VerifikasiKompen extends Model
{
    use HasFactory;

    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'pengajuan_id',
        'user_id',
        'status',
        'catatan',
        'file_ttd',
    ];

    // Auto generate UUID saat membuat data baru
    protected static function boot()
    {
        parent::boot();
        static::creating(function ($model) {
            if (empty($model->id)) {
                $model->id = (string) Str::uuid();
            }
        });
    }

    // Relasi balik ke Pengajuan
    public function pengajuan()
    {
        return $this->belongsTo(PengajuanKompen::class, 'pengajuan_id');
    }

    // Relasi ke User (Dosen/Kaprodi yang memverifikasi)
    public function verifikator()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}