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
              WebViewPlus(
                javascriptMode: JavascriptMode.unrestricted,
                javascriptChannels: <JavascriptChannel>[
                  JavascriptChannel(
                      name: 'VideoUrl',
                      onMessageReceived: (s) {
                        print('[QuizScreen] onMessageReceived ${s.message}');
                        setState(() {
                          videoUrl = s.message;
                        });
                      }),
                  JavascriptChannel(
                      name: 'AudioUrl',
                      onMessageReceived: (s) async {
                        print('[QuizScreen] onMessageReceived ${s.message}');
                        String file_path =
                            await QuizCommand().getFilePathWithUrl(s.message);
                        print(
                            '[QuizScreen] onMessageReceived file_path $file_path');
                        
                        if (file_path != '')
                          await audioPlayer.play(file_path, isLocal: true);
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
            : IconButton(
                onPressed: () {
                  openVideo(videoUrl);
                },
                icon: Icon(Icons.video_call_sharp),
              ),
      ),
    );
  }
}
