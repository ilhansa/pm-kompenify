// src/firebase.js
import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";

// TODO: Ganti dengan konfigurasi dari Firebase Console projek E-Kompen-mu
const firebaseConfig = {
  apiKey: "AIzaSyBsE7GCJt-mDWlVMA-lmLuOGDdOUorLHoE",
  authDomain: "kompenfy-fire.firebaseapp.com",
  projectId: "kompenfy-fire",
  storageBucket: "kompenfy-fire.firebasestorage.app",
  messagingSenderId: "283741041336",
  appId: "1:283741041336:web:f60bbaaa6dcf6f86043a4d",
  measurementId: "G-3PMV59EWGV"
};

// Inisialisasi Firebase
const app = initializeApp(firebaseConfig);

// Eksport Firestore biar bisa dipakai di halaman admin manapun
export const db = getFirestore(app);