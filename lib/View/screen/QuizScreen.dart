import 'package:civilsafety_quiz/Controller/QuizCommand.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

class QuizScreen extends StatefulWidget {
  final int? quizId;
  final Key? key;

  QuizScreen({this.key, this.quizId}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  String filePath = 'assets/web/index.html';
  String quizContent = '';
  late WebViewPlusController _controller;

  @override
  void initState() {
    super.initState();
    QuizCommand().getQuiz(this.widget.quizId).then((value) {
      var quiz = value!;
      print('[QuizScreen] getQuiz $quiz');
      setState(() {
        quizContent = quiz.quizContent.replaceAll('\"', '\\"').replaceAll("'", "\'").replaceAll('\n', '');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print('[QuizScreen] quizContent $quizContent');

    return MaterialApp(
      home: Scaffold(
        body: Container(
          child: WebViewPlus(
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (controller) {
              this._controller = controller;
              controller.loadUrl(filePath);
            },
            onPageFinished: (controller) {
              _controller.webViewController.evaluateJavascript(
                  'insert_container_html("$quizContent");');
            },
          ),
        ), 
      ),
    );
  }
}
