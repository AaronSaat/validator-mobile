import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validator/screens/login_screen.dart';
import 'package:validator/services/api_service.dart';
import 'package:validator/utils/appcolors.dart';

class DeleteAccountScreen extends StatefulWidget {
  final int userId; // Tambahkan parameter userId
  final String userName;
  final String userEmail;

  const DeleteAccountScreen({
    Key? key,
    required this.userId, // Tambahkan required userId
    required this.userName,
    required this.userEmail,
  }) : super(key: key);

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  bool _isAgreed = false;

  Future<void> _onDeletePressed() async {
    try {
      // 1. Panggil API hapus user
      final result = await ApiService.deleteUser(userId: '${widget.userId}');
      if (result['success'] == true) {
        // 2. Hapus semua data di SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        prefs.clear();
        // 3. Unsubscribe FCM topic
        FirebaseMessaging.instance.unsubscribeFromTopic('validator');
        // 4. Tampilkan pesan sukses dan arahkan ke login
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Akun berhasil dihapus.')),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Gagal menghapus akun.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus akun: $e')));
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Hapus Akun', style: TextStyle(color: Colors.black)),
      ),
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: AppColors.baseBackground,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(widget.userName),
                  const SizedBox(height: 4),
                  Text(widget.userEmail),
                  const SizedBox(height: 24),
                  const Text(
                    'Dengan menghapus akun, semua data Anda terkait dengan aplikasi yaitu informasi perangkat dari user akan dihapus secara permanen dan tidak dapat dikembalikan.\n\nPastikan Anda sudah yakin sebelum melanjutkan.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Checkbox(
                        value: _isAgreed,
                        onChanged: (value) {
                          setState(() {
                            _isAgreed = value ?? false;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'Saya setuju untuk menghapus akun saya secara permanen.',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: StatefulBuilder(
                      builder: (context, setStateBtn) {
                        bool _isLoading = false;
                        return TextButton(
                          onPressed: (_isAgreed && !_isLoading)
                              ? () async {
                                  setStateBtn(() => _isLoading = true);
                                  await _onDeletePressed();
                                  if (mounted)
                                    setStateBtn(() => _isLoading = false);
                                }
                              : null,
                          style: TextButton.styleFrom(
                            backgroundColor: (_isAgreed && !_isLoading)
                                ? Colors.red
                                : Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Hapus Akun',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
