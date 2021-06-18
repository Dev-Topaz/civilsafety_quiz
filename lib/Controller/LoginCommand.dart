import 'package:civilsafety_quiz/Controller/BaseCommand.dart';

class LoginCommand extends BaseCommand {
  Future<bool> run(String email, String password) async {
    bool loginSuccess = await userService.login(email, password);

    appModel.currentUserToken = (loginSuccess ? email : null)!;

    return loginSuccess;
  }

  Future<bool> isOnlineCheck() async {
    print('[LoginCommand] isOnlineCheck Method calling...');
    bool isOnline = await appService.isOnlineCheck();

    appModel.isOnline = isOnline;

    return isOnline;
  }
}
