import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class Utils {
  static String timestampToDate(int timestamp) {
    const String format = 'dd.MM.yy HH:mm:ss';

    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    DateFormat dateFormat = DateFormat(format);
    String formattedDate = dateFormat.format(dateTime);

    return formattedDate;
  }

  /// приводит int к строке даты
  /// первый аргумент timestamp
  /// второй формат
  static String getDateFromTimestamp(int timestamp, String format) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    DateFormat formatter = DateFormat(format);

    return formatter.format(dateTime);
  }

  /// получает и возвращает директорию с документами
  static Future<String> getDocumentsPath() async {
    Directory directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}
