import 'package:civilsafety_quiz/Controller/BaseCommand.dart';

class UserCommand extends BaseCommand {
  Future<String> login(String email, String password) async {
    String loginSuccess = await userService.login(email, password);

    print('[UserCommand] loginSuccess $loginSuccess');

    
    appModel.currentUserToken = loginSuccess;

    return loginSuccess;
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
