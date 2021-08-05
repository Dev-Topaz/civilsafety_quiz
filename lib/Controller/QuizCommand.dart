import 'dart:io';

import 'package:civilsafety_quiz/Controller/BaseCommand.dart';
import 'package:civilsafety_quiz/Model/QuizModel.dart';
import 'package:civilsafety_quiz/const.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizCommand extends BaseCommand {

  Future saveResult(String content, String quizId) async {
    await sqliteService.createResult(content, quizId);
  }

  Future sendEmail(String token, String json) async {
    await quizService.sendEmail(token, json);
  }

  Future saveResultAtServer(String token, String json, String quizId) async {
    String userId = await userService.gerUserId(token);
    await quizService.saveResult(token, json, userId, quizId);
  }

  Future sendAllSavedResult(token) async {
    List resultList = await sqliteService.getAllResult();

    for (var result in resultList) {
      await this.sendEmail(token, result['content']);
      await this.saveResultAtServer(token, result['content'], result['quizId']);
    }

    await sqliteService.dropResult();
  }

  Future downloadQuizList(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isChangeUser = prefs.getBool('isChangeUser')!;

    await sqliteService.createDatabase();

    List remoteQuizIndex = await quizService.fetchQuizIndex(token);
    List localQuizIndex = await sqliteService.getQuizIndex();

    print('[QuizCommand] downloadQuizList: $localQuizIndex');
    for (var id in remoteQuizIndex) {
      id = int.parse(id);
      print('[QuizCommand] id $id');
      print('[QuizCommand] ${localQuizIndex.indexOf(id)}');
      
      if (id != 1) {
        QuizModel quizModel = await quizService.fetchQuiz(token, id);
        if (localQuizIndex.indexOf(id) == -1) {
          //create quiz
          await sqliteService.createQuiz(quizModel);
        } else {
          //update quiz
          QuizModel? localQuizModel = await sqliteService.getQuiz(id);

          print('quizmodel updatedate ${DateTime.parse(quizModel.updatedAt)}');
          print(
              'quizmodel updatedate ${DateTime.parse(localQuizModel!.updatedAt + 'Z')}');

          bool isUpdated = DateTime.parse(localQuizModel.updatedAt + 'Z')
              .isAfter(DateTime.parse(quizModel.updatedAt));

          print('[QuizCommand] downloadQuizList isUpdated $isUpdated');
          print('[QuizCommand] downloadQuizList: update quiz $id');
          if (!isUpdated || isChangeUser) await sqliteService.updateQuiz(quizModel);
        }
      }
    }
  }

  Future removeQuizList(String token) async {
    await sqliteService.createDatabase();

    List remoteQuizIndex = await quizService.fetchQuizIndex(token);
    List localQuizIndex = await sqliteService.getQuizIndex();

    for (var id in localQuizIndex) {
      id = id.toString();
      if (remoteQuizIndex.indexOf(id) == -1) {
        await sqliteService.deleteQuiz(int.parse(id));
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

  Future<void> deleteAssets(String token, int id, String localPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;

    final file = File('$path/$id.txt');

    await file.delete();

    await sqliteService.updateQuizDownload('false', id);
  }

  Future<void> updateQuizResult(String result, int id) async {
    await sqliteService.updateQuizResult(result, id);
  }

  Future<void> updateQuizScore(int score, int id) async {
    await sqliteService.updateQuizScore(score, id);
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
      String? fileId =
          await FlutterDownloader.enqueue(url: url, savedDir: localPath);

      final File _file = new File(url);
      final _filename = basename(_file.path);
      if (debug)
        print('[QuizCommand] downloadAssets filepath $localPath/$_filename');

      String filePath = '$localPath/$_filename';

      await sqliteService.createAsset(fileId!, url, filePath);
    }

    await sqliteService.updateQuizDownload('true', id);
  }

  Future<String> getFileIdWithUrl(String url) async {
    return await sqliteService.getIdWithUrl(url);
  }

  Future<String> getFilePathWithUrl(String url) async {
    return await sqliteService.getPathWithUrl(url);
  }

  Future<QuizModel?> getQuiz(int? id) async {
    return await sqliteService.getQuiz(id);
  }
}
