import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mahasiswa_model.dart';
import '../models/dosen_model.dart'; // Pastikan model dosen sudah di-import

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // LOGIN MULTI-ROLE MENGGUNAKAN NIM/NIP
  Future<dynamic> loginUser(String nimNip, String password) async {
    try {
      // Otomatis ubah NIM/NIP menjadi format email di latar belakang
      String fakeEmail = "$nimNip@kompenify.local";

      // Tembak ke Firebase Auth bawaan
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: fakeEmail,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // Ambil data tambahannya dari Firestore
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String roleString = data['role'] ?? 'mahasiswa';

        // Pilah role untuk mengembalikan objek model yang tepat
        if (roleString == 'dosen') {
          return DosenModel.fromFirestore(uid, data);
        } else {
          return MahasiswaModel.fromFirestore(uid, data);
        }
      }
      return null;
    } catch (e) {
      print("Error Login: $e");
      rethrow;
    }
  }

  // FUNGSI LOGOUT RESMI
  Future<void> logoutUser() async {
    await _auth.signOut();
  }
}