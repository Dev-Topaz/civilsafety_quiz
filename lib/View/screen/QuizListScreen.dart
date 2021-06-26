import 'package:civilsafety_quiz/Controller/QuizCommand.dart';
import 'package:flutter/material.dart';

class QuizListScreen extends StatefulWidget {
  Function callback;

  QuizListScreen(this.callback);

  @override
  _QuizListScreenState createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  List quizList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    QuizCommand().getQuizzes().then((value) {
      print('[QuizListScreen] getQuizzes $value');
      setState(() {
        quizList = value;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? CircularProgressIndicator(
            color: Colors.grey,
          )
        : Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                    onPressed: () {
                      this.widget.callback(true, false);
                    },
                    icon: Icon(
                      Icons.logout,
                      color: Colors.black,
                    ))
              ],
              centerTitle: true,
              backgroundColor: Colors.white,
              title: Text(
                'Quiz List',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            body: Center(
              child: Container(
                child: ListView.builder(
                    itemCount: quizList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        shadowColor: Colors.grey,
                        margin: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0),
                        child: Column(
                          children: [
                            ListTile(
                              // leading: Icon(Icons.arrow_drop_down_circle),
                              title: Text(quizList[index]['title']),
                              subtitle: Text(
                                'Passing score: ${quizList[index]['passing_score']}',
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.6)),
                              ),
                            ),
                            // Image.asset('assets/images/quiz_default.jpg'),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                quizList[index]['description'],
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.6)),
                              ),
                            ),
                            ButtonBar(
                              alignment: MainAxisAlignment.start,
                              children: [
                                TextButton(onPressed: () {},
                                  child: Text('Start Quiz',
                                    style: TextStyle(
                                      color: Color(0xFF6200EE),
                                    ),
                                  ),
                                ),
                                IconButton(
                                    onPressed: () {},
                                    icon: Icon(Icons.download)),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
              ),
            ),
          );
  }
}
