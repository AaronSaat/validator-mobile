import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validator/screens/detail_ppb_pjl_screen.dart';
import 'package:validator/screens/login_screen.dart';
import 'package:validator/screens/persetujuan_transaksi_screen.dart';
import 'package:validator/services/api_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../utils/appcolors.dart';

class PengadaanBarangJasaScreen extends StatefulWidget {
  const PengadaanBarangJasaScreen({super.key});

  @override
  State<PengadaanBarangJasaScreen> createState() => _PengadaanBarangJasaScreenState();
}

class _PengadaanBarangJasaScreenState extends State<PengadaanBarangJasaScreen> {
  String? username, email, nama, userId;
  List<dynamic> persetujuanList = [];
  String? totalDibutuhkan;
  bool isLoading = false;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
      email = prefs.getString('email') ?? '';
      nama = prefs.getString('nama') ?? '';
      userId = prefs.getInt('id')?.toString() ?? '';
    });
    _fetchPersetujuan();
  }

  Future<void> _fetchPersetujuan() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 16),
                const Icon(Icons.account_circle, color: Colors.black, size: 32),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    username ?? '',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            tooltip: 'Refresh',
            onPressed: () {
              _fetchPersetujuan();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: AppColors.baseBackground,
          ),
          // Positioned(
          //   child: Image.asset(
          //     'assets/images/background_login.jpg',
          //     width: MediaQuery.of(context).size.width,
          //     height: MediaQuery.of(context).size.height,
          //     fit: BoxFit.fill,
          //   ),
          // ),
          SafeArea(
            child: Column(
              children: [
                // if (isLoading)
                //   Expanded(
                //     child: Center(
                //       child: LoadingAnimationWidget.beat(
                //         color: Colors.white,
                //         size: 80,
                //       ),
                //     ),
                //   )
                // else if (errorMsg != null)
                //   Expanded(child: Center(child: Text(errorMsg!)))
                // else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.assignment_turned_in,
                                size: 40,
                                color: AppColors.primary,
                              ),
                              title: const Text(
                                'PPB/PJL Butuh Persetujuan',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: const Text(
                                'Daftar transaksi yang menunggu persetujuan Anda',
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const PersetujuanTransaksiScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.hourglass_empty,
                                size: 40,
                                color: AppColors.orange,
                              ),
                              title: const Text(
                                'Transaksi Gantung',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: const Text(
                                'Transaksi yang belum selesai prosesnya',
                              ),
                              onTap: () {
                                // TODO: Navigasi ke halaman transaksi gantung
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.archive,
                                size: 40,
                                color: AppColors.success,
                              ),
                              title: const Text(
                                'Arsip PPB/PJL',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: const Text(
                                'Riwayat transaksi yang sudah selesai',
                              ),
                              onTap: () {
                                // TODO: Navigasi ke halaman arsip
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.undo,
                                size: 40,
                                color: AppColors.error,
                              ),
                              title: const Text(
                                'Arsip PPB/PJL dikembalikan oleh anda',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: const Text(
                                'Transaksi yang Anda kembalikan ke pengusul',
                              ),
                              onTap: () {
                                // TODO: Navigasi ke halaman arsip dikembalikan
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
