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
  State<PengadaanBarangJasaScreen> createState() =>
      _PengadaanBarangJasaScreenState();
}

class _PengadaanBarangJasaScreenState extends State<PengadaanBarangJasaScreen> {
  String? username, email, nama, userId;
  Map<String, dynamic> beforeActionData = {};
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
    _fetchBeforeAction();
  }

  Future<void> _fetchBeforeAction() async {
    if (userId == null || userId!.isEmpty) return;
    setState(() {
      isLoading = true;
      errorMsg = null;
      beforeActionData = {};
    });
    try {
      final result = await ApiService.beforeAction(userId: int.parse(userId!));
      setState(() {
        beforeActionData = result['data'] ?? {};
      });
    } catch (e) {
      setState(() {
        errorMsg = 'Gagal memuat data: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

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
              _fetchBeforeAction();
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
                if (isLoading)
                  Expanded(
                    child: Center(
                      child: LoadingAnimationWidget.beat(
                        color: Colors.white,
                        size: 80,
                      ),
                    ),
                  )
                else if (errorMsg != null)
                  Expanded(child: Center(child: Text(errorMsg!)))
                else ...[
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
                          Stack(
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.thumb_up,
                                    size: 40,
                                    color: AppColors.orange,
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
                                  onTap: () async {
                                    final result = await Navigator.of(context)
                                        .push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PersetujuanTransaksiScreen(),
                                          ),
                                        );
                                    // Jika kembali dari detail dan result == 'reload', refresh data
                                    if (result == 'reload') {
                                      _fetchBeforeAction();
                                    }
                                  },
                                ),
                              ),
                              if ((beforeActionData['need_validation'] ?? 0) >
                                  0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${beforeActionData['need_validation']}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Stack(
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.check_circle_outline,
                                    size: 40,
                                    color: AppColors.lightblue,
                                  ),
                                  title: const Text(
                                    'Konfirmasi Barang/Jasa tiba & Penyelesaian Transaksi',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: const Text(
                                    'Daftar transaksi yang perlu Anda konfirmasi kedatangan barang/jasa dan menyelesaikan proses transaksi',
                                  ),
                                  onTap: () {
                                    // Navigator.of(context).push(
                                    //   MaterialPageRoute(
                                    //     builder: (context) =>
                                    //         const PersetujuanTransaksiScreen(),
                                    //   ),
                                    // );
                                  },
                                ),
                              ),
                              if ((beforeActionData['need_validation_barangtiba'] ??
                                      0) >
                                  0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${beforeActionData['need_validation_barangtiba']}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Stack(
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.hourglass_empty,
                                    size: 40,
                                    color: AppColors.error,
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
                              if ((beforeActionData['transaksi_gantung'] ?? 0) >
                                  0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${beforeActionData['transaksi_gantung']}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.inventory_2,
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
                                Icons.inventory_2,
                                size: 40,
                                color: AppColors.success,
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
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
