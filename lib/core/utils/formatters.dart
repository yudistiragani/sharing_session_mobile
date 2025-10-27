import 'package:intl/intl.dart';

final _idr = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
String formatRupiah(int v) => _idr.format(v);

String statusLabelFromUi(String uiStatus) {
  switch (uiStatus) {
    case 'low': return 'Menipis';
    case 'inactive': return 'Nonaktif';
    default: return 'Aktif';
  }
}

int statusColorFromUi(String uiStatus) {
  switch (uiStatus) {
    case 'low': return 0xFFFFA000;      // amber
    case 'inactive': return 0xFF9E9E9E; // grey
    default: return 0xFF4CAF50;         // green
  }
}
