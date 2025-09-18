import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validator/screens/arsip_transaksi_pernah_dikembalikan_oleh_anda_screen.dart';
import 'package:validator/screens/arsip_transaksi_screen.dart';
import 'package:validator/screens/butuh_konfirmasi_penyelesaian_screen.dart';
import 'package:validator/screens/login_screen.dart';
import 'package:validator/screens/butuh_persetujuan_screen.dart';
import 'package:validator/screens/transaksi_gantung_screen.dart';
import 'package:validator/services/api_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../utils/appcolors.dart';
import 'dart:io';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;

class DashboardScreen extends StatefulWidget {
  final String?
  fromScreen; // untuk handle multiple pop context karena ada searching
  const DashboardScreen({super.key, this.fromScreen});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? username, email, nama, userId;
  Map<String, dynamic> beforeActionData = {};
  Map<String, dynamic> siteIndexData = {};
  String? totalDibutuhkan;
  bool isLoading = false;
  String? errorMsg;

  bool isSupported = false;
   bool isNotificationAllowed = false;

  @override
  void initState() {
    super.initState();

    allowNotification();
    AppBadgePlus.isSupported().then((value) {
      isSupported = value;
      setState(() {});
    });

    // Contoh: update badge dari beforeActionData
    Future.delayed(Duration.zero, () async {
      // Simulasi ambil data dari API atau state
      final beforeActionData = {
        'need_validation': 5,
      }; // Ganti dengan data asli Anda
      final badgeCount = beforeActionData['need_validation'] ?? 0;
      AppBadgePlus.updateBadge(badgeCount);
      print('AppBadgePlus isSupported: $isSupported, count: $badgeCount');
    });

    // untuk handle multiple pop context karena ada searching
    print('SharedPreferences proses: fromScreen: ${widget.fromScreen}');
    if (widget.fromScreen == 'login') {
      _loadUserInfo();
    }
    SharedPreferences.getInstance().then((prefs) {
      final proses = prefs.getString('proses');
      print('SharedPreferences proses dashboard: ${proses}');
      if (proses == 'reload') {
        _loadUserInfo();
      }
    });
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
    _fetchSiteIndex();

    // untuk handle multiple pop context karena ada searching
    await prefs.setString('proses', '');
    print(
      'SharedPreferences proses setelah loadUserInfo: ${prefs.getString('proses')}',
    );
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

  Future<void> _fetchSiteIndex() async {
    if (userId == null || userId!.isEmpty) return;
    setState(() {
      isLoading = true;
      errorMsg = null;
      siteIndexData = {};
    });
    try {
      final result = await ApiService.siteIndex(userId: int.parse(userId!));
      setState(() {
        siteIndexData = result;
        print('siteIndexData: $siteIndexData');
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

  String getTanggalPengajuanHariIni() {
    final now = DateTime.now();
    return DateFormat('yyyy/MM/dd').format(now);
  }

  String getTanggalPengajuan2BulanSebelumnya() {
    final now = DateTime.now();
    final duaBulanSebelum = DateTime(now.year, now.month - 2, now.day);
    return DateFormat('yyyy/MM/dd').format(duaBulanSebelum);
  }

  void allowNotification() async {
    if (Platform.isAndroid || Platform.isIOS) {
      if (await permission_handler.Permission.notification.isGranted) {
        isNotificationAllowed = true;
        setState(() {});
      } else {
        await permission_handler.Permission.notification.request().then((value) {
          if (value.isGranted) {
            isNotificationAllowed = true;
            setState(() {});
            print('Permission is granted');
          } else {
            print('Permission is not granted');
            isNotificationAllowed = false;
            setState(() {});
          }
        });
      }
    } else {
      print('This platform is not supported for notification permissions.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tglPengajuan = getTanggalPengajuanHariIni();
    final tglPengajuanAkhir = getTanggalPengajuan2BulanSebelumnya();
    print('tglPengajuan: $tglPengajuan, tglPengajuanAkhir: $tglPengajuanAkhir');
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
              isLoading = true;
              _loadUserInfo();
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
            child: SingleChildScrollView(
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
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: 1.6,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          children: [
                            // 1
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    'assets/cards/yellow.png',
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                    title: Text(
                                      '\n',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 8,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                    subtitle: const Text(
                                      'Butuh \nPersetujuan',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black54,
                                            offset: Offset(1, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                    onTap: () async {
                                      final result = await Navigator.of(context)
                                          .push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ButuhPersetujuanScreen(),
                                            ),
                                          );
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
                            // 2
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    'assets/cards/blue.png',
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                    title: Text(
                                      '\n',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 8,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                    subtitle: const Text(
                                      'Butuh Konfirmasi Penyelesaian',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black54,
                                            offset: Offset(1, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ButuhKonfirmasiPenyelesaianScreen(),
                                        ),
                                      );
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
                            // 3
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    'assets/cards/red.png',
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                    title: Text(
                                      '\n',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 8,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                    subtitle: const Text(
                                      'Transaksi\nGantung',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black54,
                                            offset: Offset(1, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              TransaksiGantungScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                if ((beforeActionData['transaksi_gantung'] ??
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
                            // 4
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    'assets/cards/green.png',
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                    title: Text(
                                      '\n',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 8,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                    subtitle: const Text(
                                      'Arsip\nTransaksi',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black54,
                                            offset: Offset(1, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ArsipTransaksiScreen(
                                                search: '',
                                                tglPengajuan: tglPengajuan,
                                                tglPengajuanAkhir:
                                                    tglPengajuanAkhir,
                                                jenis: 'Semua',
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            // 5
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    'assets/cards/green.png',
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.only(
                                      left: 8,
                                      right: 8,
                                      top: 18,
                                      bottom: 8,
                                    ),
                                    subtitle: const Text(
                                      'Arsip Transaksi\nPernah Dikembalikan\noleh Anda',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black54,
                                            offset: Offset(1, 1),
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.end,
                                    ),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ArsipTransaksiPernahDikembalikanOlehAndaScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: SizedBox(
                        height: 400,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                const Text(
                                  'Total Pengeluaran 6 Bulan Terakhir',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textblack,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: LineChart(
                                    LineChartData(
                                      gridData: FlGridData(show: true),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 60,
                                            getTitlesWidget: (value, meta) {
                                              final formatted =
                                                  NumberFormat.decimalPattern(
                                                    'id',
                                                  ).format(value.round());
                                              return Text(
                                                formatted,
                                                style: const TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 10,
                                                ),
                                                textAlign: TextAlign.right,
                                              );
                                            },
                                          ),
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: true,
                                            reservedSize: 32,
                                            getTitlesWidget: (value, meta) {
                                              // Tampilkan angka bulan sebagai label
                                              return Text(
                                                value.toInt().toString(),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        topTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                        rightTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            showTitles: false,
                                          ),
                                        ),
                                      ),
                                      borderData: FlBorderData(show: true),
                                      minX:
                                          (siteIndexData['data_rekap']?['pengeluaran_bulan_6bulan']
                                                      as List?)
                                                  ?.isNotEmpty ==
                                              true
                                          ? ((siteIndexData['data_rekap']?['pengeluaran_bulan_6bulan']
                                                            as List)
                                                        .first
                                                    as num)
                                                .toDouble()
                                          : 0,
                                      maxX:
                                          (siteIndexData['data_rekap']?['pengeluaran_bulan_6bulan']
                                                      as List?)
                                                  ?.isNotEmpty ==
                                              true
                                          ? ((siteIndexData['data_rekap']?['pengeluaran_bulan_6bulan']
                                                            as List)
                                                        .last
                                                    as num)
                                                .toDouble()
                                          : 12,
                                      minY: 0,
                                      maxY:
                                          (siteIndexData['data_rekap']?['pengeluaran_total_6bulan']
                                                  as List?)
                                              ?.reduce((a, b) => a > b ? a : b)
                                              ?.toDouble() ??
                                          10,
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: (() {
                                            final xList =
                                                siteIndexData['data_rekap']?['pengeluaran_bulan_6bulan']
                                                    as List? ??
                                                [];
                                            final yList =
                                                siteIndexData['data_rekap']?['pengeluaran_total_6bulan']
                                                    as List? ??
                                                [];
                                            final length =
                                                xList.length < yList.length
                                                ? xList.length
                                                : yList.length;
                                            return List.generate(length, (i) {
                                              final x = xList[i] is num
                                                  ? (xList[i] as num).toDouble()
                                                  : double.tryParse(
                                                          xList[i].toString(),
                                                        ) ??
                                                        i.toDouble();
                                              final y = yList[i] is num
                                                  ? (yList[i] as num).toDouble()
                                                  : double.tryParse(
                                                          yList[i].toString(),
                                                        ) ??
                                                        0;
                                              return FlSpot(x, y);
                                            });
                                          })(),
                                          isCurved: false,
                                          color: AppColors.primary,
                                          barWidth: 3,
                                          dotData: FlDotData(show: true),
                                          belowBarData: BarAreaData(
                                            show: true,
                                            color: AppColors.primary.withAlpha(
                                              30,
                                            ), // warna fill area di bawah garis
                                          ),
                                        ),
                                      ],
                                      // Tambahkan touch callback untuk detail saat ditekan
                                      lineTouchData: LineTouchData(
                                        touchTooltipData: LineTouchTooltipData(
                                          getTooltipColor: (touchedSpot) =>
                                              AppColors.primary,
                                          getTooltipItems: (touchedSpots) {
                                            return touchedSpots.map((spot) {
                                              final bulan = spot.x.toInt();
                                              final nominal = spot.y;
                                              return LineTooltipItem(
                                                'Bulan: $bulan\nTotal: ${NumberFormat.currency(locale: 'id', symbol: 'Rp ').format(nominal)}',
                                                const TextStyle(
                                                  color: AppColors.textwhite,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              );
                                            }).toList();
                                          },
                                        ),
                                        handleBuiltInTouches: true,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Angka bulan tahun 2025',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textblack,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Klik dan tahan pada titik atau garis vertikal data untuk melihat detail',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textblack,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
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
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 16.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.receipt_long,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Total Pengeluaran ${siteIndexData['data_rekap']?['bulan_tahun']}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Center(
                                child: Text(
                                  siteIndexData['data_rekap']?['pengeluaran_total_bulan_ini']
                                          ?.toString() ??
                                      'Rp. 0',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const Divider(
                                color: Colors.white,
                                thickness: 1,
                                height: 32,
                              ),
                              // Tanpa scroll, gunakan Wrap dan Expanded
                              if (siteIndexData['data_rekap'] != null &&
                                  siteIndexData['data_rekap']['pengeluaran_per_divisi_bulan_ini'] !=
                                      null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Expanded(
                                    child: Wrap(
                                      runSpacing: 4,
                                      children:
                                          (siteIndexData['data_rekap']['pengeluaran_per_divisi_bulan_ini']
                                                  as List)
                                              .map<Widget>(
                                                (item) => Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 2.0,
                                                      ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          item['divisi']
                                                                  ?.toString() ??
                                                              '',
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize: 14,
                                                              ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      Text(
                                                        item['total']
                                                                ?.toString() ??
                                                            '0',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                              .toList(),
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
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 16.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.battery_6_bar,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Total Transaksi Tunai Gantung',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Center(
                                child: Text(
                                  siteIndexData['data_rekap']?['transaksi_gantung_total']
                                          ?.toString() ??
                                      'Rp. 0',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const Divider(
                                color: Colors.white,
                                thickness: 1,
                                height: 32,
                              ),
                              // Tanpa scroll, gunakan Wrap dan Expanded
                              if (siteIndexData['data_rekap'] != null &&
                                  siteIndexData['data_rekap']['pengeluaran_gantung_per_divisi_bulan_ini'] !=
                                      null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Expanded(
                                    child: Wrap(
                                      runSpacing: 4,
                                      children:
                                          (siteIndexData['data_rekap']['pengeluaran_gantung_per_divisi_bulan_ini']
                                                  as List)
                                              .map<Widget>(
                                                (item) => Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 2.0,
                                                      ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          item['divisi']
                                                                  ?.toString() ??
                                                              '',
                                                          style:
                                                              const TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize: 14,
                                                              ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      Text(
                                                        item['total']
                                                                ?.toString() ??
                                                            '0',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
