import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

class QuizScreen extends StatefulWidget {
  QuizScreen({Key? key}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  String filePath = 'assets/web/index.html';
  late WebViewPlusController _controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: WebViewPlus(
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (controller) {
          this._controller = controller;
          controller.loadUrl(filePath);
        },
        onPageFinished: (controller) {
          _controller.webViewController.evaluateJavascript(
              'insert_container_html("OKOKOKOKOKOKOKOKOKOKOKOKOKOKOKOKOKOK TE!");');
        },
      )),
    );
  }
}
