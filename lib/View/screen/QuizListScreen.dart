import 'package:flutter/material.dart';

class QuizListScreen extends StatefulWidget {
  Function callback;

  QuizListScreen(this.callback);

  @override
  _QuizListScreenState createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            this.widget.callback(true, false);
          },
          child: Text('Log out'),
        ),
      ),
    );
  }
}
