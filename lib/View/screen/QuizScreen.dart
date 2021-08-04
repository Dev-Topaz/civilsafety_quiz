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
  bool isPrevButtonEnable = true;
  bool isNextButtonEnable = true;
  bool isLoading = true;
  bool isReview = false;
  bool isReviewButtonShow = false;
  bool isListShow = false;
  bool isClearHotspotShow = false;
  String currentUserToken = '';
  String quizStatus = '[]';
  String buttonName = 'Next';
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    print('[QuizScreen] isPortrait $isPortrait');
    print('[QuizScreen] screenWidth $screenWidth');
    print('[QuizScreen] screenHeight $screenHeight');

    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: MediaQuery.of(context).orientation == Orientation.portrait
        ? AppBar(
          // centerTitle: true,
          actions: [
            Container(
              margin: EdgeInsets.all(10.0),
              child: ElevatedButton(
                child: Row(
                  children: [
                    Text(
                      "Exit",
                      style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColor)
                    ),
                    SizedBox(width: 5,),
                    Icon(Icons.logout_outlined, color: Theme.of(context).primaryColor, size: 18,)
                  ],
                ), 
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    )
                  )
                ),
                onPressed: () {
                  Navigator.push(context,MaterialPageRoute(builder: (context) => HomeScreen()));
                }
              ),
            ),
          ], 
          title: Text(this.widget.name!,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Theme.of(context).primaryColor,
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
                            name: 'PrevButton',
                            onMessageReceived: (s) {
                              print(
                                  '[QuizScreen] onMessageReceived PrevButton ${s.message}');
                              if (s.message == 'enable') {
                                setState(() {
                                  isPrevButtonEnable = true;
                                });
                              } else {
                                setState(() {
                                  isPrevButtonEnable = false;
                                });
                              }
                            }),
                        JavascriptChannel(
                            name: 'NextButton',
                            onMessageReceived: (s) {
                              print(
                                  '[QuizScreen] onMessageReceived NextButton ${s.message}');
                              if (s.message == 'enable') {
                                setState(() {
                                  isNextButtonEnable = true;
                                });
                              } else {
                                setState(() {
                                  isNextButtonEnable = false;
                                });
                              }
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
                                print('[QuizScreen] currentUserToken $currentUserToken');
                                _controller.webViewController.evaluateJavascript('show_progress_bar();');
                                await QuizCommand().sendEmail(currentUserToken, s.message);
                                await QuizCommand().saveResultAtServer(currentUserToken, s.message, this.widget.id.toString());
                                _controller.webViewController.evaluateJavascript('hide_progress_bar();');
                              } else {
                                await QuizCommand().saveResult(s.message, this.widget.id.toString());
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
                            name: 'ClearHotspot',
                            onMessageReceived: (s) async {
                              print(
                                  '[QuizScreen] onMessageReceived ClearHotspot ${s.message}');
                              if (s.message == 'hide') {
                                setState(() {
                                  isClearHotspotShow = false;
                                });
                              } else {
                                setState(() {
                                  isClearHotspotShow = true;
                                });
                              }
                            }),
                        JavascriptChannel(
                            name: 'AudioStop',
                            onMessageReceived: (s) async {
                              print(
                                  '[QuizScreen] onMessageReceived AudioStop ${s.message}');
                              await audioPlayer.stop();
                            }),
                        JavascriptChannel(
                            name: 'ButtonName',
                            onMessageReceived: (s) async {
                              print(
                                  '[QuizScreen] onMessageReceived ButtonName ${s.message}');
                              setState(() {
                                buttonName = s.message;
                              });
                            }),
                      ].toSet(),
                      onWebViewCreated: (controller) {
                        this._controller = controller;
                        controller.loadUrl(filePath);
                      },
                      onPageFinished: (controller) async {
                        _controller.webViewController.evaluateJavascript('set_screen_size($screenWidth, $screenHeight);');
                        _controller.webViewController.evaluateJavascript('insert_container_html("$quizContent");');
                        // _controller.webViewController.evaluateJavascript('set_portrait("$isPortrait");');
                        
                        setState(() {
                          isLoading = false;
                        });
                      },
                    ),
                  ),
                  CustomLayout(
                    layout: isPortrait == 'true' ? 'row' : 'column',
                    size: 65.0,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MediaQuery.of(context).orientation != Orientation.portrait
                      ? CustomTextIconButton(
                        onPressed: () {
                          Navigator.push(context,MaterialPageRoute(builder: (context) => HomeScreen()));
                        },
                        icon: Icon(Icons.logout, color: Colors.white),
                        label: Text('Exit', style: TextStyle(fontSize: 14.0, color: Colors.white),),
                      )
                      : Container(),
                      // MediaQuery.of(context).orientation != Orientation.portrait
                      // ? isListShow
                      //   ? CustomTextIconButton(
                      //     onPressed: () {
                      //       _controller.webViewController.evaluateJavascript('hide_list_button();');
                      //       setState(() {
                      //         isListShow = false;
                      //       });
                      //     },
                      //     icon: Icon(Icons.close, color: Colors.white),
                      //     label: Text('Close List', style: TextStyle(fontSize: 14.0, color: Colors.white),),
                      //   )
                      //   : CustomTextIconButton(
                      //     onPressed: () {
                      //       _controller.webViewController.evaluateJavascript('click_list_button();');
                      //       setState(() {
                      //         isListShow = true;
                      //       });
                      //     },
                      //     icon: Icon(Icons.list_sharp, color: Colors.white),
                      //     label: Text('Quiz List', style: TextStyle(fontSize: 14.0, color: Colors.white)),
                      //   )
                      // : Container(),
                      videoUrl != '#'
                      ? CustomTextIconButton(
                        onPressed: () {
                          openVideo(videoUrl);
                        },
                        icon: Icon(
                          Icons.video_camera_front,
                          color: Colors.white,
                          size: 30.0,
                        ),
                        label: Text('Play Video',
                          style: TextStyle(color: Colors.white, fontSize: 14.0),
                        ),
                      )
                      : Container(),
                      isClearHotspotShow
                      ? CustomTextIconButton(
                        onPressed: () {
                          _controller.webViewController.evaluateJavascript('clear_hotspots();');
                        },
                        icon: Icon(
                          Icons.clear_all,
                          color: Colors.white,
                          size: 30.0,
                        ),
                        label: Text('Clear hotspot',
                          style: TextStyle(color: Colors.white, fontSize: 14.0),
                        ),
                      )
                      : Container(),
                      isReviewButtonShow
                      ? CustomTextIconButton(
                        onPressed: () {
                          if (isReviewButtonShow) {
                            _controller.webViewController.evaluateJavascript('review_button();');
                            setState(() {
                              buttonName = 'Next';
                            });  
                          }
                        },
                        icon: Icon(Icons.rate_review_sharp,
                          color: Colors.white,
                        ), 
                        label: Text('Review',
                          style: TextStyle(color: Colors.white, fontSize: 14.0),
                        ))
                      : Container(),
                      isReview
                      ? CustomTextIconButton(
                        color: isPrevButtonEnable ? Theme.of(context).primaryColor : Colors.grey,
                        onPressed: () {
                          if (isReview) _controller.webViewController.evaluateJavascript('review_prev_button();');
                        },
                        icon: Icon(
                          Icons.navigate_before_rounded,
                          color: Colors.white,
                          size: 30.0,
                        ),
                        label: Text('Previous',
                          style: TextStyle(color: Colors.white, fontSize: 14.0),
                        ),
                      )
                      : Container(),
                      buttonName == 'Close'
                      ? Container()
                      : CustomTextIconButton(
                        color: isNextButtonEnable ? Theme.of(context).primaryColor : Colors.grey,
                        onPressed: () {
                          if (isReview) {
                            _controller.webViewController.evaluateJavascript('review_next_button();');
                          } else {
                            _controller.webViewController.evaluateJavascript('click_preview_button();');
                          }
                        },
                        icon: Icon(
                          Icons.navigate_next_rounded,
                          color: Colors.white,
                          size: 30.0,
                        ),
                        label: Text(buttonName,
                          style: TextStyle(color: Colors.white, fontSize: 14.0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                )
              : Stack(),
            ],
          ),
        ),
      ),
    );
  }
}
