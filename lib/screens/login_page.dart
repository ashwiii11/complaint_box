import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authSvc = AuthService();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _signIn() async {
    setState(() { _loading = true; _error = null; });
    try {
      await _authSvc.signInEmail(_emailCtl.text.trim(), _passCtl.text);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    } on FirebaseAuthException catch (e) {
      setState(() { _error = e.message; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  Future<void> _signUp() async {
    setState(() { _loading = true; _error = null; });
    try {
      await _authSvc.signUpEmail(_emailCtl.text.trim(), _passCtl.text);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    } on FirebaseAuthException catch (e) {
      setState(() { _error = e.message; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  Future<void> _anonymous() async {
    setState(() { _loading = true; _error = null; });
    try {
      await _authSvc.signInAnonymously();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
    } on FirebaseAuthException catch (e) {
      setState(() { _error = e.message; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login / Anonymous')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(controller: _emailCtl, decoration: const InputDecoration(labelText: 'Email')),
          TextField(controller: _passCtl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
          const SizedBox(height: 12),
          if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _loading ? null : _signIn, child: const Text('Sign in')),
          ElevatedButton(onPressed: _loading ? null : _signUp, child: const Text('Create account')),
          const SizedBox(height: 8),
          TextButton(onPressed: _loading ? null : _anonymous, child: const Text('Continue as Guest (Anonymous)')),
        ],),
      ),
    );
  }
}
