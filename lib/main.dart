import 'package:civilsafety_quiz/Model/AppModel.dart';
import 'package:civilsafety_quiz/Model/QuizModel.dart';
import 'package:civilsafety_quiz/Model/UserModel.dart';
import 'package:civilsafety_quiz/Service/AppService.dart';
import 'package:civilsafety_quiz/Service/QuizService.dart';
import 'package:civilsafety_quiz/Service/SqliteService.dart';
import 'package:civilsafety_quiz/Service/UserService.dart';
import 'package:civilsafety_quiz/View/screen/HomeScreen.dart';
import 'package:civilsafety_quiz/View/screen/QuizScreen.dart';
import 'package:civilsafety_quiz/Controller/BaseCommand.dart' as Commands;
import 'package:civilsafety_quiz/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: debug);
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext _) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (c) => AppModel()),
        ChangeNotifierProvider(create: (c) => UserModel()),
        ChangeNotifierProvider(create: (c) => QuizModel()),
        Provider(create: (c) => UserService()),
        Provider(create: (c) => AppService()),
        Provider(create: (c) => SqliteService()),
        Provider(create: (c) => QuizService()),
      ],
      child: Builder(builder: (context) {
        Commands.init(context);

        return MaterialApp(
          title: 'Civil Safety Quiz',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => HomeScreen(),
            '/quiz': (context) => QuizScreen(),
          },
        );
      }),
    );
  }
}