import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validator/screens/dashboard_screen.dart';
import 'package:validator/screens/butuh_persetujuan_screen.dart';
import 'package:validator/services/api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _errorMessage = null;
    });
    try {
      final result = await ApiService.checkUser(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );
      if (result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        final user = result['user'] ?? {};
        await prefs.setString('token', result['token'] ?? '');
        await prefs.setInt('id', user['id'] ?? 0);
        await prefs.setString('username', user['username'] ?? '');
        await prefs.setString('nama', user['nama']?.toString() ?? '');
        await prefs.setString('email', user['email'] ?? '');

        String? token = await FirebaseMessaging.instance.getToken();
        print('FCM Token: $token');

        final dataToPrint = {
          'token': result['token'],
          'id': user['id'],
          'username': user['username'],
          'nama': user['nama'],
          'email': user['email'],
        };
        print('LOGIN DATA: ' + dataToPrint.toString());

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login berhasil!')));
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(fromScreen: "login"),
          ),
        );
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Username atau password salah';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/background_login.jpg', fit: BoxFit.cover),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Login',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      // obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        child: const Text('Login'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
