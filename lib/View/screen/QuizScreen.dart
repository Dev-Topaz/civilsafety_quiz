import 'package:civilsafety_quiz/Controller/QuizCommand.dart';
import 'package:civilsafety_quiz/Model/AppModel.dart';
import 'package:civilsafety_quiz/View/screen/HomeScreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';

class QuizScreen extends StatefulWidget {
  // final int? quizId;
  final int? id;
  final Key? key;
  // Function? updateResult;
  // Function? updateScore;

  QuizScreen({
    this.key, 
    this.id, 
    // this.updateResult, 
    // this.updateScore
    }) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  String filePath = 'assets/web/index.html';

  // String filePath = 'assets/web/test.html';
  String quizContent = '';
  String videoUrl = '#';
  bool isLoading = true;
  bool isReview = false;
  bool isReviewButtonShow = false;
  bool isListShow = false;
  late WebViewPlusController _controller;
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);

    QuizCommand().getQuizContent(this.widget.id!).then((value) {
      setState(() {
        quizContent = value
            .replaceAll('\"', '\\"')
            .replaceAll("'", "\'")
            .replaceAll('\n', '');
      });
    });
  }

  void openVideo(String videoUrl) async {
    String fileId = await QuizCommand().getFileIdWithUrl(videoUrl);
    FlutterDownloader.open(taskId: fileId);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('[QuizScreen] quizContent $quizContent');

    String currentUserToken =
        context.select<AppModel, String>((value) => value.currentUserToken);

    bool isOnline = context.select<AppModel, bool>((value) => value.isOnline);

    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          child: Stack(
            children: [
              Container(
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width - 50,
                      height: MediaQuery.of(context).size.height,
                      child: WebViewPlus(
                        gestureRecognizers: Set()
                        ..add(
                          Factory<DragGestureRecognizer>(
                            () => VerticalDragGestureRecognizer(),
                          ),
                        ),
                        javascriptMode: JavascriptMode.unrestricted,
                        javascriptChannels: <JavascriptChannel>[
                          JavascriptChannel(
                              name: 'VideoUrl',
                              onMessageReceived: (s) {
                                print(
                                    '[QuizScreen] onMessageReceived ${s.message}');
                                setState(() {
                                  videoUrl = s.message;
                                });
                              }),
                          JavascriptChannel(
                              name: 'ReviewButtonShow',
                              onMessageReceived: (s) {
                                setState(() {
                                  isReviewButtonShow = s.message == 'true';
                                });
                              }),
                          JavascriptChannel(
                              name: 'AudioUrl',
                              onMessageReceived: (s) async {
                                print(
                                    '[QuizScreen] onMessageReceived AudioUrl ${s.message}');
                                await audioPlayer.stop();
                                String filePath = await QuizCommand()
                                    .getFilePathWithUrl(s.message);
                                print(
                                    '[QuizScreen] onMessageReceived AudioUrl filePath $filePath');

                                if (filePath != '')
                                  await audioPlayer.play(filePath,
                                      isLocal: true);
                              }),
                          JavascriptChannel(
                              name: 'QuizResult',
                              onMessageReceived: (s) async {
                                print(
                                    '[QuizScreen] onMessageReceived QuizResult ${s.message}');

                                print('[QuizScreen] isOnline $isOnline');
                                if (isOnline) {
                                  _controller.webViewController.evaluateJavascript('show_progress_bar();');
                                  await QuizCommand().sendEmail(currentUserToken, s.message);
                                  _controller.webViewController.evaluateJavascript('hide_progress_bar();');
                                } else {
                                  await QuizCommand().saveResult(s.message);
                                }
                              }),
                          JavascriptChannel(
                              name: 'Result',
                              onMessageReceived: (s) async {
                                print(
                                    '[QuizScreen] onMessageReceived Result ${s.message}');

                                await QuizCommand().updateQuizResult(s.message, this.widget.id!);
                                // this.widget.updateResult!(this.widget.id!, s.message);
                              }),
                          JavascriptChannel(
                              name: 'Score',
                              onMessageReceived: (s) async {
                                print(
                                    '[QuizScreen] onMessageReceived Score ${s.message}');

                                await QuizCommand().updateQuizScore(int.parse(s.message), this.widget.id!);
                                // this.widget.updateScore!(this.widget.id!, int.parse(s.message));
                              }),
                          JavascriptChannel(
                              name: 'Review',
                              onMessageReceived: (s) async {
                                print(
                                    '[QuizScreen] onMessageReceived Review ${s.message}');
                                setState(() {
                                  isReview = true;
                                });
                              }),
                          JavascriptChannel(
                              name: 'AudioStop',
                              onMessageReceived: (s) async {
                                print(
                                    '[QuizScreen] onMessageReceived AudioStop ${s.message}');
                                await audioPlayer.stop();
                              }),
                        ].toSet(),
                        onWebViewCreated: (controller) {
                          this._controller = controller;
                          controller.loadUrl(filePath);
                        },
                        onPageFinished: (controller) {
                          _controller.webViewController.evaluateJavascript(
                              'insert_container_html("$quizContent");');
                          setState(() {
                            isLoading = false;
                          });
                        },
                      ),
                    ),
                    Container(
                      width: 50.0,
                      // decoration: BoxDecoration(
                      //   border: Border(
                      //     left: BorderSide(
                      //         width: 3.0, color: Colors.blue),
                      //   ),
                      //   color: Colors.white,
                      // ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 30.0,
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(context,MaterialPageRoute(builder: (context) =>HomeScreen()));
                            }, 
                          icon: Icon(Icons.arrow_back,
                            color: Colors.blue,
                            size: 30.0,
                          )),
                          isListShow
                              ? IconButton(
                                  onPressed: () {
                                    _controller.webViewController
                                        .evaluateJavascript(
                                            'hide_list_button();');
                                    setState(() {
                                      isListShow = false;
                                    });
                                  },
                                  icon: Icon(Icons.close,
                                      color: Colors.blue, size: 30.0))
                              : IconButton(
                                  onPressed: () {
                                    _controller.webViewController
                                        .evaluateJavascript(
                                            'click_list_button();');
                                    setState(() {
                                      isListShow = true;
                                    });
                                  },
                                  icon: Icon(Icons.list_sharp,
                                      color: Colors.blue, size: 30.0)),
                          isReviewButtonShow
                          ? IconButton(
                            onPressed: () {
                              _controller.webViewController
                                      .evaluateJavascript(
                                          'review_button();');
                            }, 
                            icon: Icon(Icons.rate_review_sharp,
                              color:Colors.blue,
                              size: 30.0
                            )
                          )
                          :SizedBox(height: 0),
                          Expanded(child: Container()),
                          isReview
                              ? IconButton(
                                  onPressed: () {
                                    _controller.webViewController
                                      .evaluateJavascript(
                                          'review_prev_button();');
                                  },
                                  icon: Icon(
                                    Icons.navigate_before_rounded,
                                    color: Colors.blue,
                                    size: 30.0,
                                  ))
                              : SizedBox(
                                  height: 0,
                                ),
                          IconButton(
                              onPressed: () {
                                if (isReview) {
                                  _controller.webViewController
                                      .evaluateJavascript(
                                          'review_next_button();');
                                } else {
                                  _controller.webViewController
                                      .evaluateJavascript(
                                          'click_preview_button();');
                                }
                              },
                              icon: Icon(
                                Icons.navigate_next_rounded,
                                color: Colors.blue,
                                size: 30.0,
                              )),
                          SizedBox(
                            height: 30.0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Colors.black,
                      ),
                    )
                  : Stack(),
            ],
          ),
        ),
        floatingActionButton: (videoUrl == '#')
            ? null
            : Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 70.0, 20.0),
                child: IconButton(
                  onPressed: () {
                    openVideo(videoUrl);
                  },
                  icon: Icon(
                    Icons.video_call_sharp,
                    size: 50.0,
                    color: Colors.blue,
                  ),
                ),
              ),
      ),
    );
  }
}
