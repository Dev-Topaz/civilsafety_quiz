import 'package:civilsafety_quiz/Model/QuizModel.dart';
import 'package:intl/intl.dart';
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
        "name TEXT,"
        "description TEXT,"
        "passing_score INTEGER,"
        "stuff_emails TEXT,"
        "file_path TEXT,"
        "downloaded TEXT,"
        "updated_at TEXT,"
        "result TEXT,"
        "score INTEGER,"
        "quiz_content_path TEXT"
        ")");

    await database.execute("CREATE TABLE Asset ("
        "id TEXT PRIMARY KEY,"
        "url TEXT,"
        "file_path TEXT"
        ")");

    await database.execute("CREATE TABLE Record ("
        "id INTEGER PRIMARY KEY,"
        "quizId INTEGER,"
        "score INTEGER"
        ")");

    await database.execute("CREATE TABLE Result ("
        "id INTEGER PRIMARY KEY,"
        "content TEXT"
        ")");
  }

  Future<int> createResult(String content) async {
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);

    var result =
        await database.rawInsert("INSERT INTO Result (content)"
            " VALUES ('$content')");
    return result;
  }

  Future<void> dropResult() async {

    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);

    await database.execute("DROP TABLE IF EXISTS Result");
    await database.execute("CREATE TABLE Result ("
        "id INTEGER PRIMARY KEY,"
        "content TEXT"
        ")");
}

  Future<List> getAllResult() async {
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);

    var indexList = await database.rawQuery('SELECT content FROM Result');

    List result = [];

    for (var item in indexList.toList()) {
      result.add(item['content']);
    }

    return result;
  }

  Future<int> createAsset(String id, String url, String filePath) async {
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);

    var result =
        await database.rawInsert("INSERT INTO Asset (id, url, file_path)"
            " VALUES ('$id', '$url', '$filePath')");
    return result;
  }

  Future<String> getIdWithUrl(String url) async {
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);

    var results =
        await database.rawQuery("SELECT id FROM Asset WHERE url = '$url'");

    if (results.length > 0) {
      print('[SqliteService] getQuiz ${results.first['id']}');
      return results.first['id'].toString();
    }

    return '';
  }

  Future<String> getPathWithUrl(String url) async {
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);

    var results = await database
        .rawQuery("SELECT file_path FROM Asset WHERE url = '$url'");

    if (results.length > 0) {
      print('[SqliteService] getQuiz ${results.first['file_path']}');
      return results.first['file_path'].toString();
    }

    return '';
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

  Future<int> updateQuizContent(String quizContent, int id) async {
    DateTime now = DateTime.now().toUtc();
    String formattedDate = DateFormat('yyyy-MM-ddTkk:mm:ss').format(now);

    print('[SqliteService] updateQuizContent formattedDate $formattedDate');

    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);

    print('[SqliteService] updateQuizContent id $id quizContent $quizContent');

    int count = await database.rawUpdate(
        'UPDATE Quiz SET quiz_content = ?, updated_at = ? WHERE id = ?', [quizContent, formattedDate, id]);

    print('[SqliteService] updateQuizContent count $count');

    return count;
  }

  Future<int> updateQuizDownload(String isDownload, int id) async {
    DateTime now = DateTime.now().toUtc();
    String formattedDate = DateFormat('yyyy-MM-ddTkk:mm:ss').format(now);

    print('[SqliteService] updateQuizDownload formattedDate $formattedDate');

    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);

    int count = await database.rawUpdate(
        'UPDATE Quiz SET downloaded = ?, updated_at = ? WHERE id = ?', [isDownload, formattedDate, id]);

    print('[SqliteService] updateQuizDownload count $count');

    return count;
  }

  Future<int> updateQuizResult(String result, int id) async {

    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);

    int count = await database.rawUpdate(
        'UPDATE Quiz SET result = ? WHERE id = ?', [result, id]);

    print('[SqliteService] updateQuizResult count $count');

    return count;
  }

  Future<int> updateQuizScore(int score, int id) async {

    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);

    int count = await database.rawUpdate(
        'UPDATE Quiz SET score = ? WHERE id = ?', [score, id]);

    print('[SqliteService] updateQuizScore count $count');

    return count;
  }

  Future<QuizModel?> getQuiz(int? id) async {
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);

    var results = await database.rawQuery('SELECT * FROM Quiz WHERE id = $id');

    if (results.length > 0) {
      print('[SqliteService] getQuiz ${results.first}');
      return new QuizModel.fromMap(results.first);
    }

    return null;
  }
}
