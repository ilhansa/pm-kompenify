import 'package:flutter/material.dart';
import 'app_theme.dart';

class UploadPage extends StatelessWidget {
  const UploadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        title: const Text("Upload Bukti", style: AppTextStyle.h2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pilih Tugas Kompen", style: AppTextStyle.h3),
            const SizedBox(height: 12),
            
            // Dropdown simulasi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Bersih Ruang Baca", style: AppTextStyle.body),
                  Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text("Lampirkan Bukti (Foto/PDF)", style: AppTextStyle.h3),
            const SizedBox(height: 12),

            // Area Upload
            GestureDetector(
              onTap: () {
                // Nanti di sini pakai file_picker
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Fitur pilih file akan aktif setelah tambah library!")),
                );
              },
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 2,
                    style: BorderStyle.solid, // Nanti bisa diubah ke dashed
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 48, color: AppColors.primary.withOpacity(0.5)),
                    const SizedBox(height: 12),
                    const Text("Ketuk untuk memilih file", style: AppTextStyle.caption),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Tombol Kirim
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Berhasil mengirim bukti kompen!")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
                  elevation: 0,
                ),
                child: const Text(
                  "Kirim Sekarang",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}