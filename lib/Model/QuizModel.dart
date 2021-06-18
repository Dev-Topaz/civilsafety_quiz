import 'package:flutter/material.dart';

class QuizModel extends ChangeNotifier {
  late String quizId;
  late String title;
  late String description;
  late int passingScore;
  late String stuffEmail;
  late String quizContent;
  late bool isDownload;
}
