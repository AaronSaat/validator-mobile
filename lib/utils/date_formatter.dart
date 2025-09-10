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
