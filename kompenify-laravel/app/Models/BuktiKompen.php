<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class BuktiKompen extends Model
{
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = ['id', 'pengajuan_id', 'file_path', 'tipe_file'];

    public function pengajuan()
    {
        return $this->belongsTo(PengajuanKompen::class, 'pengajuan_id');
    }

    // AUTO-CLEAN STORAGE
    protected static function boot()
    {
        parent::boot();

        static::deleting(function ($bukti) {
            if (Storage::disk('public')->exists($bukti->file_path)) {
                Storage::disk('public')->delete($bukti->file_path);
            }
        });
    }
}