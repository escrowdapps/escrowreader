import 'package:intl/intl.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io'; 
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ntp/ntp.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app/contract.dart';


String getFormatDate(int date) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(date);
  DateFormat dateFormat = DateFormat('dd.MM.yyyy HH:mm:ss');
  String formattedDate = dateFormat.format(dateTime);
  return formattedDate;
}

String getLocalTimeZoneOffset() {
  final dateTimeNow = DateTime.now();
  final timeZoneOffsetHours = dateTimeNow.timeZoneOffset.inHours;
  final sign = timeZoneOffsetHours >= 0 ? '+' : '-';
  return 'UTC$sign${timeZoneOffsetHours.abs().toString().padLeft(2, '0')}';
}

List<dynamic> getRandomParagraphs(String text) {
  List textFilter = text.split('\n\n').where((str) => str != "").toList();

  if(textFilter.length < 3){
    textFilter = text.split(' ').where((str) => str != "").toList();
    if(textFilter.length<3){
      textFilter = text.split('').where((str) => str != "").toList();
      if(textFilter.length < 3){
        return [];
      }
    }
  }
  
  final part = textFilter.length ~/ 3;
  final paragraphs = [];
  final random = Random();
  for (int i = 0; i < 3; i++) {
    final min = part * i;
    final max = part * (i + 1) - 1;
    final rand = min + random.nextInt(max - min + 1);
    paragraphs.add(textFilter[rand]);
  }
  return paragraphs;
}


Future<dynamic> getBalance(String wallet) async {
// url: `https://blockstream.info/testnet/api/address/${sourceAddress}/utxo`,
try{
    // var url = Uri.https('blockstream.info', 'testnet/api/address/$wallet/utxo');
    var url = Uri.https('blockstream.info', 'api/address/$wallet/utxo');

    var utxo = await http.get(url, headers: {
      "Accept": "application/json",
    });
    dynamic data = jsonDecode(utxo.body);
    num balance = 0;
    data.forEach((item) => {balance += item['value']});
    if(balance<100){
      return 0;
    }else{
    return balance;
    }
}catch(e){
  num balance = 40400000000;
  return balance;
}

}


Future<String> getFilePath() async {
  Directory directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<void> saveFile(String content, String fileName) async {
  String directoryPath = await getFilePath();
  String filePath = '$directoryPath/$fileName';
  
  
  File file = File(filePath);
  await file.writeAsString(content);
}

Future<String> readFile(fileName) async {
  String directoryPath = await getFilePath();
  String filePath = '$directoryPath/$fileName';

  File file = File(filePath);
  if (await file.exists()) {
    String content = await file.readAsString();
    return content;
  } else {
    return "Файл не найден";
  }
}








Future checkConection() async {
  final connectivityResult = await (Connectivity().checkConnectivity());
  bool isConnect = false;
  if (connectivityResult == ConnectivityResult.mobile) {
    isConnect = true;
    // I am connected to a mobile network.
  } else if (connectivityResult == ConnectivityResult.wifi) {
    isConnect = true;

    // I am connected to a wifi network.
  } else if (connectivityResult == ConnectivityResult.ethernet) {
    isConnect = true;

    // I am connected to a ethernet network.
  } else if (connectivityResult == ConnectivityResult.vpn) {
    isConnect = true;

    // I am connected to a vpn network.
    // Note for iOS and macOS:
    // There is no separate network interface type for [vpn].
    // It returns [other] on any device (also simulator)
  } else if (connectivityResult == ConnectivityResult.bluetooth) {
    // I am connected to a bluetooth.
  } else if (connectivityResult == ConnectivityResult.other) {
    isConnect = true;

    // I am connected to a network which is not in the above mentioned networks.
  } else if (connectivityResult == ConnectivityResult.none) {
    isConnect = false;

    // I am not connected to any network.
  }

  return isConnect;
}


Future<dynamic> getTimeNTP()async{
  try{
    if(await checkConection()){
      dynamic dateNow = await NTP.now();
      return dateNow.millisecondsSinceEpoch;
    }else{
      return 'no internet';
    }

  }catch(e){
    return e;
  }
}




String ErrorCutBody(String errorString){
  int braceIndex = errorString.indexOf('{');
  String jsonString = errorString.substring(braceIndex);
  Map<String, dynamic> jsonData = json.decode(jsonString);
  String errorMessage = jsonData['message'];
  return errorMessage;
}


Future<Box> openEncryptedBoxContracts() async {
    AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );
  final secureStorage = FlutterSecureStorage(aOptions: _getAndroidOptions());
  final encryptionKeyString = await secureStorage.read(key: 'key');

  if (encryptionKeyString == null) {
    final key = Hive.generateSecureKey();
    await secureStorage.write(
      key: 'key',
      value: base64UrlEncode(key),
    );
  }

  final key = await secureStorage.read(key: 'key');
  final encryptionKeyUint8List = base64Url.decode(key!);


  return await Hive.openBox<Contract>('contracts',
      encryptionCipher: HiveAesCipher(encryptionKeyUint8List));
}
