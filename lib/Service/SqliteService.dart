import 'package:civilsafety_quiz/Model/QuizModel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqliteService {
  createDatabase() async {
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath, version: 1, onCreate: populateDb);
    return database;
  }

  void populateDb(Database database, int version) async {
    await database.execute("CREATE TABLE Quiz ("
        "id INTEGER PRIMARY KEY,"
        "title TEXT,"
        "description TEXT,"
        "passing_score INTEGER,"
        "staff_email TEXT,"
        "file_path TEXT"
        ")");

    await database.execute("CREATE TABLE Record ("
        "id INTEGER PRIMARY KEY,"
        "quizId INTEGER,"
        "score INTEGER"
        ")");
  }

  Future<List> getQuizIndex() async {
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);

    var indexList = await database.rawQuery('SELECT id FROM Quiz');

    List result = [];

    for (var item in indexList.toList()) {
      result.add(item['id']);
    }

    return result;
  }

  Future<int> createQuiz(QuizModel quiz) async {
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);

    var result = -1;
    try {
      result = await database.insert("Quiz", quiz.toMap());
    } catch (e) {}
    print('[SqliteService] createQuiz completed');
    return result;
  }

  Future<List> getQuizzes() async {
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);

    var result = await database.rawQuery('SELECT * FROM Quiz');
    return result.toList();
  }

  Future<int> updateQuiz(QuizModel quiz) async {
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);

    return await database.update("Quiz", quiz.toMap(),
        where: "id = ?", whereArgs: [quiz.quizId]);
  }

  Future<int> deleteQuiz(int id) async {
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);

    return await database.delete("Quiz", where: 'id = ?', whereArgs: [id]);
  }
}
