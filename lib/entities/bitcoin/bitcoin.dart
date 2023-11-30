import 'package:hive/hive.dart';

class Bitcoin {
  static const String HIVE_SETTINGS_KEY = 'settings';

  static Future<void> getUTXO() async {
    var box = await Hive.openBox(HIVE_SETTINGS_KEY);
  }
}
