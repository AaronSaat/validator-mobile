import 'package:intl/intl.dart';

String formatTanggal(int tanggal) {
  try {
    // Gunakan fromMillisecondsSinceEpoch tanpa isUtc, agar sesuai zona lokal
    DateTime dt = tanggal > 1000000000000
        ? DateTime.fromMillisecondsSinceEpoch(tanggal)
        : DateTime.fromMillisecondsSinceEpoch(tanggal * 1000);
    return DateFormat('dd MMMM yyyy', 'id_ID').format(dt);
  } catch (e) {
    return tanggal.toString();
  }
}

String formatTanggalFromString(String tanggal) {
  try {
    DateTime dt = DateFormat('yyyy-MM-dd').parse(tanggal);
    return DateFormat('dd MMMM yyyy', 'id_ID').format(dt);
  } catch (e) {
    return tanggal;
  }
}

String namaBulan(int bulan) {
  const List<String> bulanIndonesia = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  if (bulan < 1 || bulan > 12) {
    return 'Bulan tidak valid';
  }
  return bulanIndonesia[bulan - 1];
}
