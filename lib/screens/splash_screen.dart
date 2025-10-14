import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validator/screens/butuh_konfirmasi_penyelesaian_screen.dart';
import 'package:validator/screens/dashboard_screen.dart';
import 'package:validator/screens/butuh_persetujuan_screen.dart';
import 'package:validator/screens/detail_butuh_konfirmasi_penyelesaian_screen.dart';
import 'package:validator/screens/detail_butuh_persetujuan_screen.dart';
import 'package:validator/screens/login_screen.dart';
import 'package:validator/services/api_service.dart';
import 'package:validator/utils/appcolors.dart'; // Pastikan path ini sesuai

class SplashScreen extends StatefulWidget {
  final bool fromNotification;
  final String? tujuan;
  final int? id;
  final int? userId;
  const SplashScreen({
    Key? key,
    this.fromNotification = false,
    this.tujuan,
    this.id,
    this.userId,
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _startValidation();
  }

  Future<void> _startValidation() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    // Cek token di SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }
    // Jika ada token, validasi ke API
    final result = await ApiService.validateUser();
    if (!mounted) return;
    bool isValid = result['success']; // Adjust the key if needed
    if (isValid) {
      // Jika dari notifikasi, arahkan ke tujuan
      print('Navigating: valid user');
      print('Navigating: widget.fromNotification = ${widget.fromNotification}');
      if (widget.fromNotification) {
        print('Navigating from notification');
        if (widget.tujuan == 'butuh_persetujuan') {
          print('Navigating to Dashboard Screen');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  const DashboardScreen(fromScreen: "splash_screen"),
            ),
          );
          print('Navigating to Butuh Persetujuan Screen');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const ButuhPersetujuanScreen(),
            ),
          );
        } else if (widget.tujuan == 'detail_butuh_persetujuan') {
          print('Navigating to Dashboard Screen');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  const DashboardScreen(fromScreen: "splash_screen"),
            ),
          );
          print('Navigating to Butuh Persetujuan Screen');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const ButuhPersetujuanScreen(),
            ),
          );
          print('Navigating to Detail Butuh Persetujuan Screen');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DetailButuhPersetujuanScreen(
                pembelianId: widget.id ?? 0,
                userId: widget.userId ?? 0,
              ),
            ),
          );
        } else if (widget.tujuan == 'butuh_konfirmasi_penyelesaian') {
          print('Navigating to Dashboard Screen');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  const DashboardScreen(fromScreen: "splash_screen"),
            ),
          );
          print('Navigating to Butuh Konfirmasi Screen');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const ButuhKonfirmasiPenyelesaianScreen(),
            ),
          );
        } else if (widget.tujuan == 'detail_butuh_konfirmasi_penyelesaian') {
          print('Navigating to Dashboard Screen');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  const DashboardScreen(fromScreen: "splash_screen"),
            ),
          );
          print('Navigating to Butuh Konfirmasi Screen');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const ButuhKonfirmasiPenyelesaianScreen(),
            ),
          );
          print('Navigating to Detail Butuh Konfirmasi Screen');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DetailButuhKonfirmasiPenyelesaianScreen(
                bayarId: widget.id ?? 0,
                userId: widget.userId ?? 0,
              ),
            ),
          );
        } else {
          print('Navigating to Dashboard Screen');
          // Default: ke dashboard
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  const DashboardScreen(fromScreen: "splash_screen"),
            ),
          );
        }
      } else {
        print('Navigating not from notification');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) =>
                const DashboardScreen(fromScreen: "splash_screen"),
          ),
        );
      }
    } else {
      print('Navigating: invalid user');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: AppColors.baseBackground,
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/app_icon_splash.png',
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sistem Pengadaan SAAT',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Validator Mobile',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
