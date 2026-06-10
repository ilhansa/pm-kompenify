<!DOCTYPE html>
<html>
<head>
    <title>Surat Bebas Kompensasi</title>
    <style>
        body { font-family: 'Times New Roman', Times, serif; font-size: 14px; line-height: 1.5; color: #000; padding: 30px; }
        .kop-surat { text-align: center; border-bottom: 3px double #000; padding-bottom: 10px; margin-bottom: 30px; }
        .kop-surat h2 { margin: 0; font-size: 18px; }
        .kop-surat h3 { margin: 5px 0; font-size: 20px; text-transform: uppercase; }
        .kop-surat p { margin: 0; font-size: 12px; }
        .judul { text-align: center; font-weight: bold; font-size: 16px; text-decoration: underline; margin-bottom: 30px; }
        .isi-surat { margin-bottom: 20px; text-align: justify; }
        .table-data { width: 90%; margin: 0 auto 30px auto; border-collapse: collapse; }
        .table-data td { padding: 5px; vertical-align: top; }
        .ttd-container { width: 100%; margin-top: 50px; }
        .ttd-kiri { float: left; width: 45%; text-align: center; }
        .ttd-kanan { float: right; width: 45%; text-align: center; }
        .qr-box { margin: 15px 0; }
        .clear { clear: both; }
    </style>
</head>
<body>

    <div class="kop-surat">
        <h2>KEMENTERIAN PENDIDIKAN, KEBUDAYAAN, RISET, DAN TEKNOLOGI</h2>
        <h3>POLITEKNIK NEGERI</h3>
        <p>Jl. Kampus Merdeka No. 1, Kota Kompenify, Telp (031) 123456</p>
    </div>

    <div class="judul">SURAT KETERANGAN BEBAS KOMPENSASI</div>

    <div class="isi-surat">
        Dengan hormat, yang bertanda tangan di bawah ini menerangkan bahwa mahasiswa berikut:
    </div>

    <table class="table-data">
        <tr>
            <td style="width: 30%;">Nama Lengkap</td>
            <td style="width: 5%;">:</td>
            <td><strong>{{ $pengajuan->mahasiswa->user->nama ?? 'Data Tidak Ditemukan' }}</strong></td>
        </tr>
        <tr>
            <td>Nomor Induk Mahasiswa</td>
            <td>:</td>
            <td>{{ $pengajuan->mahasiswa->nim ?? '-' }}</td>
        </tr>
        <tr>
            <td>Tugas Kompensasi</td>
            <td>:</td>
            <td>{{ $pengajuan->assignment->judul }}</td>
        </tr>
        <tr>
            <td>Bobot Waktu</td>
            <td>:</td>
            <td>{{ $pengajuan->assignment->jam_kompen }} Jam</td>
        </tr>
        <tr>
            <td>Tanggal Selesai</td>
            <td>:</td>
            <td>{{ $pengajuan->updated_at->format('d F Y') }}</td>
        </tr>
    </table>

    <div class="isi-surat">
        Telah menyelesaikan seluruh kewajiban kompensasi akademisnya dengan baik dan benar. Dokumen ini dicetak secara otomatis oleh sistem Kompenify dan telah divalidasi secara digital tanpa memerlukan tanda tangan basah.
    </div>

   <div class="ttd-container">
        <div class="ttd-kiri">
            <p>Mengetahui,<br>Dosen Pemberi Tugas</p>
            <div class="qr-box">
                {{-- 🚀 MENEMBAK GOOGLE API: AMAN, CEPAT, DAN DIJAMIN MUNCUL JINK! --}}
                <img src="https://chart.googleapis.com/chart?chs=100x100&cht=qr&chl={{ urlencode($urlValidasiDosen) }}&choe=UTF-8" width="100" height="100" />
            </div>
            <p><u>Validasi Sistem Elektronik</u></p>
        </div>

        <div class="ttd-kanan">
            <p>Mengesahkan,<br>Kepala Program Studi</p>
            <div class="qr-box">
                {{-- 🚀 AMAN DARI SEGALA MACAM ERROR CLASS NOT FOUND --}}
                <img src="https://chart.googleapis.com/chart?chs=100x100&cht=qr&chl={{ urlencode($urlValidasiKaprodi) }}&choe=UTF-8" width="100" height="100" />
            </div>
            <p><u>Validasi Sistem Elektronik</u></p>
        </div>
    </div>
    <div class="clear"></div>

</body>
</html>