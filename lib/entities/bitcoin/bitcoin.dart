import 'package:hive/hive.dart';

class Bitcoin {
  static const String HIVE_SETTINGS_KEY = 'settings';

  static Uri BLOCKSTREAM_URL = Uri(
      scheme: 'https',
      host: 'blockstream.info',
      path: 'api/address/wallet/utxo');

  static Future<void> getUTXO() async {
    // var box = await Hive.openBox(HIVE_SETTINGS_KEY);
  }

  static Uri? getReplacedUri({String walletId = '', Uri? customUrl}) {
    if (walletId.isEmpty) {
      throw const FormatException('wallet id not passed');
    }

    if (customUrl != null) {
      Uri url = customUrl.replace(path: 'api/address/$walletId/utxo');

      return url;
    }

    if (walletId.isNotEmpty) {
      Uri url =
          Bitcoin.BLOCKSTREAM_URL.replace(path: 'api/address/$walletId/utxo');

      return url;
    }

    return null;
  }
}
