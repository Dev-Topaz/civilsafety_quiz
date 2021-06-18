import 'package:connectivity/connectivity.dart';

class AppService {
  Future<bool> isOnlineCheck() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    print('[AppService] connectivityResult $connectivityResult');

    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }
}
