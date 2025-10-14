import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validator/screens/dashboard_screen.dart';
import 'package:validator/screens/detail_butuh_persetujuan_screen.dart';
import 'package:validator/screens/searching_screen.dart';
import 'package:validator/services/api_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:validator/utils/appstatus.dart';

import '../utils/appcolors.dart';
import 'profile_screen.dart';

class ButuhPersetujuanScreen extends StatefulWidget {
  final String search;
  const ButuhPersetujuanScreen({super.key, this.search = ''});

  @override
  State<ButuhPersetujuanScreen> createState() => _ButuhPersetujuanScreenState();
}

class _ButuhPersetujuanScreenState extends State<ButuhPersetujuanScreen> {
  String? username, email, nama;
  int userId = 0;
  List<dynamic> persetujuanList = [];
  String? totalDibutuhkan;
  bool isLoading = true;
  String? errorMsg;
  int page = 1;
  int totalPages = 1;
  String paginationInfo = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      username = prefs.getString('username') ?? '';
      email = prefs.getString('email') ?? '';
      nama = prefs.getString('nama') ?? '';
      userId = prefs.getInt('id') ?? 0;
    });
    _fetchPersetujuan();
  }

  Future<void> _fetchPersetujuan() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      final result = await ApiService.persetujuan(
        userId: userId,
        search: widget.search,
        page: page,
      );
      if (result['success'] == true) {
        if (!mounted) return;
        setState(() {
          persetujuanList = result['data'] ?? [];
          totalDibutuhkan = result['total_dibutuhkan'] ?? '';
          // Ambil totalPages dari API jika ada, fallback 1
          totalPages = result['total_pages'] != null
              ? int.tryParse(result['total_pages'].toString()) ?? 1
              : 1;
          paginationInfo = result['pagination_info'] ?? '';
        });
      } else {
        if (!mounted) return;
        setState(() {
          errorMsg = result['message'] ?? 'Failed to fetch data';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMsg = e.toString();
      });
    } finally {
      if (!mounted) return;
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
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
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
                  const Icon(
                    Icons.account_circle,
                    color: Colors.black,
                    size: 32,
                  ),
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
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            tooltip: 'Refresh',
            onPressed: () {
              _fetchPersetujuan();
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
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/no_data.png',
                            width: 128,
                            height: 128,
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Text(
                              errorMsg ?? 'Tidak ada data',
                              style: const TextStyle(
                                color: AppColors.textblack,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: 48,
                            child: Material(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: _fetchPersetujuan,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.refresh, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Muat Ulang',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
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
                                fromScreen: 'butuh_persetujuan',
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
                                              const ButuhPersetujuanScreen(),
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
                                fromScreen: 'butuh_persetujuan',
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
                                  'Cari PPB/PJL Butuh Persetujuan...',
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Total Dibutuhkan',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              totalDibutuhkan ?? '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: AppColors.textblack,
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
                        'Transaksi yang butuh divalidasi',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  // Pagination preview box with iOS-style arrows
                  persetujuanList.isEmpty
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Row(
                            children: [
                              // Left arrow
                              Container(
                                height: 44,
                                width: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.15),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                  ),
                                  onPressed: page > 1
                                      ? () {
                                          setState(() {
                                            page--;
                                          });
                                          _fetchPersetujuan();
                                        }
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Middle: showing items & page info
                              Expanded(
                                child: Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.15),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.list_alt,
                                          color: AppColors.textwhite,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '$paginationInfo',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 12,
                                            color: AppColors.textwhite,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Right arrow
                              Container(
                                height: 44,
                                width: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.15),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Colors.white,
                                  ),
                                  onPressed: page < totalPages
                                      ? () {
                                          setState(() {
                                            page++;
                                          });
                                          _fetchPersetujuan();
                                        }
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                  Expanded(
                    child: (persetujuanList.isEmpty)
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/no_data.png',
                                  width: 128,
                                  height: 128,
                                ),
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: const Text(
                                    'Tidak ada data persetujuan',
                                    style: TextStyle(
                                      color: AppColors.textblack,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  height: 48,
                                  child: Material(
                                    color: AppColors.success,
                                    borderRadius: BorderRadius.circular(8),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: _fetchPersetujuan,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(
                                            Icons.refresh,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Muat Ulang',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: persetujuanList.length,
                            itemBuilder: (context, index) {
                              final item = persetujuanList[index];
                              return GestureDetector(
                                onTap: () async {
                                  final result = await Navigator.of(context)
                                      .push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DetailButuhPersetujuanScreen(
                                                pembelianId:
                                                    item['id_pembelian'],
                                                userId: userId,
                                              ),
                                        ),
                                      );
                                  // Jika kembali dari detail dan result == true, refresh data
                                  if (result == 'reload') {
                                    _fetchPersetujuan();
                                  }
                                },
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height * 0.27,
                                  child: Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Kotak status di kiri
                                        Container(
                                          width: 100,
                                          decoration: BoxDecoration(
                                            color: AppStatus.getStatusColor(
                                              item['status'],
                                            ),
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topLeft: Radius.circular(12),
                                                  bottomLeft: Radius.circular(
                                                    12,
                                                  ),
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
                                                  item['nama_status'] ?? '-',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
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
                                                  // ignore: prefer_interpolation_to_compose_strings
                                                  '${((page - 1) * 10 + index + 1)}. ' +
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
                                                  'Divisi: ${item['nama_divisi'] ?? '-'}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                                Text(
                                                  'Nama Pemohon: ${item['nama_pemohon'] ?? '-'}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                                Text(
                                                  // ignore: prefer_interpolation_to_compose_strings
                                                  'Keterangan/Keperluan: ' +
                                                      ((item['keterangan']
                                                                  ?.toString()
                                                                  .toLowerCase() ==
                                                              'keterangan')
                                                          ? '-'
                                                          : (item['keterangan'] ??
                                                                '-')),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  (item['total_biaya'] ?? '-'),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                if (item['branch'] == 1)
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: const Text(
                                                      'Branch: STT SAAT',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  )
                                                else if (item['branch'] == 2)
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: const Text(
                                                      'Branch: Yayasan SAAT',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
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
