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
  final int branch;
  final int id_divisi;
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
    required this.id_divisi,
    required this.branch,
    required this.keterangan,
    required this.total_biaya,
    Key? key,
  }) : super(key: key);

  @override
  _SetujuiTransaksiScreenState createState() => _SetujuiTransaksiScreenState();
}

class _SetujuiTransaksiScreenState extends State<SetujuiTransaksiScreen> {
  String? _selectedBranch;
  final TextEditingController _controller = TextEditingController();
  String? _message;
  Color? _messageColor;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set default branch sesuai widget.branch
    if (widget.branch == 1) {
      _selectedBranch = 'STT SAAT';
    } else if (widget.branch == 2) {
      _selectedBranch = 'Yayasan SAAT';
    } else {
      _selectedBranch = null;
    }
  }

  Future<void> _handleApproval(int action) async {
    if (isLoading) return;
    if (_selectedBranch == null || _selectedBranch == 'Pilih branch') {
      setState(() {
        _message = 'Silakan pilih branch terlebih dahulu.';
        _messageColor = Colors.red;
      });
      return;
    }
    setState(() {
      _message = null;
      _messageColor = null;
      isLoading = true;
    });

    if (action == 2 && _controller.text.trim().isEmpty) {
      setState(() {
        _message =
            "Jelaskan alasan Anda mengembalikan transaksi ini di isian keterangan";
        _messageColor = Colors.red;
        isLoading = false;
      });
      return;
    }
    if (action == 1 && _controller.text.trim().isEmpty) {
      _controller.text = "Menyetujui";
    }

    try {
      // Tentukan branch sesuai pilihan dropdown
      int branchValue = _selectedBranch == 'STT SAAT' ? 1 : 2;
      final result = await ApiService.pembelianApproval(
        pembelianId: widget.pembelianId,
        userId: widget.userId,
        approve: action, // 1 for approve, 2 for disapprove
        level: widget.level,
        status: action == 1 ? widget.level : 99,
        idDivisi: widget.id_divisi,
        branch: branchValue,
        keterangan: _controller.text.trim().isEmpty ? "" : _controller.text,
      );

      if (result['success'] == true) {
        setState(() {
          isLoading = false;
        });
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
        setState(() {
          isLoading = false;
        });
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
        isLoading = false;
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
                // Dropdown untuk memilih branch
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedBranch,
                    decoration: const InputDecoration(
                      labelText: 'Pilih Branch',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Pilih branch', 'STT SAAT', 'Yayasan SAAT']
                        .map(
                          (String value) => DropdownMenuItem<String>(
                            value: value == 'Pilih branch' ? null : value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedBranch = newValue;
                      });
                    },
                  ),
                ),
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
                    isLoading
                        ? Container(
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.greyLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              GestureDetector(
                                onTap: () => _handleApproval(1),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.check_circle,
                                        color: AppColors.white,
                                      ),
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
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
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
