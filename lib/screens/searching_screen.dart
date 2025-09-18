import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:validator/screens/arsip_transaksi_pernah_dikembalikan_oleh_anda_screen.dart';
import 'package:validator/screens/arsip_transaksi_screen.dart';
import 'package:validator/screens/butuh_konfirmasi_penyelesaian_screen.dart';
import 'package:validator/screens/butuh_persetujuan_screen.dart';
import 'package:validator/screens/transaksi_gantung_screen.dart';
import 'package:validator/utils/appcolors.dart';
import 'package:date_picker_plus/date_picker_plus.dart';

class SearchingScreen extends StatefulWidget {
  final String fromScreen;
  const SearchingScreen({super.key, required this.fromScreen});

  @override
  State<SearchingScreen> createState() => _SearchingScreenState();
}

class _SearchingScreenState extends State<SearchingScreen> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? _tanggalAwal;
  DateTime? _tanggalAkhir;
  String _selectedFilter = 'Semua';
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    print('Dari layar: ${widget.fromScreen}');
    // Open keyboard automatically selain arsip_transaksi
    if (widget.fromScreen != 'arsip_transaksi') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_focusNode);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String query) {
    if (widget.fromScreen == 'butuh_persetujuan') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              ButuhPersetujuanScreen(search: _searchController.text),
        ),
      );
    } else if (widget.fromScreen == 'transaksi_gantung') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              TransaksiGantungScreen(search: _searchController.text),
        ),
      );
    } else if (widget.fromScreen == 'butuh_konfirmasi_penyelesaian') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              ButuhKonfirmasiPenyelesaianScreen(search: _searchController.text),
        ),
      );
    } else if (widget.fromScreen == 'arsip_transaksi') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ArsipTransaksiScreen(
            search: _searchController.text,
            tglPengajuan: _tanggalAwal != null
                ? DateFormat('yyyy/MM/dd').format(_tanggalAwal!)
                : '',
            tglPengajuanAkhir: _tanggalAkhir != null
                ? DateFormat('yyyy/MM/dd').format(_tanggalAkhir!)
                : '',
            jenis: _selectedFilter == 'Semua' ? '' : _selectedFilter,
          ),
        ),
      );
    } else if (widget.fromScreen ==
        'arsip_transaksi_pernah_dikembalikan_oleh_anda') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ArsipTransaksiPernahDikembalikanOlehAndaScreen(
            search: _searchController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Pencarian'),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: AppColors.baseBackground,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (widget.fromScreen != 'arsip_transaksi') {
                          FocusScope.of(context).requestFocus(_focusNode);
                        }
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
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                focusNode: _focusNode,
                                decoration: InputDecoration(
                                  hintText:
                                      widget.fromScreen == 'butuh_persetujuan'
                                      ? 'Cari PPB/PJL Butuh Persetujuan...'
                                      : widget.fromScreen == 'transaksi_gantung'
                                      ? 'Cari Transaksi Gantung...'
                                      : widget.fromScreen ==
                                            'butuh_konfirmasi_penyelesaian'
                                      ? 'Cari Konfirmasi Barang/Jasa & Penyelesaian Transaksi...'
                                      : widget.fromScreen == 'arsip_transaksi'
                                      ? 'Pencarian...'
                                      : widget.fromScreen ==
                                            'arsip_transaksi_pernah_dikembalikan_oleh_anda'
                                      ? 'Cari Arsip PPB/PJL...'
                                      : 'Type to search...',
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                style: const TextStyle(
                                  color: AppColors.textblack,
                                  fontSize: 14,
                                ),
                                textInputAction:
                                    widget.fromScreen == 'arsip_transaksi'
                                    ? TextInputAction.done
                                    : TextInputAction.go,
                                onSubmitted:
                                    widget.fromScreen == 'arsip_transaksi'
                                    ? (_) {} // Tidak melakukan submit
                                    : _onSearchSubmitted,
                              ),
                            ),
                            if (widget.fromScreen != 'arsip_transaksi')
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.grey,
                                ),
                                onPressed: () =>
                                    _onSearchSubmitted(_searchController.text),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(color: AppColors.orange),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Icon dan text di ujung kiri
                            const Icon(
                              Icons.info_outline,
                              color: AppColors.black,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Lakukan pencarian berdasarkan\nsalah satu kolom berikut:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 12,
                                    color: AppColors.textwhite,
                                  ),
                                ),
                                Text(
                                  widget.fromScreen == 'butuh_persetujuan'
                                      ? 'No. PPB/PJL, Nama Pemohon,\nKeterangan/Keperluan'
                                      : widget.fromScreen == 'transaksi_gantung'
                                      ? 'No. PPB/PJL, Nama Pemohon, Keperluan,\nTunai/Transfer'
                                      : widget.fromScreen ==
                                            'butuh_konfirmasi_penyelesaian'
                                      ? 'No. PPB/PJL, Nama Pemohon, Keperluan,\nTunai/Transfer'
                                      : widget.fromScreen == 'arsip_transaksi'
                                      ? 'No. PPB/PJL, Nama Pemohon,\nKeperluan/Keterangan'
                                      : widget.fromScreen ==
                                            'arsip_transaksi_pernah_dikembalikan_oleh_anda'
                                      ? 'No. PPB/PJL, Nama Pemohon,\nKeperluan/Keterangan'
                                      : "",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppColors.textwhite,
                                  ),
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.fromScreen == 'arsip_transaksi') ...[
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  'Jenis Pembayaran: ',
                                  style: TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButton<String>(
                                    value: _selectedFilter,
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    items: ['Semua', 'Transfer', 'Tunai'].map((
                                      String value,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedFilter = newValue!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () async {
                              FocusScope.of(
                                context,
                              ).unfocus(); // Tutup keyboard jika terbuka
                              final picked = await showDatePickerDialog(
                                context: context,
                                initialDate: DateTime.now(),
                                minDate: DateTime(2018),
                                maxDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() {
                                  // Simpan tanggal awal
                                  _tanggalAwal = picked;
                                });
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              margin: const EdgeInsets.only(
                                bottom: 12,
                              ), // Tambahkan jarak bawah
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                _tanggalAwal != null
                                    ? 'Tanggal Awal: ${DateFormat('yyyy/MM/dd').format(_tanggalAwal!)}'
                                    : 'Pilih Tanggal Awal',
                                style: const TextStyle(fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              FocusScope.of(
                                context,
                              ).unfocus(); // Tutup keyboard jika terbuka
                              final picked = await showDatePickerDialog(
                                context: context,
                                initialDate: DateTime.now(),
                                minDate: DateTime(2018),
                                maxDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() {
                                  // Simpan tanggal akhir
                                  _tanggalAkhir = picked;
                                });
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                _tanggalAkhir != null
                                    ? 'Tanggal Akhir: ${DateFormat('yyyy/MM/dd').format(_tanggalAkhir!)}'
                                    : 'Pilih Tanggal Akhir',
                                style: const TextStyle(fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          Center(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.green, // warna success
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(),
                                ),
                                onPressed: () =>
                                    _onSearchSubmitted(_searchController.text),
                                child: const Text(
                                  'Cari',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
