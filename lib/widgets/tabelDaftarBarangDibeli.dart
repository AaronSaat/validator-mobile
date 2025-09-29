import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TabelDaftarBarangDibeli extends StatelessWidget {
  final String title;
  final Map<String, dynamic> detailData;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const TabelDaftarBarangDibeli({
    Key? key,
    required this.detailData,
    this.title = 'Daftar Barang Dibeli',
    this.backgroundColor,
    this.margin,
    this.padding,
  }) : super(key: key);

  String formatCurrency(num value) {
    return NumberFormat("#,##0.00", "en_US").format(value);
  }

  @override
  Widget build(BuildContext context) {
    if (detailData == null) {
      print('Detail Data: $detailData');
      return const SizedBox.shrink();
    }

    final entries = detailData.entries.toList();

    return Container(
      width: double.infinity,
      margin: margin ?? const EdgeInsets.symmetric(vertical: 6.0),
      padding:
          padding ??
          const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
              for (var i = 0; i < entries.length; i++)
                TableRow(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${entries[i].value['nama_barang'] ?? '-'}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.local_offer,
                                size: 18,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Merk: ${entries[i].value['merk'] ?? '-'}',
                                  style: const TextStyle(fontSize: 14),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.confirmation_number,
                                size: 18,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Jumlah: ${entries[i].value['jumlah']}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.straighten,
                                size: 18,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Satuan: ${entries[i].value['satuan']}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 18,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Tanggal Dibutuhkan: ${(entries[i].value['tgl_dibutuhkan'] == null || entries[i].value['tgl_dibutuhkan'].toString().trim().isEmpty) ? '(not set)' : entries[i].value['tgl_dibutuhkan']}',
                                  style: const TextStyle(fontSize: 14),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 18,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Keperluan: ${((entries[i].value['keperluan']?.toString().toLowerCase() == 'keperluan') || (entries[i].value['keperluan'] == null) || (entries[i].value['keperluan'].toString().trim().isEmpty)) ? '-' : entries[i].value['keperluan']}',
                                  style: const TextStyle(fontSize: 14),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 18,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Lokasi Penggunaan: ${entries[i].value['lokasi']}',
                                  style: const TextStyle(fontSize: 14),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withAlpha(50),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                (() {
                                  final hargaSatuan =
                                      num.tryParse(
                                        entries[i].value['harga_satuan']
                                                ?.toString() ??
                                            '0',
                                      ) ??
                                      0;
                                  final estimasiHargaSatuan =
                                      num.tryParse(
                                        entries[i]
                                                .value['estimasi_harga_satuan']
                                                ?.toString() ??
                                            '0',
                                      ) ??
                                      0;
                                  if (hargaSatuan != estimasiHargaSatuan) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Harga Satuan:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          'Rp. ${formatCurrency(hargaSatuan)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Rp. ${formatCurrency(estimasiHargaSatuan)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                            color: Colors.grey,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    return Text(
                                      'Harga Satuan: Rp. ${formatCurrency(hargaSatuan)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    );
                                  }
                                })(),
                                const SizedBox(height: 2),
                                Text(
                                  'Total Harga: ${(() {
                                    final jumlah = num.tryParse(entries[i].value['jumlah'].toString()) ?? 0;
                                    final hargaSatuan = num.tryParse(entries[i].value['harga_satuan']?.toString() ?? '0') ?? 0;
                                    final estimasiHargaSatuan = num.tryParse(entries[i].value['estimasi_harga_satuan']?.toString() ?? '0') ?? 0;
                                    final harga = hargaSatuan != 0 ? hargaSatuan : estimasiHargaSatuan;
                                    return 'Rp. ${formatCurrency(jumlah * harga)}';
                                  })()}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
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
    );
  }
}
