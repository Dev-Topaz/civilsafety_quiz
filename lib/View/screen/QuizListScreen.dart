import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:civilsafety_quiz/Controller/QuizCommand.dart';
import 'package:civilsafety_quiz/Controller/UserCommand.dart';
import 'package:civilsafety_quiz/Model/AppModel.dart';
import 'package:civilsafety_quiz/Model/TaskInfo.dart';
import 'package:civilsafety_quiz/View/screen/QuizScreen.dart';
import 'package:civilsafety_quiz/View/widget/QuizListCard.dart';
import 'package:civilsafety_quiz/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizListScreen extends StatefulWidget {
  final Function callback;
  final TargetPlatform? platform;
  final bool? isOnline;

  QuizListScreen({required this.callback, this.platform, this.isOnline});

  @override
  _QuizListScreenState createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  List quizList = [];
  List allQuizList = [];
  int filterIndex = 0;
  bool isLoading = true;
  List<TaskInfo>? _tasks;
  late bool _permissionReady;
  late String _localPath;
  ReceivePort _port = ReceivePort();
  String? currentUserToken;
  bool? isOnline;

  @override
  void initState() {
    super.initState();



    if (this.widget.isOnline!) {
      _bindBackgroundIsolate();

      FlutterDownloader.registerCallback(downloadCallback);

      _permissionReady = false;
    }

    setState(() {
      isOnline = this.widget.isOnline;
    });

    _prepare();

    getUserToken();

    QuizCommand().getQuizzes().then((value) {
      setState(() {
        allQuizList = value;
        isLoading = false;
      });
      print('[QuizListScreen] initState $allQuizList');
      filterQuizList(filterIndex);
    });
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  void filterQuizList(int id) {
    print('[QuizListScreen] filterQuizList filterIndex $id');
    List tmp = [];
    switch (id) {
      case 0:
        tmp = allQuizList;
        break;
      case 1:
        for (var item in allQuizList) {
          if (item['result'] == 'Pass') tmp.add(item); 
        }
        break;
      case 2:
        for (var item in allQuizList) {
          if (item['result'] == 'Fail') tmp.add(item);
        }
        break;
      case 3:
        for (var item in allQuizList) {
          if (item['result'] == 'none' || item['result'] == 'Pending') tmp.add(item);
        }
        break;
      default:
    }

    setState(() {
      quizList = tmp;
    });

    print('[QuizListScreen] quizList $quizList');
  }

  void getUserToken() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userToken = prefs.getString('userToken') ?? '';

    setState(() {
      currentUserToken = userToken;
    });
  }

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
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(width: 10.0),
              new Text("Downloading",
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
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

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
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
        allQuizList = value;
        isLoading = false;
      });
      filterQuizList(filterIndex);
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
              TextButton(
                  onPressed: () {
                    deleteAssets(id, token);
                    Navigator.of(context).pop();
                  },
                  child: Text('Yes')),
              TextButton(
                  onPressed: () {
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
        allQuizList = value;
        isLoading = false;
      });
      filterQuizList(filterIndex);
    });
  }

  @override
  Widget build(BuildContext context) {

    bool isOnline = context.select<AppModel, bool>((value) => value.isOnline);

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text('Civil Safety Quiz App',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ListTile(
              title: Row(children: [
                Icon(Icons.close_rounded, size: 24.0, color: Colors.black,),
                SizedBox(width: 20,),
                Text('Close', style: TextStyle(color: Colors.black, fontSize: 20.0,),),
              ]),
              onTap: () {
                SystemNavigator.pop();
                exit(0);
              },
            ),
            ListTile(
              title: Row(children: [
                Icon(Icons.logout, size: 24.0, color: Colors.black,),
                SizedBox(width: 20,),
                Text('Logout', style: TextStyle(color: Colors.black, fontSize: 20.0,),),
              ]),
              onTap: () async {
                // bool online = await UserCommand().isOnlineCheck();
                // print('online $online');
                //
                // if (!online) {
                //   Navigator.pop(context);
                //
                //   setState(() {
                //     isOnline = online;
                //   });
                //
                //   Fluttertoast.showToast(
                //     msg: "You're offline!",
                //     toastLength: Toast.LENGTH_SHORT,
                //     gravity: ToastGravity.BOTTOM,
                //     timeInSecForIosWeb: 1,
                //     backgroundColor: Colors.black,
                //     textColor: Colors.white,
                //     fontSize: 16.0);
                //
                //   return;
                // }
                //
                widget.callback(true, false);

                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('userToken', '');
              },
            )
          ],
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Quiz List',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          },
        ),
      ),
      body: Center(
        child: isLoading
        ? CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          )
        : Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 25.0),
              child: Column(
                children: [
                  Container(
                    height: 60,
                    color: Colors.grey[200],
                    child: Center(
                      child: FlutterToggleTab(  
                        width: 60,  
                        borderRadius: 30,  
                        height: 30,  
                        initialIndex:0, 
                        selectedBackgroundColors: [Theme.of(context).primaryColor],  
                        selectedTextStyle: TextStyle(  
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                        unSelectedBackgroundColors: [Colors.white],
                        unSelectedTextStyle: TextStyle(  
                          color: Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                        labels: ["All", "Pass", "Fail", "Pending"],  
                        selectedLabelIndex: (index) {  
                          print("Selected Index $index");
                          setState(() {
                            filterIndex = index;
                          });
                          filterQuizList(filterIndex);
                        },  
                      ),
                    ),
                  ),
                  SizedBox(height: 15.0,),
                  Row(
                    children: [
                      Icon(Icons.bookmark_outline, size: 24.0),
                      SizedBox(width: 10.0,),
                      Text(quizList.length == 1 ? '1 Quiz' : '${quizList.length} Quizzes',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: quizList.length,
                  itemBuilder: (BuildContext context, int index) {

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
                      child: QuizListCard(
                        title: quizList[index]['name'],
                        quizType: quizList[index]['result'],
                        description: quizList[index]['description'],
                        score: quizList[index]['score'],
                        passingScore: quizList[index]['passing_score'],
                        downloaded: quizList[index]['downloaded'],
                        isOnline: isOnline,
                        examIcon: quizList[index]['exam_icon'],
                        startPressed: () {
                          if (quizList[index]['downloaded'] == 'true') Navigator.push(context, MaterialPageRoute(builder: (context) =>
                              QuizScreen(
                                id: quizList[index]['quizId'],
                                name: quizList[index]['name'],
                              ),
                            ),
                          );
                        },
                        downloadPressed: () async {
                          bool online = await UserCommand().isOnlineCheck();
                          if (!online) {
                            setState(() {
                              isOnline = online;
                            });

                            Fluttertoast.showToast(
                              msg: "You're offline!",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              fontSize: 16.0);

                            return;
                          }
                          if (isOnline && quizList[index]['downloaded'] == 'false') downloadAssets(quizList[index]['quizId'], currentUserToken!);
                        },
                        deletePressed: () {
                          if (quizList[index]['downloaded'] == 'true') _delete(quizList[index]['quizId'], currentUserToken!);
                        },
                      ),
                    );
                  }),
            ),
          ],
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

    print("DIRECTORY");
    print(directory);
    return directory?.path;
  }
}
