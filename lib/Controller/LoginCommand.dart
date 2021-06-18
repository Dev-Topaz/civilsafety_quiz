import 'package:civilsafety_quiz/Controller/BaseCommand.dart';

class LoginCommand extends BaseCommand {
  Future<String> run(String email, String password) async {
    String loginSuccess = await userService.login(email, password);

    print('[LoginCommand] loginSuccess $loginSuccess');
    appModel.currentUserToken = loginSuccess;

    return loginSuccess;
  }

  Future<bool> isOnlineCheck() async {
    print('[LoginCommand] isOnlineCheck Method calling...');
    bool isOnline = await appService.isOnlineCheck();

    appModel.isOnline = isOnline;

    return isOnline;
  }
}
