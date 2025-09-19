import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validator/screens/dashboard_screen.dart';
import 'package:validator/screens/login_screen.dart';
import 'package:validator/screens/searching_screen.dart';
import 'package:validator/services/api_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:validator/utils/appstatus.dart';
import '../utils/appcolors.dart';

class ArsipTransaksiScreen extends StatefulWidget {
  final String jenis;
  final String tglPengajuan;
  final String tglPengajuanAkhir;
  final String search;
  const ArsipTransaksiScreen({
    super.key,
    this.jenis = '',
    this.tglPengajuan = '',
    this.tglPengajuanAkhir = '',
    this.search = '',
  });

  @override
  State<ArsipTransaksiScreen> createState() => _ArsipTransaksiScreenState();
}

class _ArsipTransaksiScreenState extends State<ArsipTransaksiScreen> {
  String? username, email, nama;
  int userId = 0;
  List<dynamic> ArsipTransaksiList = [];
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    print('Loading user info from SharedPreferences');
    print('widget.tglPengajuan: ${widget.tglPengajuan}');
    print('widget.tglPengajuanAkhir: ${widget.tglPengajuanAkhir}');
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
      email = prefs.getString('email') ?? '';
      nama = prefs.getString('nama') ?? '';
      userId = prefs.getInt('id') ?? 0;
    });
    _fetchArsipTransaksi();
  }

  Future<void> _fetchArsipTransaksi() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      final result = await ApiService.arsipTransaksi(
        userId: userId,
        jenis: widget.jenis,
        tgl_pengajuan: widget.tglPengajuan,
        tgl_pengajuan_akhir: widget.tglPengajuanAkhir,
        search: widget.search,
      );
      print(result);
      if (result['success'] == true) {
        setState(() {
          ArsipTransaksiList = result['dataProvider'] ?? [];
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

  String formatTanggal(String tanggal) {
    if (tanggal.isEmpty) return '-';
    try {
      // Ganti '/' dengan '-' agar bisa diparse oleh DateTime.parse
      String formatted = tanggal.replaceAll('/', '-');
      DateTime dt = DateTime.parse(formatted);

      // Format ke "dd MMMM yyyy"
      return '${dt.day.toString().padLeft(2, '0')} ${namaBulan(dt.month)} ${dt.year}';
    } catch (e) {
      return tanggal;
    }
  }

  String namaBulan(int bulan) {
    const bulanList = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return bulanList[bulan - 1];
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
              _fetchArsipTransaksi();
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
                                fromScreen: 'arsip_transaksi',
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
                                              const ArsipTransaksiScreen(),
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
                                fromScreen: 'arsip_transaksi',
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
                                color: Colors.grey.withAlpha(20),
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
                                  'Filter Pencarian Arsip Transaksi',
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
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 8.0,
                          left: 16.0,
                          right: 16.0,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Transaksi Pembelian ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
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
                          decoration: BoxDecoration(color: AppColors.lightblue),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                // Icon dan text di ujung kiri
                                const Icon(
                                  Icons.calendar_today,
                                  color: AppColors.textwhite,
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Menampilkan tanggal:',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: AppColors.textwhite,
                                      ),
                                    ),
                                    Text(
                                      '${formatTanggal(widget.tglPengajuan)} - ${formatTanggal(widget.tglPengajuanAkhir)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: AppColors.textwhite,
                                      ),
                                    ),
                                    Text(
                                      'Jenis Pembayaran: ${widget.jenis}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(color: AppColors.success),
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
                                      'Showing ${ArsipTransaksiList.length} items',
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
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: ArsipTransaksiList.length,
                      itemBuilder: (context, index) {
                        final item = ArsipTransaksiList[index];
                        return GestureDetector(
                          onTap: () async {
                            // final result = await Navigator.of(context).push(
                            //   MaterialPageRoute(
                            //     builder: (context) => DetailArsipTransaksiScreen(
                            //       pembelianId: item['id_pembelian'],
                            //       userId: userId,
                            //     ),
                            //   ),
                            // );
                            // // Jika kembali dari detail dan result == true, refresh data
                            // if (result == 'reload') {
                            //   _fetchArsipTransaksi();
                            // }
                          },
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.4,
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
                                          const SizedBox(height: 4),
                                          Text(
                                            item['tgl_uangkeluar'] ?? '-',
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
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          if (item['selisih_bayar'] == null)
                                            Text(
                                              (item['bayar_total'] ?? '-'),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          else
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: AppColors.error,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withAlpha(20),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    (item['bayar_total'] ??
                                                        '-'),
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                      decorationColor:
                                                          Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    (item['bayar_realisasi'] ??
                                                        '-'),
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  const Text(
                                                    'Uang kembali:',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    (item['selisih_bayar'] ??
                                                        '-'),
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
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
