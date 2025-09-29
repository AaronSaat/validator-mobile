import 'package:flutter/material.dart';
import 'package:validator/screens/success_transaksi_screen.dart';
import 'package:validator/services/api_service.dart';
import 'package:validator/utils/appcolors.dart';

class SetujuiTransaksiScreen extends StatefulWidget {
  final int pembelianId;
  final int userId;
  final int level;
  final int barang_jasa;
  final String no_ppb;
  final String tgl_pengajuan;
  final String divisi;
  final String keterangan;
  final String total_biaya;

  SetujuiTransaksiScreen({
    required this.pembelianId,
    required this.userId,
    required this.level,
    required this.barang_jasa,
    required this.no_ppb,
    required this.tgl_pengajuan,
    required this.divisi,
    required this.keterangan,
    required this.total_biaya,
    Key? key,
  }) : super(key: key);

  @override
  _SetujuiTransaksiScreenState createState() =>
      _SetujuiTransaksiScreenState();
}

class _SetujuiTransaksiScreenState
    extends State<SetujuiTransaksiScreen> {
  final TextEditingController _controller = TextEditingController();
  String? _message;
  Color? _messageColor;

  Future<void> _handleApproval(int action) async {
    setState(() {
      _message = null;
      _messageColor = null;
    });

    try {
      final result = await ApiService.pembelianApproval(
        pembelianId: widget.pembelianId,
        userId: widget.userId,
        approve: action, // 1 for approve, 2 for disapprove
        level: widget.level,
        status: action == 1 ? widget.level : 99,
        keterangan: _controller.text.trim().isEmpty ? "" : _controller.text,
      );

      if (result['success'] == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessTransaksiScreen(
              isSuccess: true,
              message: action == 1
                  ? 'Transaksi berhasil disetujui.'
                  : 'Transaksi berhasil dikembalikan.',
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessTransaksiScreen(
              isSuccess: false,
              message: result['message'] ?? 'Terjadi kesalahan.',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _message = 'Gagal memproses: $e';
        _messageColor = Colors.red;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Persetujuan Transaksi Pembelian',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              // Implement refresh logic here
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Persetujuan Transaksi',
                  style: TextStyle(color: AppColors.textblack, fontSize: 18),
                ),
                SizedBox(height: 16),
                Table(
                  border: TableBorder.all(color: AppColors.greyMedium),
                  children: [
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            widget.barang_jasa == 1
                                ? 'No PPB (Pembelian Barang)'
                                : 'No PJL (Jasa Luar)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(widget.no_ppb),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Tanggal Pengajuan',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(widget.tgl_pengajuan),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Divisi',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(widget.divisi),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Keterangan/Keperluan',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(widget.keterangan),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Total Biaya',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(widget.total_biaya),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _controller,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Keterangan/Catatan',
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.keyboard_hide),
                      tooltip: 'Tutup Keyboard',
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () => _handleApproval(1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.check_circle, color: AppColors.white),
                            SizedBox(width: 8),
                            Text(
                              'Setujui Transaksi',
                              style: TextStyle(
                                color: AppColors.textwhite,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _handleApproval(2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.error, color: AppColors.white),
                            SizedBox(width: 8),
                            Text(
                              'Kembalikan Transaksi',
                              style: TextStyle(
                                color: AppColors.textwhite,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                if (_message != null)
                  Text(
                    _message!,
                    style: TextStyle(color: _messageColor, fontSize: 16),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
