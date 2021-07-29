import 'package:civilsafety_quiz/Controller/BaseCommand.dart';

class UserCommand extends BaseCommand {
  Future<Map> login(String email, String password) async {
    Map loginResponse = await userService.login(email, password);

    print('[UserCommand] loginResponse $loginResponse');

    if (loginResponse['success'] == 'success') {
      appModel.currentUserToken = loginResponse['userToken'];
    } else {
      appModel.currentUserToken = '';
    }

    return loginResponse;
  }

  Future<String> register(String username, String email, String password,
      String confirmPassword) async {
    String registerSuccess =
        await userService.register(username, email, password, confirmPassword);

    print('[UserCommand] registerSuccess $registerSuccess');
    appModel.currentUserToken = registerSuccess;

    return registerSuccess;
  }

  Future<bool> isOnlineCheck() async {
    print('[UserCommand] isOnlineCheck Method calling...');
    bool isOnline = await appService.isOnlineCheck();

    appModel.isOnline = isOnline;

    return isOnline;
  }
}
