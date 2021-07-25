import 'package:civilsafety_quiz/Controller/QuizCommand.dart';
import 'package:civilsafety_quiz/Model/AppModel.dart';
import 'package:civilsafety_quiz/View/screen/HomeScreen.dart';
import 'package:civilsafety_quiz/View/widget/CustomLayout.dart';
import 'package:civilsafety_quiz/View/widget/CustomTextIconButton.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';

class QuizScreen extends StatefulWidget {
  // final int? quizId;
  final int? id;
  final Key? key;
  final String? name;
  // Function? updateResult;
  // Function? updateScore;

  QuizScreen({
    this.key, 
    this.id, 
    this.name,
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
  String currentUserToken = '';
  String quizStatus = '[]';
  late WebViewPlusController _controller;
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeRight, DeviceOrientation.portraitUp, DeviceOrientation.landscapeLeft]);

    getUserToken();

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

  void getUserToken() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userToken = prefs.getString('userToken') ?? '';

    setState(() {
      currentUserToken = userToken;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('[QuizScreen] quizContent $quizContent');
    
    bool isOnline = context.select<AppModel, bool>((value) => value.isOnline);
    // String isPortrait = MediaQuery.of(context).orientation == Orientation.portrait ? 'true' : 'false';
    String isPortrait = 'true';

    print('[QuizScreen] isPortrait $isPortrait');

    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: isPortrait == 'true'
        ? AppBar(
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.push(context,MaterialPageRoute(builder: (context) =>HomeScreen()));
            }, 
          icon: Icon(Icons.arrow_back,
            color: Colors.blue,
            size: 30.0,
          )),
          title: Text(this.widget.name!,
            style: TextStyle(color: Colors.blue),
          ),
          backgroundColor: Colors.white,
        )
        : null,
        body: Container(
          child: Stack(
            children: [
              CustomLayout(
                layout: isPortrait == 'true' ? 'column' : 'row',
                children: [
                  Expanded(
                    // width: isPortrait == 'true' ? MediaQuery.of(context).size.width : MediaQuery.of(context).size.width - 50,
                    // height: isPortrait == 'true' ? MediaQuery.of(context).size.height - 169 : MediaQuery.of(context).size.height,
                    child: WebViewPlus(
                      gestureRecognizers: [
                            Factory(() => EagerGestureRecognizer()),
                        ].toSet(),
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
                      onPageFinished: (controller) async {
                        _controller.webViewController.evaluateJavascript('insert_container_html("$quizContent");');
                        // _controller.webViewController.evaluateJavascript('insert_container_html("$quizContent");');
                        // _controller.webViewController.evaluateJavascript('set_portrait("$isPortrait");');
                        
                        setState(() {
                          isLoading = false;
                        });
                      },
                    ),
                  ),
                  CustomLayout(
                    layout: isPortrait == 'true' ? 'row' : 'column',
                    size: 50.0,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      isListShow
                      ? CustomTextIconButton(
                        onPressed: () {
                          _controller.webViewController.evaluateJavascript('hide_list_button();');
                        },
                        icon: Icon(Icons.close, color: Colors.blue),
                        label: Text('Close List', style: TextStyle(fontSize: 8.0, color: Colors.blue),),
                      )
                      : CustomTextIconButton(
                        onPressed: () {
                          _controller.webViewController.evaluateJavascript('click_list_button();');
                        },
                        icon: Icon(Icons.list_sharp, color: Colors.blue),
                        label: Text('Quiz List', style: TextStyle(fontSize: 8.0, color: Colors.blue)),
                      ),
                      CustomTextIconButton(
                        onPressed: () {
                          if (isReviewButtonShow) _controller.webViewController.evaluateJavascript('review_button();');
                        },
                        icon: Icon(Icons.rate_review_sharp,
                          color: isReviewButtonShow ? Colors.blue : Colors.white,
                        ), 
                        label: Text('Review',
                          style: TextStyle(color: isReviewButtonShow ? Colors.blue : Colors.white, fontSize: 8.0),
                        )),
                      CustomTextIconButton(
                        onPressed: () {
                          if (isReview) _controller.webViewController.evaluateJavascript('review_prev_button();');
                        },
                        icon: Icon(
                          Icons.navigate_before_rounded,
                          color: isReview ? Colors.blue : Colors.white,
                          size: 30.0,
                        ),
                        label: Text('Previous',
                          style: TextStyle(color: isReview ? Colors.blue : Colors.white, fontSize: 8.0),
                        ),
                      ),
                      CustomTextIconButton(
                        onPressed: () {
                          if (isReview) {
                            _controller.webViewController.evaluateJavascript('review_next_button();');
                          } else {
                            _controller.webViewController.evaluateJavascript('click_preview_button();');
                          }
                        },
                        icon: Icon(
                          Icons.navigate_next_rounded,
                          color: Colors.blue,
                          size: 30.0,
                        ),
                        label: Text('Next',
                          style: TextStyle(color: Colors.blue, fontSize: 8.0),
                        ),
                      ),
                    ],
                  ),
                ],
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
