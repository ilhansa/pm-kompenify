import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mahasiswa_model.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // LOGIN MENGGUNAKAN NIM
  Future<MahasiswaModel?> loginMahasiswaLokal(String nim, String password) async {
    try {
      // Otomatis ubah NIM menjadi format email di latar belakang
      String fakeEmail = "$nim@kompenify.local";

      // Tembak ke Firebase Auth bawaan
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: fakeEmail,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // Ambil data tambahannya dari Firestore
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return MahasiswaModel.fromFirestore(uid, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Error Login NIM: $e");
      rethrow;
    }
  }

  // REGISTRASI MENGGUNAKAN NIM
  Future<void> registrasiMahasiswaLokal(MahasiswaModel mahasiswa) async {
    try {
      // Ubah NIM menjadi format email tiruan sebelum didaftarkan
      String fakeEmail = "${mahasiswa.nim}@kompenify.local";

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: fakeEmail,
        password: mahasiswa.password,
      );

      String uid = userCredential.user!.uid;

      // Simpan data lengkap ke database Firestore
      await _db.collection('users').doc(uid).set(mahasiswa.toJson());
    } catch (e) {
      print("Error Registrasi NIM: $e");
      rethrow;
    }
  }
}