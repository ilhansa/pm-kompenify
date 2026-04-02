import 'package:flutter/material.dart';
import 'profile.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 30),

              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.school, color: Colors.white, size: 30),
              ),

              const SizedBox(height: 10),

              const Text(
                "Kompenify",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const Text(
                "Manage your compensation easily",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 30),

              Container(
                height: 120,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(child: Text("Welcome Students!")),
              ),

              const SizedBox(height: 30),

              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email),
                  hintText: "student@university.edu",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  hintText: "Enter your password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(color: Colors.blue[700]),
                ),
              ),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.blueAccent],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Center(
                    child: Text(
                      "Login",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              const Text("Don't have an account? Sign up"),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}