import 'package:flutter/material.dart';
import 'package:validator/utils/appcolors.dart';
import '../services/api_service.dart';
import '../utils/date_formatter.dart';

class DetailPpbPjjScreen extends StatefulWidget {
  final String approvalId;
  final String userId;

  const DetailPpbPjjScreen({
    Key? key,
    required this.approvalId,
    required this.userId,
  }) : super(key: key);

  @override
  State<DetailPpbPjjScreen> createState() => _DetailPpbPjjScreenState();
}

class _DetailPpbPjjScreenState extends State<DetailPpbPjjScreen> {
  Map<String, dynamic>? detailData;
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      final result = await ApiService.pembelianTambahDetailApproval(
        approvalId: widget.approvalId,
        userId: widget.userId,
      );
      setState(() {
        detailData = result;
      });
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
      appBar: AppBar(
        title: const Text('Detail Approval'),
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
              ? const Center(child: CircularProgressIndicator())
              : errorMsg != null
              ? Center(child: Text(errorMsg!))
              : detailData == null
              ? const Center(child: Text('Data tidak ditemukan'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Model Pembelian
                      // Judul Pengadaan Jasa Luar
                      Text(
                        detailData!['model_pembelian']['barang_jasa'] == 1
                            ? 'Pembelian Barang Baru'
                            : 'Pengadaan Jasa Luar',
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
                              color: Colors.grey[400]!,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white, // background putih
                          ),
                          child: Table(
                            border: TableBorder.all(
                              color: Colors.grey[400]!,
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
                                      'Divisi',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color:
                                          detailData!['model_pembelian']['status'] ==
                                              1
                                          ? AppColors.lightblue
                                          : detailData!['model_pembelian']['status'] ==
                                                101
                                          ? AppColors.orange
                                          : Colors.grey[300],
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
                            ],
                          ),
                        ),
                      ],

                      // Data Provider
                      if (detailData?['dataProvider'] != null &&
                          detailData!['dataProvider'] is List &&
                          detailData!['dataProvider'].isNotEmpty) ...[
                        Container(
                          width: double.infinity,
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
                              const Text(
                                'Data Provider',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Table(
                                border: TableBorder.symmetric(
                                  inside: BorderSide(color: Colors.grey[300]!, width: 1.2),
                                ),
                                columnWidths: const {
                                  0: FlexColumnWidth(0.5),
                                  1: FlexColumnWidth(3.5),
                                },
                                children: [
                                  for (var entry in detailData!['dataProvider'].asMap().entries)
                                    TableRow(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${entry.key + 1}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${entry.value['jenis_pekerjaan'] ?? '-'}',
                                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(Icons.business, size: 16, color: Colors.grey),
                                                  const SizedBox(width: 4),
                                                  Text('${entry.value['supplier_jasa'] ?? '-'}', style: const TextStyle(fontSize: 12)),
                                                  const SizedBox(width: 16),
                                                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                                  const SizedBox(width: 4),
                                                  Text('${entry.value['tgl_diselesaikan'] ?? '-'}', style: const TextStyle(fontSize: 12)),
                                                ],
                                              ),
                                              Container(
                                                margin: const EdgeInsets.symmetric(vertical: 4),
                                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                                decoration: BoxDecoration(
                                                  color: AppColors.lightblue.withAlpha(50),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: AppColors.secondary),
                                                ),
                                                child: Text(
                                                  'Estimasi Biaya: ${entry.value['estimasi_biaya'] ?? '-'}',
                                                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                                                ),
                                              ),
                                              Text(
                                                'Keterangan Item: ' +
                                                  ((entry.value['keterangan_item']?.toString().toLowerCase() == 'keterangan item')
                                                    ? '-'
                                                    : '${entry.value['keterangan_item'] ?? '-'}'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
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
                              const Text(
                                'Upload Provider',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ...detailData!['dataProviderUpload'].map<Widget>(
                                (up) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Nama File: ${up['nama_file'] ?? '-'}',
                                    ),
                                    Text(
                                      'Keterangan: ${up['keterangan'] ?? '-'}',
                                    ),
                                    Text('Tahap: ${up['tahap'] ?? '-'}'),
                                    const SizedBox(height: 4),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      // Rekap Pembelian
                      if (detailData?['rekap_pembelian'] != null) ...[
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
                              const Text(
                                'Rekap Pembelian',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Jenis Jasa: ${detailData!['rekap_pembelian']['jenis_jasa'] ?? '-'}',
                              ),
                              Text(
                                'Total Biaya: ${detailData!['rekap_pembelian']['total_biaya'] ?? '-'}',
                              ),
                            ],
                          ),
                        ),
                      ],
                      // Model Pembelian Detail Approved
                      if (detailData?['model_pembelian_detail_approved'] !=
                              null &&
                          detailData!['model_pembelian_detail_approved']
                              is Map &&
                          detailData!['model_pembelian_detail_approved']
                              .isNotEmpty) ...[
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
                              const Text(
                                'Detail Approved',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ...detailData!['model_pembelian_detail_approved']
                                  .entries
                                  .map((entry) {
                                    final val = entry.value;
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'ID Jasaluar Detail Approved: ${val['id_jasaluar_detail_approved'] ?? '-'}',
                                        ),
                                        Text(
                                          'ID Jasaluar Detail: ${val['id_jasaluar_detail'] ?? '-'}',
                                        ),
                                        Text(
                                          'ID Pembelian: ${val['id_pembelian'] ?? '-'}',
                                        ),
                                        const SizedBox(height: 4),
                                      ],
                                    );
                                  }),
                            ],
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
                              const Text(
                                'Status Approval',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ...detailData!['model_status'].map<Widget>(
                                (st) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tanggal: ${st['tanggal_status'] ?? '-'}',
                                    ),
                                    Text('Status: ${st['status'] ?? '-'}'),
                                    Text(
                                      'Kode Status: ${st['kode_status'] ?? '-'}',
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      // Rekap Pembelian Approved
                      if (detailData?['rekap_pembelian_approved'] != null) ...[
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
                              const Text(
                                'Rekap Pembelian Approved',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Jenis Jasa: ${detailData!['rekap_pembelian_approved']['jenis_jasa'] ?? '-'}',
                              ),
                              Text(
                                'Total Biaya: ${detailData!['rekap_pembelian_approved']['total_biaya'] ?? '-'}',
                              ),
                            ],
                          ),
                        ),
                      ],
                      // Data Provider Bayar
                      if (detailData?['dataProviderBayar'] != null &&
                          detailData!['dataProviderBayar'] is List &&
                          detailData!['dataProviderBayar'].isNotEmpty) ...[
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
                              const Text(
                                'Data Provider Bayar',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ...detailData!['dataProviderBayar'].map<Widget>(
                                (bayar) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ID Bayar: ${bayar['id_bayar'] ?? '-'}',
                                    ),
                                    Text(
                                      'ID Pembelian: ${bayar['id_pembelian'] ?? '-'}',
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                ),
                              ),
                            ],
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
                              const Text(
                                'Upload Bayar',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ...detailData!['dataProviderBayarUpload'].map<
                                Widget
                              >(
                                (up) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Nama File: ${up['nama_file'] ?? '-'}',
                                    ),
                                    Text(
                                      'Keterangan: ${up['keterangan'] ?? '-'}',
                                    ),
                                    Text('Tahap: ${up['tahap'] ?? '-'}'),
                                    const SizedBox(height: 4),
                                  ],
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
    );
  }
}
