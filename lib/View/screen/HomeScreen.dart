import 'package:civilsafety_quiz/Controller/LoginCommand.dart';
import 'package:civilsafety_quiz/Model/AppModel.dart';
import 'package:civilsafety_quiz/View/screen/LoginScreen.dart';
import 'package:civilsafety_quiz/View/screen/QuizListScreen.dart';
import 'package:civilsafety_quiz/View/screen/RegisterScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoggedin = false;
  bool hasAccount = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    LoginCommand().isOnlineCheck().then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  void callback(bool hasAccount, bool isLoggedin) {
    setState(() {
      this.hasAccount = hasAccount;
      this.isLoggedin = isLoggedin;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isOnline = context.select<AppModel, bool>((value) => value.isOnline);
    print('[HomeScreen] isOnline $isOnline');

    return isLoading
        ? CircularProgressIndicator(
            color: Colors.black87,
          )
        : Container(
            child: isLoggedin || !isOnline
                ? QuizListScreen(this.callback)
                : (hasAccount
                    ? LoginScreen(this.callback)
                    : RegisterScreen(this.callback)),
          );
  }
}
