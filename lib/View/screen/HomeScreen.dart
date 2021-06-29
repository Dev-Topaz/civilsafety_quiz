import 'package:civilsafety_quiz/Controller/UserCommand.dart';
import 'package:civilsafety_quiz/Model/AppModel.dart';
import 'package:civilsafety_quiz/View/screen/LoginScreen.dart';
import 'package:civilsafety_quiz/View/screen/QuizListScreen.dart';
import 'package:civilsafety_quiz/View/screen/RegisterScreen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
    UserCommand().isOnlineCheck().then((value) {
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
    late bool isOnline;

    final platform = Theme.of(context).platform;

    if (!isLoading) {
      isOnline = context.select<AppModel, bool>((value) => value.isOnline);

      if (!isOnline) {
        Fluttertoast.showToast(
            msg: "You're offline!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 16.0);
      }
      print('[HomeScreen] isOnline $isOnline');
    }

    return isLoading
        ? CircularProgressIndicator(
            color: Colors.black87,
          )
        : Container(
            child: isLoggedin || !isOnline
                ? QuizListScreen(
                  callback: callback,
                  platform: platform,
                )
                : (hasAccount
                    ? LoginScreen(this.callback)
                    : RegisterScreen(this.callback)),
          );
  }
}
