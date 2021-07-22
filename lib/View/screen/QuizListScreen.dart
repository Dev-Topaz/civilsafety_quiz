import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:civilsafety_quiz/Controller/QuizCommand.dart';
import 'package:civilsafety_quiz/Model/AppModel.dart';
import 'package:civilsafety_quiz/Model/TaskInfo.dart';
import 'package:civilsafety_quiz/View/screen/QuizScreen.dart';
import 'package:civilsafety_quiz/View/widget/CustomBanner.dart';
import 'package:civilsafety_quiz/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizListScreen extends StatefulWidget {
  Function callback;
  final TargetPlatform? platform;
  final bool? isOnline;

  QuizListScreen({required this.callback, this.platform, this.isOnline});

  @override
  _QuizListScreenState createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  List quizList = [];
  bool isLoading = true;
  List<TaskInfo>? _tasks;
  late bool _permissionReady;
  late String _localPath;
  ReceivePort _port = ReceivePort();
  String? currentUserToken;

  @override
  void initState() {
    super.initState();

    if (this.widget.isOnline!) {
      _bindBackgroundIsolate();

      FlutterDownloader.registerCallback(downloadCallback);

      _permissionReady = false;
    }

    _prepare();

    getUserToken();

    QuizCommand().getQuizzes().then((value) {
      print('[QuizListScreen] initState $value');
      setState(() {
        quizList = value;
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  void getUserToken() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userToken = prefs.getString('userToken') ?? '';

    setState(() {
      currentUserToken = userToken;
    });
  }

  // void updateResult(int id, String result) {
  //   setState(() {
  //     quizList[id]['result'] = result;
  //   });
  // }

  // void updateScore(int id, int score) {
  //   setState(() {
  //     quizList[id]['score'] = score;
  //   });
  // }

  void _onDownloading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
            child: Container(
          padding: EdgeInsets.all(30.0),
          child: new Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              new CircularProgressIndicator(
                color: Colors.black,
              ),
              SizedBox(width: 10.0),
              new Text("Downloading"),
            ],
          ),
        ));
      },
    );
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      if (debug) {
        print('UI Isolate Callback: $data');
      }
      String? id = data[0];
      DownloadTaskStatus? status = data[1];
      int? progress = data[2];

      if (_tasks != null && _tasks!.isNotEmpty) {
        final task = _tasks!.firstWhere((task) => task.taskId == id);
        setState(() {
          task.status = status;
          task.progress = progress;
        });
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    if (debug) {
      print(
          'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    }
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  void _requestDownload(TaskInfo task) async {
    task.taskId = await FlutterDownloader.enqueue(
        url: task.link!,
        headers: {"auth": "test_for_sql_encoding"},
        savedDir: _localPath,
        showNotification: true,
        openFileFromNotification: true);
  }

  void downloadAssets(int id, String token) async {
    if (debug) print('[QuizListScreen] download_assets $id');

    _onDownloading();

    await QuizCommand().downloadAssets(token, id, _localPath);

    QuizCommand().getQuizzes().then((value) {
      print('[QuizListScreen] downloadAssets $value');
      setState(() {
        quizList = value;
        isLoading = false;
      });
    });

    Navigator.pop(context);
  }

  void _delete(int id, String token) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Please Confirm'),
            content: Text('Are you sure to remove assets?'),
            actions: [
              // The "Yes" button
              TextButton(
                  onPressed: () {
                    deleteAssets(id, token);

                    // Close the dialog
                    Navigator.of(context).pop();
                  },
                  child: Text('Yes')),
              TextButton(
                  onPressed: () {
                    // Close the dialog
                    Navigator.of(context).pop();
                  },
                  child: Text('No'))
            ],
          );
        });
  }

  void deleteAssets(int id, String token) async {
    await QuizCommand().deleteAssets(token, id, _localPath);

    QuizCommand().getQuizzes().then((value) {
      print('[QuizListScreen] deleteAssets $value');
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
                    onPressed: () async {
                      widget.callback(true, false);

                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setString('userToken', '');
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

                      double rating = (quizList[index]['score'] ?? 0) / quizList[index]['passing_score'] < 1 ? (quizList[index]['score'] ?? 0) / quizList[index]['passing_score'] * 5 : 5;

                      return Card(
                        clipBehavior: Clip.antiAlias,
                        shadowColor: Colors.grey,
                        margin: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0),
                        child: CustomBanner(
                          isBanner: quizList[index]['downloaded'] == 'false',
                          message: 'UPDATED',
                          child: Column(
                            children: [
                              ListTile(
                                // leading: Icon(Icons.arrow_drop_down_circle),
                                title: Row(
                                  children: [
                                    Text(quizList[index]['name']),
                                    SizedBox(width: 10.0),
                                    Text(quizList[index]['result'] ?? '',
                                      style: TextStyle(
                                        color: quizList[index]['result'] == 'Pass' ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.0,
                                      ),
                                    ),
                                  ],
                                ), 
                                subtitle: Text(
                                  'Passing score: ${quizList[index]['passing_score']}',
                                  style: TextStyle(
                                      color: Colors.black.withOpacity(0.6)),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text('Score: ' + (quizList[index]['score'] ?? 0).toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  RatingBar.builder(
                                    initialRating: rating,
                                    minRating: rating,
                                    maxRating: rating,
                                    itemSize: 24.0,
                                    allowHalfRating: true,
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (rating) {
                                      print(rating);
                                    },
                                  ),
                                ],
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
                                alignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  quizList[index]['downloaded'] == 'true'
                                      ? TextButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    QuizScreen(
                                                        id: quizList[index]['id'],
                                                        ),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'Start Quiz',
                                            style: TextStyle(
                                              color: Color(0xFF6200EE),
                                            ),
                                          ),
                                        )
                                      : SizedBox(
                                          width: 0,
                                        ),
                                  this.widget.isOnline! &&
                                          quizList[index]['downloaded'] ==
                                              'false'
                                      ? IconButton(
                                          onPressed: () {
                                            downloadAssets(
                                                quizList[index]['id'],
                                                currentUserToken!);
                                          },
                                          icon: Icon(Icons.download))
                                      : IconButton(
                                          onPressed: () {
                                            _delete(quizList[index]['id'], currentUserToken!);
                                          },
                                          icon: Icon(Icons.delete)
                                        ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
            ),
          );
  }

  Future<bool> _checkPermission() async {
    if (widget.platform == TargetPlatform.android) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  Future<Null> _prepare() async {
    final tasks = await FlutterDownloader.loadTasks();

    _permissionReady = await _checkPermission();

    if (_permissionReady) {
      await _prepareSaveDir();
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _prepareSaveDir() async {
    _localPath =
        (await _findLocalPath())! + Platform.pathSeparator + 'Download';

    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  Future<String?> _findLocalPath() async {
    final directory = widget.platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    return directory?.path;
  }
}
