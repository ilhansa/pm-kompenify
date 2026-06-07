<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class PersetujuanKaprodi extends Model
{
    use HasFactory;

    protected $table = 'persetujuan_kaprodis';
    public $incrementing = false;
    protected $keyType = 'string';
    
    // Matikan timestamps bawaan karena kita pakai 'disetujui_pada' sesuai ERD
    public $timestamps = false; 

    protected $fillable = [
        'id',
        'pengajuan_id',
        'kaprodi_id',
        'keputusan',
        'disetujui_pada',
    ];

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

    // Relasi ke User (Kaprodi)
    public function kaprodi()
    {
        return $this->belongsTo(User::class, 'kaprodi_id');
    }
}