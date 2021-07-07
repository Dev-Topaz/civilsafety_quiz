import 'package:civilsafety_quiz/Controller/BaseCommand.dart';
import 'package:civilsafety_quiz/Model/QuizModel.dart';
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

  Future<void> downloadAssets(
      String token, int id, String localPath, String quizContent) async {
    List videoAudioURL =
        await quizService.fetchVideoAudioAssetsURL(token, quizContent);

    if (debug) print('[QuizCommand] downloadAssets $localPath');

    for (var url in videoAudioURL) {
      await FlutterDownloader.enqueue(url: url, savedDir: localPath);
    }

    List imageURL = await quizService.fetchImageAssetsURL(token, quizContent);
      print('[QuizCommand] downloadAssets $imageURL');

    for (var url in imageURL) {
      String base64 = await quizService.getBase64(token, url);
      quizContent.replaceAll(url, base64);
      print('[QuizCommand] downloadAssets $quizContent');

      await sqliteService.updateQuizContent(quizContent, id);
    }

    // String quizContent = await quizService.getQuizContent(token, id);

  }

  Future<QuizModel?> getQuiz(int? id) async {
    return await sqliteService.getQuiz(id);
  }
}
