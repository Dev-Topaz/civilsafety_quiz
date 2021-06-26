import 'package:civilsafety_quiz/Controller/BaseCommand.dart';
import 'package:civilsafety_quiz/Model/QuizModel.dart';

class QuizCommand extends BaseCommand {
  Future<void> updateQuiz(String token) async {
    await sqliteService.createDatabase();

    List quizIndex = await quizService.fetchQuizIndex(token);

    for (var id in quizIndex) {
      if (id != -1) {
        print('[QuizCommand] updateQuiz $id');
        QuizModel quizModel = await quizService.fetchQuiz(token, id);
        await sqliteService.createQuiz(quizModel);
      }
    }
    print('[QuizCommand] updateQuiz complete');
  }

  Future<List> getQuizzes() async {
    return await sqliteService.getQuizzes();
  }
}
