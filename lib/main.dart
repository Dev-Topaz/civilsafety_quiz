import 'package:civilsafety_quiz/View/screen/HomeScreen.dart';
import 'package:civilsafety_quiz/View/screen/QuizScreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Civil Safety Quiz',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/quiz': (context) => QuizScreen(),
      },
    );
  }
}
