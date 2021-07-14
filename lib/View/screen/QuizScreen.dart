import 'package:civilsafety_quiz/Controller/QuizCommand.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import 'package:audioplayers/audioplayers.dart';

class QuizScreen extends StatefulWidget {
  // final int? quizId;
  final int? id;
  final Key? key;

  QuizScreen({this.key, this.id}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  String filePath = 'assets/web/index.html';
  String quizContent = '';
  String videoUrl = '#';
  bool isLoading = true;
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

    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          child: Stack(
            children: [
              Container(
                child: Row(
                  children: [
                    Expanded(
                      child: WebViewPlus(
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
                          IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.list_sharp,
                                  color: Colors.blue, size: 30.0)),
                          IconButton(
                              onPressed: () {
                                _controller.webViewController
                                    .evaluateJavascript(
                                        'click_preview_button();');
                              },
                              icon: Icon(
                                Icons.navigate_next_rounded,
                                color: Colors.blue,
                                size: 30.0,
                              )),
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
                  icon: Icon(Icons.video_call_sharp,
                    size: 50.0,
                    color: Colors.blue,
                  ),
                ),
              ),
      ),
    );
  }
}
