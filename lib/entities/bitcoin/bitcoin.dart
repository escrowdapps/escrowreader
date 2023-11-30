import 'dart:convert';
import 'dart:math';

import 'package:app/DTOs/Response/FeeResponseDTO.dart';
import 'package:app/DTOs/Response/UTXO.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

class Bitcoin {
  static const String HIVE_SETTINGS_KEY = 'settings';
  static Uri FEE_ENDPOINT_URL =
  Uri.parse('https://api.blockcypher.com/v1/btc/main');

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
      Uri url = customUrl.replace(
          path: customUrl.path.replaceFirst('wallet', walletId));

      return url;
    }

    if (walletId.isNotEmpty) {
      Uri url =
      Bitcoin.BLOCKSTREAM_URL.replace(path: 'api/address/$walletId/utxo');

      return url;
    }

    return null;
  }

  static Future<List<UtxoDTO>> getTransactions(
      {required String walletId, Uri? customUrl}) async {
    List<UtxoDTO> list = [];
    Uri? requestUri = getReplacedUri(walletId: walletId, customUrl: customUrl);

    if (requestUri == null) {
      throw const FormatException('can not create uri');
    }

    try {
      http.Response response = await http.get(requestUri);

      final parsedJSON = jsonDecode(response.body);

      for (var item in parsedJSON) {
        list.add(UtxoDTO.fromJSON(item));
      }

      return list;
    } catch (e) {
      rethrow;
    }
  }

  static Future<int> getFee() async {
    try {
      http.Response response = await http.get(Bitcoin.FEE_ENDPOINT_URL);

      final parsedJSON = jsonDecode(response.body);

      FeeResponseDTO feeResponse = FeeResponseDTO.fromJSON(parsedJSON);

      return feeResponse.fee;
    } catch (e) {
      rethrow;
    }
  }
}
