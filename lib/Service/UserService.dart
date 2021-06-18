import 'dart:convert';

import 'package:civilsafety_quiz/const.dart';
import 'package:http/http.dart' as http;

class UserService {
  Future<String> login(String email, String password) async {
    var request =
        http.MultipartRequest('POST', Uri.parse(API_ROOT_URL + 'login'));

    request.fields['email'] = email;
    request.fields['password'] = password;

    String userToken = '';

    await request.send().then((response) async {
      response.stream.transform(utf8.decoder).listen((value) {
        if (response.statusCode == 200) {
          var userData = json.decode(value);
          userToken = userData['data']['token'];
        } else {
          throw Exception("Faild to Load!");
        }
      });
    }).catchError((e) {
      print(e);
    });

    print('[UserService] userToken $userToken');

    return Future.value(userToken);
  }
}
