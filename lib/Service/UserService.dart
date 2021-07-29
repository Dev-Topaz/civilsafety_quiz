import 'dart:convert';

import 'package:civilsafety_quiz/const.dart';
import 'package:http/http.dart' as http;

class UserService {
  Future<Map> login(String email, String password) async {
    Map result;
    var request =
        http.MultipartRequest('POST', Uri.parse(API_ROOT_URL + 'login'));

    request.fields['email'] = email;
    request.fields['password'] = password;

    String userToken = '';

    var response = await request.send();
    final String respStr = await response.stream.bytesToString();
    print('[UserService] login respStr $respStr');
    var userData = json.decode(respStr);

    if (userData['success']) {
      userToken = userData['data']['token'];
      result = {
        'success': 'success',
        'userToken': userToken,
      };
    } else {
      result = {
        'success': 'error',
        'message': userData['message'],
      };
    }

    print('[UserService] login: result $result');

    return result;
  }

  Future<String> register(String username, String email, String password,
      String confirmPassword) async {
    var request =
        http.MultipartRequest('POST', Uri.parse(API_ROOT_URL + 'register'));

    request.fields['name'] = username;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['c_password'] = confirmPassword;

    String userToken = '';

    var response = await request.send();
    final String respStr = await response.stream.bytesToString();
    print('[UserService] login respStr $respStr');
    var userData = json.decode(respStr);

    if (userData['success']) {
      userToken = userData['data']['token'];
    } else {
      userToken = '';
    }

    print('[UserService] register: userToken $userToken');

    return userToken;
  }
}
