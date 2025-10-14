import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:validator/screens/konfirmasi_screen.dart';
import 'package:validator/screens/setujui_transaksi_screen.dart';
import 'package:validator/utils/appcolors.dart';
import 'package:validator/utils/appstatus.dart';
import 'package:validator/utils/globalvariables.dart';
import 'package:validator/widgets/tabelDaftarBarangDibeli.dart';
import 'package:validator/widgets/tabelDaftarJasaLuar.dart';
import '../services/api_service.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:open_file/open_file.dart';

class DetailButuhKonfirmasiPenyelesaianScreen extends StatefulWidget {
  final int bayarId;
  final int userId;

  const DetailButuhKonfirmasiPenyelesaianScreen({
    Key? key,
    required this.bayarId,
    required this.userId,
  }) : super(key: key);
  @override
  State<DetailButuhKonfirmasiPenyelesaianScreen> createState() =>
      _DetailButuhKonfirmasiPenyelesaianScreenState();
}

class _DetailButuhKonfirmasiPenyelesaianScreenState
    extends State<DetailButuhKonfirmasiPenyelesaianScreen> {
  Map<String, dynamic>? detailData;
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      final result = await ApiService.konfirmasiBarangTibaApproval(
        idBayar: widget.bayarId.toString(),
        userId: widget.userId.toString(),
      );
      if (!mounted) return;
      setState(() {
        detailData = result;
      });
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

  void imageViewer(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.7,
              child: PhotoView(
                imageProvider: NetworkImage(imageUrl),
                backgroundDecoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                loadingBuilder: (context, event) =>
                    Center(child: CircularProgressIndicator()),
              ),
            ),
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Tutup',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void pdfViewer(BuildContext context, String pdfUrl) {
    () async {
      String localPath = pdfUrl;
      if (pdfUrl.startsWith('http')) {
        // Tampilkan loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(child: CircularProgressIndicator()),
        );
        try {
          final dir = await getTemporaryDirectory();
          final fileName = pdfUrl.split('/').last;
          final savePath = '${dir.path}/$fileName';
          await Dio().download(pdfUrl, savePath);
          localPath = savePath;
        } catch (e) {
          print('Gagal mengunduh PDF: $e');
          Navigator.of(context).pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal mengunduh PDF: $e')));
          return;
        }
        Navigator.of(context).pop(); // Tutup loading
      }
      // Tampilkan PDFView dengan file lokal
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(8),
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.7,
            child: PDFView(
              filePath: localPath,
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: true,
              pageFling: true,
              onError: (error) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal memuat PDF: $error')),
                );
              },
              onPageError: (page, error) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal memuat halaman $page: $error')),
                );
              },
            ),
          ),
        ),
      );
    }();
  }

  Future<void> openFile(String filePath) async {
    try {
      await OpenFile.open(filePath);
    } catch (e) {
      print('Gagal membuka file: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuka file: $e')));
    }
  }

  void downloadFile(String url, {String? fileName}) {
    () async {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: LoadingAnimationWidget.beat(color: AppColors.white, size: 60),
        ),
      );
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final dir = await getApplicationDocumentsDirectory();
          final filesDir = Directory('${dir.path}/files');
          if (!await filesDir.exists()) {
            await filesDir.create(recursive: true);
          }
          final saveName = fileName ?? url.split('/').last;
          final file = File('${filesDir.path}/$saveName');
          await file.writeAsBytes(response.bodyBytes);
          if (!mounted) return;
          Navigator.of(context).pop(); // Close loading
          print('Download completed: ${file.path}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Download selesai: Silakan simpan ke folder anda\n${file.path}',
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    tooltip: 'Tutup',
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                  ),
                ],
              ),
              duration: const Duration(seconds: 8),
              action: SnackBarAction(
                label: 'Buka File',
                onPressed: () async {
                  await openFile(file.path);
                },
              ),
            ),
          );
        } else {
          if (!mounted) return;
          Navigator.of(context).pop(); // Close loading
          print('Download error: status ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download error: status ${response.statusCode}'),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        Navigator.of(context).pop(); // Close loading
        print('Download error: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Download error: $e')));
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // mengikuti nama page dari web pengadaan
        title: const Text(
          'Konfirmasi Barang Tiba Approval',
          style: TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _fetchDetail,
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
          isLoading
              ? Center(
                  child: LoadingAnimationWidget.beat(
                    color: Colors.white,
                    size: 80,
                  ),
                )
              : errorMsg != null
              ? Expanded(
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
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            errorMsg ?? 'Error tidak diketahui',
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
                              onTap: _fetchDetail,
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
              : detailData == null
              ? Expanded(
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
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                              onTap: _fetchDetail,
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
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Model Pembelian
                      // Judul Pengadaan Jasa Luar
                      Text(
                        detailData!['model_pembelian']['barang_jasa'] == 1
                            ? 'Data Barang yang dibeli'
                            : 'Data Jasa Luar yang diajukan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (detailData?['model_pembelian'] != null) ...[
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.greyLight,
                              width: 1.2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white, // background putih
                          ),
                          child: Table(
                            border: TableBorder.all(
                              color: AppColors.greyLight,
                              width: 1.2,
                            ),
                            columnWidths: const {
                              0: FlexColumnWidth(1),
                              1: FlexColumnWidth(1),
                            },
                            children: [
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      detailData!['model_pembelian']['barang_jasa'] ==
                                              1
                                          ? 'No PPB (Pembelian Barang)'
                                          : 'No PJL (Jasa Luar)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '${detailData!['model_pembelian']['no_ppb'] ?? '-'}',
                                    ),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Tanggal Pengajuan',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      detailData!['model_pembelian']['tgl_pengajuan'],
                                    ),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Keterangan/Keperluan',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      (detailData!['model_pembelian']['keterangan']
                                                  ?.toString()
                                                  .toLowerCase() ==
                                              'keterangan')
                                          ? '-'
                                          : '${detailData!['model_pembelian']['keterangan'] ?? '-'}',
                                    ),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Email Notifikasi',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '${detailData!['model_pembelian']['email_notifikasi'] ?? '-'}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      detailData!['model_pembelian']['keterangan_databayar'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child:
                                        detailData!['model_pembelian']['tanggal_databayar'] ==
                                            'Belum dilakukan'
                                        ? const Text(
                                            'Belum dilakukan',
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                            ),
                                          )
                                        : Text(
                                            detailData!['model_pembelian']['tanggal_databayar'] ??
                                                '-',
                                            style: const TextStyle(
                                              fontStyle: FontStyle.normal,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Divisi',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '${detailData!['model_pembelian']['nama_divisi'] ?? '-'}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      detailData!['model_pembelian']['barang_jasa'] ==
                                              1
                                          ? 'Status PPB'
                                          : 'Status PJL',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppStatus.getStatusColor(
                                        detailData!['model_pembelian']['status'],
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 8,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '${detailData!['model_pembelian']['keterangan_status'] ?? '-'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textwhite,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Branch',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      detailData!['model_pembelian']['branch'] ==
                                              1
                                          ? 'STT SAAT'
                                          : detailData!['model_pembelian']['branch'] ==
                                                2
                                          ? 'Yayasan SAAT'
                                          : '-',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Data Provider - Daftar Jasa Luar
                      if (detailData?['dataProvider'] != null &&
                          detailData!['dataProvider'] is Map &&
                          detailData!['dataProvider'].isNotEmpty &&
                          detailData!['model_pembelian']['barang_jasa'] ==
                              2) ...[
                        TabelDaftarJasaLuar(
                          detailData: detailData!['dataProvider'],
                        ),
                      ],
                      // // Data Provider - Daftar Barang Dibeli
                      if (detailData?['dataProvider'] != null &&
                          detailData!['dataProvider'] is Map &&
                          detailData!['dataProvider'].isNotEmpty &&
                          detailData!['model_pembelian']['barang_jasa'] ==
                              1) ...[
                        TabelDaftarBarangDibeli(
                          detailData: detailData!['dataProvider'],
                        ),
                      ],
                      // Rekap Pembelian
                      if (detailData?['rekap_pembayaran'] != null) ...[
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 12.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Card(
                                      color: AppColors.background,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.work_outline,
                                              color: AppColors.greyMedium,
                                              size: 32,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              detailData!['rekap_pembayaran']['jenis_jasa'] !=
                                                      null
                                                  ? 'Total Jenis Jasa'
                                                  : 'Total Jenis Barang',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${detailData!['rekap_pembayaran']['jenis_jasa'] ?? detailData!['rekap_pembayaran']['jenis_barang'] ?? '-'}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Card(
                                      color: AppColors.background,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.account_balance_wallet,
                                              color: AppColors.greyMedium,
                                              size: 32,
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              'Total Biaya',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            (() {
                                              final totalBiaya =
                                                  detailData!['rekap_pembayaran']['total_biaya'];
                                              final totalBiayaDatang =
                                                  detailData!['rekap_pembayaran_datang']?['total_biaya'];
                                              if (totalBiaya != null &&
                                                  totalBiayaDatang != null &&
                                                  totalBiaya !=
                                                      totalBiayaDatang) {
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '$totalBiaya',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        decoration:
                                                            TextDecoration
                                                                .lineThrough,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      '$totalBiayaDatang',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              } else {
                                                return Text(
                                                  '${totalBiaya ?? '-'}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                );
                                              }
                                            })(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Card(
                                      color: AppColors.background,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.keyboard_return,
                                              color: AppColors.greyMedium,
                                              size: 32,
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              'Uang Kembali',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${detailData!['rekap_pembayaran']['kembali'] ?? '-'}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Card(
                                      color: AppColors.background,
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.payment,
                                              color: AppColors.greyMedium,
                                              size: 32,
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              'Metode Pembayaran',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${detailData!['rekap_pembayaran']['metode_pembayaran'] ?? '-'}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            // Tambahan info jika metode transfer
                                            if (detailData!['rekap_pembayaran']['metode_pembayaran'] ==
                                                'Transfer') ...[
                                              const SizedBox(height: 4),
                                              ...((detailData!['rekap_pembayaran']['tujuan_transfer'] ??
                                                      '-')
                                                  .toString()
                                                  .split(';')
                                                  .map(
                                                    (line) => Text(
                                                      line.trim(),
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  )
                                                  .toList()),
                                              if (detailData!['rekap_pembayaran']['uang_kembali_transfer'] !=
                                                  null) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Uang Kembali Transfer: ${detailData!['rekap_pembayaran']['uang_kembali_transfer']}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                              if (detailData!['rekap_pembayaran']['biaya_transfer'] !=
                                                  null) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Biaya Transfer: ${detailData!['rekap_pembayaran']['biaya_transfer']}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                              const SizedBox(height: 2),
                                              Text(
                                                'Berita Transfer: ${detailData!['rekap_pembayaran']['berita_transfer'] ?? '-'}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                            // Catatan pembelian darurat
                                            if (detailData!['rekap_pembayaran']['catatan'] !=
                                                null) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                '${detailData!['rekap_pembayaran']['catatan']}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.error,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Data Provider Upload
                      if (detailData?['dataProviderUpload'] != null &&
                          detailData!['dataProviderUpload'] is List &&
                          detailData!['dataProviderUpload'].isNotEmpty) ...[
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          padding: const EdgeInsets.only(top: 10.0),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(40),
                            borderRadius: BorderRadius.circular(8),
                            // border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: const Text(
                                  'Daftar Dokumen Pengajuan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textblack,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                color: Colors.white,
                                child: Table(
                                  border: TableBorder(
                                    top: BorderSide(
                                      color: AppColors.black.withAlpha(80),
                                      width: 1.2,
                                    ),
                                    bottom: BorderSide(
                                      color: AppColors.black.withAlpha(80),
                                      width: 1.2,
                                    ),
                                    left: BorderSide(
                                      color: AppColors.black.withAlpha(80),
                                      width: 1.2,
                                    ),
                                    right: BorderSide(
                                      color: AppColors.black.withAlpha(80),
                                      width: 1.2,
                                    ),
                                    horizontalInside: BorderSide(
                                      color: AppColors.greyLight,
                                      width: 0.8,
                                    ),
                                    verticalInside: BorderSide(
                                      color: AppColors.greyLight,
                                      width: 0.8,
                                    ),
                                  ),
                                  columnWidths: const {
                                    0: FlexColumnWidth(2),
                                    1: FlexColumnWidth(3),
                                    2: FlexColumnWidth(2),
                                  },
                                  children: [
                                    TableRow(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                      ),
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Nama File',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Keterangan',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Aksi',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    ...detailData!['dataProviderUpload'].where((up) => up['tahap'] == 1).map<
                                      TableRow
                                    >((up) {
                                      return TableRow(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                        ),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              // Ambil nama file di belakang dan ubah %20 jadi spasi
                                              (() {
                                                final fullPath =
                                                    up['nama_file'] ?? '-';
                                                if (fullPath == '-' ||
                                                    fullPath == null) {
                                                  return '-';
                                                }
                                                final fileName = fullPath
                                                    .split('/')
                                                    .last
                                                    .replaceAll('%20', ' ');
                                                return fileName;
                                              })(),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${up['keterangan'] ?? '-'}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  'Upload oleh: ${up['upload_by'] ?? '-'}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${up['created_at'] ?? '-'}',
                                                  style: const TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  final fileName =
                                                      up['nama_file']
                                                          ?.toString() ??
                                                      '';
                                                  print(
                                                    '${GlobalVariables.imageUrl}$fileName',
                                                  );
                                                  if (fileName
                                                      .toLowerCase()
                                                      .endsWith('.pdf')) {
                                                    pdfViewer(
                                                      context,
                                                      '${GlobalVariables.imageUrl}$fileName',
                                                    );
                                                  } else {
                                                    imageViewer(
                                                      context,
                                                      '${GlobalVariables.imageUrl}$fileName',
                                                    );
                                                  }
                                                },
                                                child: Container(
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary
                                                        .withAlpha(50),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          8.0,
                                                        ),
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.visibility,
                                                          size: 16,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        const Text(
                                                          'View',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: AppColors
                                                                .primary,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                height: 2,
                                                color: AppColors.greyLight,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  downloadFile(
                                                    '${GlobalVariables.imageUrl}${up['nama_file'] ?? ''}',
                                                  );
                                                },
                                                child: Container(
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary
                                                        .withAlpha(50),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          8.0,
                                                        ),
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.download,
                                                          size: 16,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        const Text(
                                                          'Download',
                                                          style: TextStyle(
                                                            fontSize: 8,
                                                            color: AppColors
                                                                .primary,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                height: 2,
                                                color: AppColors.greyLight,
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              'Tidak Ada Hasil Daftar Dokumen Pengajuan',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],

                      // Data Provider Bayar Upload
                      if (detailData?['dataProviderBayarUpload'] != null &&
                          detailData!['dataProviderBayarUpload'] is List &&
                          detailData!['dataProviderBayarUpload']
                              .isNotEmpty) ...[
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          padding: const EdgeInsets.only(top: 10.0),
                          decoration: BoxDecoration(
                            color: AppColors.orange.withAlpha(60),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: const Text(
                                  'Daftar Dokumen Pertanggung Jawaban',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textblack,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                color: Colors.white,
                                child: Table(
                                  border: TableBorder(
                                    top: BorderSide(
                                      color: AppColors.black.withAlpha(80),
                                      width: 1.2,
                                    ),
                                    bottom: BorderSide(
                                      color: AppColors.black.withAlpha(80),
                                      width: 1.2,
                                    ),
                                    left: BorderSide(
                                      color: AppColors.black.withAlpha(80),
                                      width: 1.2,
                                    ),
                                    right: BorderSide(
                                      color: AppColors.black.withAlpha(80),
                                      width: 1.2,
                                    ),
                                    horizontalInside: BorderSide(
                                      color: AppColors.greyLight,
                                      width: 0.8,
                                    ),
                                    verticalInside: BorderSide(
                                      color: AppColors.greyLight,
                                      width: 0.8,
                                    ),
                                  ),
                                  columnWidths: const {
                                    0: FlexColumnWidth(2),
                                    1: FlexColumnWidth(3),
                                    2: FlexColumnWidth(2),
                                  },
                                  children: [
                                    TableRow(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                      ),
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Nama File',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Keterangan',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Aksi',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    ...detailData!['dataProviderBayarUpload']
                                        .where((up) => up['tahap'] == 2)
                                        .map<TableRow>((up) {
                                          return TableRow(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                            ),
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: Text(
                                                  // Ambil nama file di belakang dan ubah %20 jadi spasi
                                                  (() {
                                                    final fullPath =
                                                        up['nama_file'] ?? '-';
                                                    if (fullPath == '-' ||
                                                        fullPath == null) {
                                                      return '-';
                                                    }
                                                    final fileName = fullPath
                                                        .split('/')
                                                        .last
                                                        .replaceAll('%20', ' ');
                                                    return fileName;
                                                  })(),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${up['keterangan'] ?? '-'}',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    if (up['upload_by'] != null)
                                                      Text(
                                                        'Upload oleh: ${up['upload_by']}',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    if (up['created_at'] !=
                                                        null)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 4,
                                                            ),
                                                        child: Text(
                                                          '${up['created_at']}',
                                                          style:
                                                              const TextStyle(
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                                fontSize: 12,
                                                              ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      final fileName =
                                                          up['nama_file']
                                                              ?.toString() ??
                                                          '';
                                                      print(
                                                        '${GlobalVariables.imageUrl}$fileName',
                                                      );
                                                      if (fileName
                                                          .toLowerCase()
                                                          .endsWith('.pdf')) {
                                                        pdfViewer(
                                                          context,
                                                          '${GlobalVariables.imageUrl}$fileName',
                                                        );
                                                      } else {
                                                        imageViewer(
                                                          context,
                                                          '${GlobalVariables.imageUrl}$fileName',
                                                        );
                                                      }
                                                    },
                                                    child: Container(
                                                      height: 48,
                                                      decoration: BoxDecoration(
                                                        color: AppColors.orange
                                                            .withAlpha(50),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8.0,
                                                            ),
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                              Icons.visibility,
                                                              size: 16,
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            const Text(
                                                              'View',
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color: AppColors
                                                                    .orange,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    height: 2,
                                                    color: AppColors.greyLight,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      downloadFile(
                                                        '${GlobalVariables.imageUrl}${up['nama_file'] ?? ''}',
                                                      );
                                                    },
                                                    child: Container(
                                                      height: 48,
                                                      decoration: BoxDecoration(
                                                        color: AppColors.orange
                                                            .withAlpha(50),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              8.0,
                                                            ),
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                              Icons.download,
                                                              size: 16,
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            const Text(
                                                              'Download',
                                                              style: TextStyle(
                                                                fontSize: 8,
                                                                color: AppColors
                                                                    .orange,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    height: 2,
                                                    color: AppColors.greyLight,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        })
                                        .toList(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              'Tidak Ada Hasil Daftar Dokumen Pertanggung Jawaban',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],

                      // Model Status
                      if (detailData?['model_status'] != null &&
                          detailData!['model_status'] is List &&
                          detailData!['model_status'].isNotEmpty) ...[
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          padding: const EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 12.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...detailData!['model_status'].map<Widget>(
                                (st) => Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: AppColors.greyLight,
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 48,
                                        height: (() {
                                          final status =
                                              st['status']?.toString() ?? '';
                                          final keterangan =
                                              st['keterangan']?.toString() ??
                                              '';
                                          print(
                                            'status length: ${status.length}, keterangan length: ${keterangan.length}',
                                          );
                                          if (status.length <= 25 &&
                                              keterangan.length <= 25) {
                                            return 108.0;
                                          } else if ((status.length > 25 &&
                                                  status.length <= 50) ||
                                              (keterangan.length > 25 &&
                                                  keterangan.length <= 50)) {
                                            return 148.0;
                                          } else if ((status.length > 50 &&
                                                  status.length <= 100) &&
                                              keterangan.length < 25) {
                                            return 132.0;
                                          } else if ((status.length > 50 &&
                                                  status.length <= 100) ||
                                              (keterangan.length > 50 &&
                                                  keterangan.length <= 100)) {
                                            return 148.0;
                                          } else if (status.length > 100 ||
                                              keterangan.length > 100) {
                                            return 172.0;
                                          } else {
                                            return 124.0;
                                          }
                                        })(),
                                        decoration: BoxDecoration(
                                          color: AppStatus.getStatusColor(
                                            st['kode_status'],
                                          ),
                                        ),
                                        child: Icon(
                                          AppStatus.getStatusIcon(
                                            st['kode_status'],
                                          ),
                                          color: Colors.white,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4.0,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${st['status'] ?? '-'}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.access_time,
                                                    size: 14,
                                                    color: Colors.grey,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${st['tanggal_status'] ?? '-'}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '${st['keterangan'] ?? '-'}',
                                                style: const TextStyle(
                                                  fontSize: 14,
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
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => KonfirmasiScreen(
                bayarId: detailData!['model_bayar']['id_bayar'],
                userId: widget.userId,
                barang_jasa: detailData!['model_pembelian']['barang_jasa'],
                no_ppb: detailData!['model_pembelian']['no_ppb'],
                tgl_pengajuan: detailData!['model_pembelian']['tgl_pengajuan'],
                level: 1,
                divisi: detailData!['model_pembelian']['nama_divisi'],
                branch: detailData!['model_pembelian']['branch'],
                id_divisi: detailData!['model_pembelian']['id_divisi'],
                keterangan:
                    (detailData!['model_pembelian']['keterangan']
                            ?.toString()
                            .toLowerCase() ==
                        'keterangan')
                    ? '-'
                    : '${detailData!['model_pembelian']['keterangan'] ?? '-'}',
                total_biaya_rekap_pembayaran:
                    '${detailData!['rekap_pembayaran']['total_biaya'] ?? '-'}',
                total_biaya_rekap_pembayaran_datang:
                    '${detailData!['rekap_pembayaran_datang']['total_biaya'] ?? '-'}',
              ),
            ),
          );
        },
        icon: const Icon(Icons.arrow_forward, color: Colors.white),
        label: const Text(
          'Konfirmasi',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }
}
