import 'dart:convert';
import 'dart:io';

import 'package:civilsafety_quiz/Model/QuizModel.dart';
import 'package:civilsafety_quiz/const.dart';
import 'package:http/http.dart' as http;

class QuizService {
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
      Uri.parse(API_ROOT_URL + 'get_all_index'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + token,
      },
    );
    final responseJson = jsonDecode(response.body);
    List quizIndex = responseJson['data']['data'];

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

  Future<List> fetchAllAssetsURL(String token, int id) async {
    final response = await http.get(
      Uri.parse(API_ROOT_URL + 'get_quiz_assets_url/' + id.toString()),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ' + token,
      },
    );
    final responseJson = jsonDecode(response.body);

    print('[QuizService] fetchQuiz $responseJson');

    return responseJson['data']['data'];
  }
}
