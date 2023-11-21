import 'package:flutter_bitcoin/flutter_bitcoin.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'contract.dart';
import 'funcs.dart';
import 'package:hive/hive.dart';

int calculateTransactionWeight(int numInputs) {
  int inputWeight = numInputs * 180;
  int numOutputs = 2;
  int outputWeight = numOutputs * 34;
  int metadataWeight = 10;

  int signatureWeight = numInputs * 73;

  int totalWeight =
      inputWeight + outputWeight + metadataWeight + signatureWeight;

  return totalWeight;
}

Future<dynamic> getUtxo(String wallet) async {
  try {
    var box = await Hive.openBox('settings');
    dynamic utxoUrl = box.get('utxo');
    // String fullUrl = 'https://blockstream.info/testnet/api/address/wallet/utxo';
       String fullUrl = 'https://blockstream.info/api/address/wallet/utxo';

    if (utxoUrl != '' && utxoUrl != null) {
      fullUrl = utxoUrl;
    }
    Uri uri = Uri.parse(fullUrl);

    String path = uri.path;
    List<String> segments = path.split('/');
    int walletIndex = segments.indexOf('wallet');
    if (walletIndex != -1) {
      segments[walletIndex] = wallet;
    }
    String updatedPath = segments.join('/');
    print(updatedPath);
    var url = Uri.https(uri.host, updatedPath);
    var utxo = await http.read(url);
    var utxoDecode = jsonDecode(utxo);

    return utxoDecode;
  } catch (error) {
    return 404;
  }
}

Future<dynamic> getFee() async {
  try {
    var url = Uri.https('api.blockcypher.com', 'v1/btc/main'); //test3
    var data = await http.read(url);
    var e = jsonDecode(data);
    return (e['low_fee_per_kb'] / 1024).ceil();
  } catch (error) {
    return '0';
  }
}

dynamic bitcoin(Contract contract, String userAddress,
    [bool timeOff = false]) async {
  String myAddress = '12Vt2BS4GDWyhfForN7dF9tjsPaLrDtHEa';

  if (userAddress == '') {
    return 'empty address';
  }
  dynamic addressExist = await getUtxo(userAddress);
  if(addressExist == 404){
    return 'bad address';
  }

  dynamic utxo = await getUtxo(contract.walletMap['address']);
  if (utxo == 404) {
    return 'bad utxo';
  }
  if (utxo.length == 0) {
    return 'balance 0';
  }

  dynamic satoshisPerByte;

  var box = await Hive.openBox('settings');
  var feeHive = box.get('fee');
  if (feeHive != '' && feeHive != null) {
    satoshisPerByte = int.parse(feeHive);
  } else {
    try {
      satoshisPerByte = await getFee();
    } catch (error) {
      satoshisPerByte = 404;
    }
  }
  if (satoshisPerByte == 404) return 'change fee';

  final ecPair = ECPair.fromWIF(contract.walletMap['wif']);
  int fee =
      (satoshisPerByte * calculateTransactionWeight(utxo.length) / 2).floor();
  final txb = TransactionBuilder();
  // TransactionBuilder();

  txb.setVersion(1);
  dynamic totalAmount = 0;
  utxo.forEach((input) {
    totalAmount += input['value'];
    txb.addInput(input['txid'], input['vout']);
  });

  if (totalAmount == 0) {
    return 'balance 0';
  }

  int checkpoints = 3 - contract.paragraphs.length;

  int userAmount = (totalAmount * checkpoints / 3).floor();
  int myAmount = totalAmount - userAmount;

  if (timeOff) {
    txb.addOutput(
        myAddress,
        myAmount - fee > 0
            ? (myAmount - fee).toInt()
            : (myAmount * 0.5).toInt());
  } else {
    if (contract.uri == 'timeOff') {
      txb.addOutput(
          userAddress,
          totalAmount - fee > 0
              ? (totalAmount - fee).toInt()
              : (totalAmount * 0.5).toInt());
    } else {
      txb.addOutput(
          myAddress,
          myAmount - fee > 0
              ? (myAmount - fee).toInt()
              : (myAmount * 0.9).toInt());
      txb.addOutput(
          userAddress,
          userAmount - fee > 0
              ? (userAmount - fee).toInt()
              : (userAmount * 0.9).toInt());
    }
  }

  for (int i = 0; i < utxo.length; i++) {
    txb.sign(vin: i, keyPair: ecPair);
  }

  final txHex = txb.build().toHex();

  var txUrl = box.get('tx');

  if (txUrl == '' || txUrl == null) {
    // txUrl = 'https://blockstream.info/testnet/api/tx';
    txUrl = "https://blockstream.info/api/tx";
  }

  final response = await http.post(
    Uri.parse(txUrl),
    headers: {'Content-Type': 'text/plain'},
    body: txHex,
  );

  if (response.statusCode == 200) {
    print('Транзакция успешно отправлена $response');

    var box = await Hive.openBox<Contract>('contracts');
    var contractUpdate = box.get(contract.id);
    if (contractUpdate != null) {
      if (timeOff) {
        contractUpdate.uri = 'timeOff';
        box.put(contractUpdate.id, contractUpdate);
      } else {
        contractUpdate.uri = '${response.body}_${myAmount / 100000000}';
        box.put(contractUpdate.id, contractUpdate);
        return '${response.body}';
      }
    } else {
      print('Контракт с id ${contract.id} не найден.');
    }
  } else {
    print('Произошла ошибка при отправке транзакции:${response.body}');
    return ErrorCutBody(response.body);
  }
}
