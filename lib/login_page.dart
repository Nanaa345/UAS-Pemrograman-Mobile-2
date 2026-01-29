import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final DBHelper _dbHelper = DBHelper();
  bool isRegistering = false; 

  void _submit() async {
    String email = _emailCtrl.text;
    String pass = _passCtrl.text;

    if (isRegistering) {
      await _dbHelper.registerUser(email, pass);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil Register! Silahkan Login")));
      setState(() => isRegistering = false);
    } else {
      bool isLoggedIn = await _dbHelper.loginUser(email, pass);
      if (isLoggedIn) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email atau Password salah")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(isRegistering ? "Daftar Akun" : "Login TabunganKu", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder())),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit, 
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text(isRegistering ? "Register" : "Login")
              ),
            ),
            TextButton(
              onPressed: () => setState(() => isRegistering = !isRegistering),
              child: Text(isRegistering ? "Sudah punya akun? Login" : "Belum punya akun? Daftar"),
            )
          ],
        ),
      ),
    );
  }
}