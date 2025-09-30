import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validator/screens/dashboard_screen.dart';
import 'package:validator/screens/butuh_persetujuan_screen.dart';
import 'package:validator/services/api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:validator/utils/appcolors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
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

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(fromScreen: "login"),
          ),
        );
      } else {
        setState(() {
          // _errorMessage = result['message'] ?? 'Username atau password salah';
          _errorMessage = 'Username atau password salah';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: AppColors.baseBackground,
          ),
          // Image.asset('assets/images/background_login.jpg', fit: BoxFit.cover),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          child: Stack(
                            children: [
                              Image.asset(
                                'assets/images/bg-01.jpg',
                                height: 140,
                                fit: BoxFit.cover,
                              ),
                              Container(
                                height: 140,
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.withAlpha(80),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'SISTEM PENGADAAN SAAT\nAPLIKASI VALIDATOR',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                shadows: [
                                  Shadow(
                                    blurRadius: 8,
                                    color: Colors.black,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FocusScope(
                              child: Column(
                                children: [
                                  TextField(
                                    controller: _usernameController,
                                    focusNode: _usernameFocusNode,
                                    style: const TextStyle(
                                      color: AppColors.textGrey,
                                    ),
                                    decoration: const InputDecoration(
                                      labelText: 'Masukkan Username',
                                      labelStyle: TextStyle(
                                        color: AppColors.textGrey,
                                      ),
                                      border: UnderlineInputBorder(),
                                    ),
                                    textInputAction: TextInputAction.next,
                                    onSubmitted: (_) {
                                      FocusScope.of(
                                        context,
                                      ).requestFocus(_passwordFocusNode);
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocusNode,
                                    obscureText: _obscureText,
                                    style: const TextStyle(
                                      color: AppColors.textGrey,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'Masukkan Password',
                                      labelStyle: const TextStyle(
                                        color: AppColors.textGrey,
                                      ),
                                      border: const UnderlineInputBorder(),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureText
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: AppColors.textGrey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureText = !_obscureText;
                                          });
                                        },
                                      ),
                                    ),
                                    textInputAction: TextInputAction.done,
                                  ),
                                ],
                              ),
                            ),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                _errorMessage!,
                                style: const TextStyle(color: AppColors.error),
                              ),
                            ],
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 48,
                              width: MediaQuery.of(context).size.width * 0.3,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.orange,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: _login,
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textwhite,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
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
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}
