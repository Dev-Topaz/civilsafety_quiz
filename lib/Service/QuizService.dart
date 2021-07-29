import 'dart:convert';
import 'dart:io';

import 'package:civilsafety_quiz/Model/QuizModel.dart';
import 'package:civilsafety_quiz/const.dart';
import 'package:http/http.dart' as http;

class QuizService {
  Future<bool> sendEmail(String token, String json) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse(API_ROOT_URL + 'send_email'));

    request.fields['json'] = json;
    request.headers['Authorization'] = 'Bearer ' + token;

    bool result = true;

    await request.send().then((response) async {
      response.stream.transform(utf8.decoder).listen((value) {
        if (response.statusCode == 200) {
          result = true;
        } else {
          result = false;
        }
      });
    }).catchError((e) {
      return false;
    });

    return result;
  }

  Future<bool> saveResult(String token, String json, String userId, String quizId) async {
    var request = http.MultipartRequest('POST', Uri.parse(API_ROOT_URL + 'save_result'));

    request.fields['json'] = json;
    request.fields['user_id'] = userId;
    request.fields['exam_id'] = quizId;
    request.headers['Authorization'] = 'Bearer ' + token;

    bool result = true;

    var response = await request.send();
    final String respStr = await response.stream.bytesToString();
    print('[QuizService] saveResult respStr $respStr');

    var resultData = jsonDecode(respStr);

    if (resultData['success']) {
      result = true;
    } else {
      result = false;
    }

    return result;
  }

  Future<List> fetchQuizIndex(String token) async {
    final response = await http.get(
      Uri.parse(API_ROOT_URL + 'get_downloading_quizzes_index'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + token,
      },
    );
    final responseJson = jsonDecode(response.body);
    List quizIndex = responseJson['data']['data'];

    print('[QuizService] fetchQuizIndex $quizIndex');
    return quizIndex;
  }

  Future<List> fetchAllQuizIndex(String token) async {
    final response = await http.get(
      Uri.parse(API_ROOT_URL + 'user'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + token,
      },
    );
    final responseJson = jsonDecode(response.body);
    List quizIndex = responseJson['approved_exams'].split('@');
    quizIndex.removeLast();

    print('[QuizService] fetchAllQuizIndex $quizIndex');
    return quizIndex;
  }

  Future<QuizModel> fetchQuiz(String token, int quizId) async {
    final response = await http.get(
      Uri.parse(API_ROOT_URL + 'get_quiz/' + quizId.toString()),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + token,
      },
    );
    final responseJson = jsonDecode(response.body);

    print('[QuizService] fetchQuiz $responseJson');

    return QuizModel.fromMap(responseJson['data']['data']);
  }

  Future<List> fetchVideoAudioAssetsURL(
      String token, String quizContent) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse(API_ROOT_URL + 'get_quiz_video_audio_url'));

    request.fields['quizContent'] = quizContent;
    request.headers['Authorization'] = 'Bearer ' + token;

    List result = [];

    await request.send().then((response) async {
      response.stream.transform(utf8.decoder).listen((value) {
        if (response.statusCode == 200) {
          var responseJson = json.decode(value);

          print(
              '[QuizService] fetchVideoAudioAssetsURL ${responseJson['data']['data']}');

          if (responseJson['data']['data'] is List) {
            responseJson['data']['data'].forEach((v) {
              result.add(v);
            });
          } else {
            responseJson['data']['data'].forEach((k, v) {
              result.add(v);
            });
          }
        } else {
          throw Exception("Failed to Load!");
        }
      });
    }).catchError((e) {
      print(e);
    });

    return result;
  }

  Future<String> getQuizContent(String token, int id) async {
    final response = await http.get(
      Uri.parse(API_ROOT_URL + 'get_quiz_html/' + id.toString()),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + token,
      },
    );
    final responseJson = jsonDecode(response.body);

    print('[QuizService] getQuizContent $responseJson');

    return responseJson['data']['data'];
  }
}
