import 'dart:io';

import 'package:civilsafety_quiz/Controller/BaseCommand.dart';
import 'package:civilsafety_quiz/Model/QuizModel.dart';
import 'package:civilsafety_quiz/const.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

class QuizCommand extends BaseCommand {
  Future downloadQuizList(String token) async {
    await sqliteService.createDatabase();

    List remoteQuizIndex = await quizService.fetchQuizIndex(token);
    List localQuizIndex = await sqliteService.getQuizIndex();

    print('[QuizCommand] downloadQuizList: $localQuizIndex');
    for (var id in remoteQuizIndex) {
      if (id != 1) {
        QuizModel quizModel = await quizService.fetchQuiz(token, id);
        if (localQuizIndex.indexOf(id) == -1) {
          //create quiz
          await sqliteService.createQuiz(quizModel);
        } else {
          //update quiz
          print('[QuizCommand] downloadQuizList: update quiz $id');
          await sqliteService.updateQuiz(quizModel);
        }
      }
    }
  }

  Future removeQuizList(String token) async {
    await sqliteService.createDatabase();

    List remoteQuizIndex = await quizService.fetchAllQuizIndex(token);
    List localQuizIndex = await sqliteService.getQuizIndex();

    for (var id in localQuizIndex) {
      if (remoteQuizIndex.indexOf(id) == -1) {
        await sqliteService.deleteQuiz(id);
      }
    }
  }

  Future<List> getQuizzes() async {
    return await sqliteService.getQuizzes();
  }

  Future<String> getQuizContent(int id) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;

    if (debug) print('[QuizCommand] downloadAssets path $path');

    final file = File('$path/$id.txt');

    final contents = await file.readAsString();

    if (debug) print('[QuizCommand] downloadAssets contents $contents');

    return contents;
  }

  Future<void> downloadAssets(String token, int id, String localPath) async {
    String quizContent = await quizService.getQuizContent(token, id);

    if (debug) print('[QuizCommand] downloadAssets $quizContent');

    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;

    if (debug) print('[QuizCommand] downloadAssets path $path');

    final file = File('$path/$id.txt');
    file.writeAsString('$quizContent');

    List videoAudioURL =
        await quizService.fetchVideoAudioAssetsURL(token, quizContent);

    if (debug) print('[QuizCommand] downloadAssets $localPath');

    for (var url in videoAudioURL) {
      await FlutterDownloader.enqueue(url: url, savedDir: localPath);
    }
  }

  Future<QuizModel?> getQuiz(int? id) async {
    return await sqliteService.getQuiz(id);
  }
}
