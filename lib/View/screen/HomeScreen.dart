import 'package:civilsafety_quiz/View/screen/LoginScreen.dart';
import 'package:civilsafety_quiz/View/screen/QuizListScreen.dart';
import 'package:civilsafety_quiz/View/screen/RegisterScreen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoggedin = false;
  bool hasAccount = true;

  void callback(bool hasAccount, bool isLoggedin) {
    setState(() {
      this.hasAccount = hasAccount;
      this.isLoggedin = isLoggedin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: isLoggedin
          ? QuizListScreen(this.callback)
          : (hasAccount
              ? LoginScreen(this.callback)
              : RegisterScreen(this.callback)),
    );
  }
}
