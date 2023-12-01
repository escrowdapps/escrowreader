import 'package:connectivity_plus/connectivity_plus.dart'
    show Connectivity, ConnectivityResult;

class PlatformUtils {
  static Future<bool> checkConnection() async {
    ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();

    return connectivityResult != ConnectivityResult.none;
  }
}
