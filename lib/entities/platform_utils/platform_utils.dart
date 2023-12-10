import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart'
    show Connectivity, ConnectivityResult;
import 'package:path_provider/path_provider.dart';

class PlatformUtils {
  static Future<bool> checkConnection() async {
    ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();

    return connectivityResult != ConnectivityResult.none;
  }

  Future<String> getFilePath() async {
    Directory directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}
