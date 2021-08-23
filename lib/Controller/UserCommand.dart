import 'package:civilsafety_quiz/Controller/BaseCommand.dart';

class UserCommand extends BaseCommand {

  Future<Map> login(String email, String password) async {
    await sqliteService.createDatabase();
    Map loginResponse = await userService.login(email, password);

    print('[UserCommand] loginResponse $loginResponse');

    if (loginResponse['success'] == 'success') {
      bool success = await sqliteService.createUser(loginResponse['userId'], email, password);
      print('[Sqlite] Create user $success');
      if(success == true)
        appModel.currentUserToken = loginResponse['userToken'];
    } else {
      appModel.currentUserToken = '';
    }

    return loginResponse;
  }

  Future<Map> offlineLogin(String email, String password) async {
    return await sqliteService.login(email, password);
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
  
  Future<bool> createDatabase() async {
    print('[Create Database]');
    await sqliteService.createDatabase();
    return true;
  }

}
