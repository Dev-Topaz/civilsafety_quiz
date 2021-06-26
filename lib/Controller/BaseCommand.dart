import 'package:civilsafety_quiz/Model/AppModel.dart';
import 'package:civilsafety_quiz/Model/QuizModel.dart';
import 'package:civilsafety_quiz/Model/UserModel.dart';
import 'package:civilsafety_quiz/Service/AppService.dart';
import 'package:civilsafety_quiz/Service/QuizService.dart';
import 'package:civilsafety_quiz/Service/SqliteService.dart';
import 'package:civilsafety_quiz/Service/UserService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

late BuildContext _mainContext;
void init(BuildContext c) => _mainContext = c;

class BaseCommand {
  UserModel userModel = _mainContext.read();
  QuizModel quizModel = _mainContext.read();
  AppModel appModel = _mainContext.read();

  UserService userService = _mainContext.read();
  AppService appService = _mainContext.read();
  SqliteService sqliteService = _mainContext.read();
  QuizService quizService = _mainContext.read();
}
