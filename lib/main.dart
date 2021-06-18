import 'package:civilsafety_quiz/Model/AppModel.dart';
import 'package:civilsafety_quiz/Model/QuizModel.dart';
import 'package:civilsafety_quiz/Model/UserModel.dart';
import 'package:civilsafety_quiz/Service/AppService.dart';
import 'package:civilsafety_quiz/Service/UserService.dart';
import 'package:civilsafety_quiz/View/screen/HomeScreen.dart';
import 'package:civilsafety_quiz/View/screen/QuizScreen.dart';
import 'package:civilsafety_quiz/Controller/BaseCommand.dart' as Commands;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
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

// class AppScaffold extends StatelessWidget {
//   const AppScaffold({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Civil Safety Quiz',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       initialRoute: '/',
//       routes: {
//         '/': (context) => HomeScreen(),
//         '/quiz': (context) => QuizScreen(),
//       },
//     );
//   }
// }
