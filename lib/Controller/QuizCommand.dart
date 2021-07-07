import 'package:civilsafety_quiz/Controller/BaseCommand.dart';
import 'package:civilsafety_quiz/Model/QuizModel.dart';
import 'package:civilsafety_quiz/Service/SqliteService.dart';
import 'package:civilsafety_quiz/const.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

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

  Future<void> downloadAssets(String token, int id, String localPath) async {
    List assetsURL = await quizService.fetchAllAssetsURL(token, id);

    if (debug) print('[QuizCommand] downloadAssets $localPath');

    for (var url in assetsURL) {
      await FlutterDownloader.enqueue(url: url, savedDir: localPath);
    }

    String quizContent = await quizService.getQuizContent(token, id);

    print('[QuizCommand] downloadAssets $quizContent');

    await sqliteService.updateQuizContent(quizContent, id);
  }

  Future<QuizModel?> getQuiz(int? id) async {
    return await sqliteService.getQuiz(id);
  }
}
