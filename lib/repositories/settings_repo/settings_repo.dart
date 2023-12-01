import 'package:app/exceptions/initialize_exception.dart';
import 'package:hive/hive.dart';

class SettingsRepo {
  static String BOX_KEY = 'settings';
  static String UTXO_KEY = 'utxo';

  late final Box<dynamic>? _box;

  Future<SettingsRepo> create() async {
    _box = await Hive.openBox(SettingsRepo.BOX_KEY);

    return this;
  }

  String? getUtxoURL() {
    if (_box == null) {
      throw ClassInitializeException(
          'you must call async create function before use getUtxourl method');
    }

    return _box!.get(SettingsRepo.UTXO_KEY);
  }
}
