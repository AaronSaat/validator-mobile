import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validator/screens/dashboard_screen.dart';
import 'package:validator/screens/detail_butuh_konfirmasi_penyelesaian_screen.dart';
import 'package:validator/screens/login_screen.dart';
import 'package:validator/screens/searching_screen.dart';
import 'package:validator/services/api_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:validator/utils/appstatus.dart';
import '../utils/appcolors.dart';

class ButuhKonfirmasiPenyelesaianScreen extends StatefulWidget {
  final String search;
  const ButuhKonfirmasiPenyelesaianScreen({super.key, this.search = ''});

  @override
  State<ButuhKonfirmasiPenyelesaianScreen> createState() =>
      _ButuhKonfirmasiPenyelesaianScreenState();
}

class _ButuhKonfirmasiPenyelesaianScreenState
    extends State<ButuhKonfirmasiPenyelesaianScreen> {
  String? username, email, nama;
  int userId = 0;
  List<dynamic> butuhKonfirmasiPenyelesaianList = [];
  bool isLoading = true;
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
      userId = prefs.getInt('id') ?? 0;
    });
    _fetchButuhKonfirmasiPenyelesaian();
  }

  Future<void> _fetchButuhKonfirmasiPenyelesaian() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      final result = await ApiService.konfirmasiBarangtiba(
        userId: userId,
        search: widget.search,
      );
      print(result);
      if (result['success'] == true) {
        setState(() {
          butuhKonfirmasiPenyelesaianList = result['dataProvider'] ?? [];
          print(
            'butuhKonfirmasiPenyelesaianList: $butuhKonfirmasiPenyelesaianList ',
          );
        });
      } else {
        setState(() {
          errorMsg = result['message'] ?? 'Failed to fetch data';
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = e.toString();
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
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            final proses = prefs.getString('proses');
            print('SharedPreferences proses dashboard: $proses');
            if (proses == 'reload') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const DashboardScreen(),
                ),
              );
            } else {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
        ),
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
              _fetchButuhKonfirmasiPenyelesaian();
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
                  if (widget.search != "")
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SearchingScreen(
                                fromScreen: 'butuh_konfirmasi_penyelesaian',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(color: AppColors.orange),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                // Icon dan text di ujung kiri
                                const Icon(
                                  Icons.search,
                                  color: AppColors.black,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hasil pencarian untuk:',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.normal,
                                          fontSize: 12,
                                          color: AppColors.textwhite,
                                        ),
                                      ),
                                      Text(
                                        '${widget.search}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppColors.textwhite,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                // Tombol tampil semua di ujung kanan
                                Container(
                                  height: 48,
                                  width: 84,
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ButuhKonfirmasiPenyelesaianScreen(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Tampilkan\nSemua',
                                      style: TextStyle(
                                        color: AppColors.textwhite,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SearchingScreen(
                                fromScreen: 'butuh_konfirmasi_penyelesaian',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 16),
                              const Icon(Icons.search, color: Colors.grey),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Cari Konfirmasi Barang/Jasa & Penyelesaian Transaksi...',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 8.0,
                      left: 16.0,
                      right: 16.0,
                      bottom: 8.0,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Konfirmasi Barang Tiba & Penyelesaian Transaksi',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(color: AppColors.primary),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            // Icon dan text di ujung kiri
                            const Icon(
                              Icons.list_alt,
                              color: AppColors.textwhite,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Showing ${butuhKonfirmasiPenyelesaianList.length} items',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                    color: AppColors.textwhite,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: butuhKonfirmasiPenyelesaianList.length,
                      itemBuilder: (context, index) {
                        final item = butuhKonfirmasiPenyelesaianList[index];
                        return GestureDetector(
                          onTap: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailButuhKonfrimasiPenyelesaianScreen(
                                      bayarId: item['id_bayar'],
                                      userId: userId,
                                    ),
                              ),
                            );
                            // Jika kembali dari detail dan result == true, refresh data
                            if (result == 'reload') {
                              _fetchButuhKonfirmasiPenyelesaian();
                            }
                          },
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.45,
                            child: Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Kotak status di kiri
                                  Container(
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: AppStatus.getStatusColor(
                                        item['status'],
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        bottomLeft: Radius.circular(12),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            AppStatus.getStatusIcon(
                                              item['status'],
                                            ),
                                            color: Colors.white,
                                            size: 32,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            item['status_text'] ?? '-',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Konten utama card
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (item['barang_jasa'] == 1
                                                    ? 'PPB: '
                                                    : 'PJL: ') +
                                                (item['no_ppb'] ?? '-'),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '${item['tgl_uangkeluar'] ?? '-'}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Divisi: ${item['nama_divisi'] ?? '-'}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          Text(
                                            'Nama Pemohon: ${item['nama_pemohon'] ?? '-'}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          Text(
                                            // ignore: prefer_interpolation_to_compose_strings
                                            'Keperluan: ' +
                                                ((item['keperluan']
                                                            ?.toString()
                                                            .toLowerCase() ==
                                                        'keperluan')
                                                    ? '-'
                                                    : (item['keperluan'] ??
                                                          '-')),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Tunai/Transfer:',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          Text(
                                            (item['tunai_transfer'] != null
                                                ? item['tunai_transfer']
                                                      .toString()
                                                      .split(';')
                                                      .join('\n')
                                                : '-'),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            (item['bayar_total'] ?? '-'),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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
