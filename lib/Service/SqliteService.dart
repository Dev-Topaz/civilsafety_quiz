import 'dart:convert';
import 'package:civilsafety_quiz/Model/QuizModel.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SqliteService {
  createDatabase() async {
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');
    var database = await openDatabase(dbPath, version: 1, onCreate: populateDb);
    return database;
  }

  void populateDb(Database database, int version) async {
    await database.execute("CREATE TABLE Quiz ("
        "quizId INTEGER,"
        "userId INTEGER,"
        "name TEXT,"
        "description TEXT,"
        "passing_score INTEGER,"
        "stuff_emails TEXT,"
        "file_path TEXT,"
        "downloaded TEXT,"
        "updated_at TEXT,"
        "exam_icon TEXT,"
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
        "userId INTEGER,"
        "quizId INTEGER,"
        "score INTEGER"
        ")");

    await database.execute("CREATE TABLE Result ("
        "userId INTEGER,"
        "quizId TEXT,"
        "content TEXT"
        ")");

    await database.execute("CREATE TABLE User ("
        "id INTEGER PRIMARY KEY,"
        "email TEXT,"
        "password TEXT"
        ")");
  }

  Future<bool> createUser(int userId, String email, String password) async {
    print('$userId, $email, $password');
    String databasePath = await getDatabasesPath();
    String dbPath = join(databasePath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);
    var user = await database.rawQuery("SELECT * FROM User WHERE email='$email';");
    var result = false;
    if(!user.isNotEmpty) {
      print('[Sqlite CreateUser] create');
      var bytes = utf8.encode(password);
      var pass = md5.convert(bytes);
      print('$userId, $email, $pass');
      await database.insert('User', {
        'id': userId,
        'email': email,
        'password': pass.toString(),
      });
      result = true;
    }
    return result;
  }

  Future<Map> login(String email, String password) async {
    String databasePath = await getDatabasesPath();
    String dbPath = join(databasePath, 'civilsafety_quiz.db');
    var loginResponse = {};

    var database = await openDatabase(dbPath);
    var users = await database.rawQuery("SELECT id, password FROM User WHERE email='$email';");
    if(users.isNotEmpty) {
      for(var user in users.toList()) {
        var bytes = utf8.encode(password);
        var pass = md5.convert(bytes);
        print('$user');
        if(pass.toString() == user['password']) {
          loginResponse = {
            'success': 'success',
            'userId': user['id'],
            'userToken': 'offline'
          };
        } else {
          loginResponse = {
            'success': 'failed',
            'message': 'Unauthorized'
          };
        }
      }
    } else {
      loginResponse = {
        'success': 'failed',
        'message': "Unauthorized"
      };
    }

    print('$loginResponse');

    return Future.value(loginResponse);
  }

  Future<int> createResult(String content, String quizId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('userId') ?? '';

    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);

    print("[Create Result] $userId, $quizId, $content");

    var result = await database.insert("Result", {
      'userId': userId,
      'quizId': quizId,
      'content': content,
    });
        // await database.rawInsert("INSERT INTO Result (quizId, content)"
            // " VALUES ('$quizId', '$content')");
    return result;
  }

  Future<void> dropResult() async {

    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);

    await database.execute("DROP TABLE IF EXISTS Result");
    await database.execute("CREATE TABLE Result ("
        "userId INTEGER,"
        "quizId TEXT,"
        "content TEXT"
        ")");
}

  Future<List> getAllResult() async {
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);

    var indexList = await database.rawQuery('SELECT userId, quizId, content FROM Result');

    List result = [];

    for (var item in indexList.toList()) {
      result.add({
        'userId': item['userId'],
        'content': item['content'],
        'quizId': item['quizId'],
        });
    }

    print('[SqliteService] getAllResult $result');

    return result;
  }

  Future<String> getResult(int userId, String quizId) async {
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);
    var result = await database.rawQuery("SELECT result FROM Quiz WHERE userId=? AND quizId=?", [userId, quizId]);
    print('[Get Quiz Result] $result');
    return Future.value(result.first['result'].toString());
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

  Future<List> getQuizIndex(userId) async {
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);

    var indexList = await database.rawQuery('SELECT quizId FROM Quiz WHERE userId=?', [userId]);

    List result = [];

    for (var item in indexList.toList()) {
      result.add(item['quizId']);
    }

    return result;
  }

  Future<int> createQuiz(QuizModel quiz, userId) async {
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);

    print('[create quiz] ${quiz.toMap()}, $userId');

    var result = -1;
    // try {
      result = await database.insert("Quiz", {
        ...quiz.toMap(),
        "userId": userId
      });
      print('[SqliteService] createQuiz completed');
    // } catch (e) {
    //   print('[SqliteService] error $e');
    // }
    return result;
  }

  Future<List> getQuizzes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userId = prefs.getInt('userId') ?? '';

    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);

    var result = await database.rawQuery('SELECT * FROM Quiz WHERE userId=?', [userId]);
    return result.toList();
  }

  Future<int> updateQuiz(QuizModel quiz, userId) async {
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);

    return await database.update("Quiz", quiz.toMap(),
        where: "quizId=? AND userId=?", whereArgs: [quiz.quizId, userId]);
  }

  Future<int> deleteQuiz(int id) async {
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);

    return await database.delete("Quiz", where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateQuizContent(String quizContent, int quizId) async {
    DateTime now = DateTime.now().toUtc();
    String formattedDate = DateFormat('yyyy-MM-ddTkk:mm:ss').format(now);

    print('[SqliteService] updateQuizContent formattedDate $formattedDate');

    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);

    print('[SqliteService] updateQuizContent id $quizId quizContent $quizContent');

    int count = await database.rawUpdate(
        'UPDATE Quiz SET quiz_content = ?, updated_at = ? WHERE quizId = ?', [quizContent, formattedDate, quizId]);

    print('[SqliteService] updateQuizContent count $count');

    return count;
  }

  Future<int> updateQuizDownload(String isDownload, int quizId) async {
    DateTime now = DateTime.now().toUtc();
    String formattedDate = DateFormat('yyyy-MM-ddTkk:mm:ss').format(now);

    print('[SqliteService] updateQuizDownload formattedDate $formattedDate');

    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);

    int count = await database.rawUpdate(
        'UPDATE Quiz SET downloaded = ?, updated_at = ? WHERE quizId = ?', [isDownload, formattedDate, quizId]);

    print('[SqliteService] updateQuizDownload count $count');

    return count;
  }

  Future<int> updateQuizResult(String result, int quizId) async {

    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);

    int count = await database.rawUpdate(
        'UPDATE Quiz SET result = ? WHERE quizId = ?', [result, quizId]);

    print('[SqliteService] updateQuizResult count $count');

    return count;
  }

  Future<int> updateQuizScore(int score, int quizId) async {

    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);

    int count = await database.rawUpdate(
        'UPDATE Quiz SET score = ? WHERE quizId = ?', [score, quizId]);

    print('[SqliteService] updateQuizScore count $count');

    return count;
  }

  Future<QuizModel?> getQuiz(int? quizId, int userId) async {
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'civilsafety_quiz.db');

    var database = await openDatabase(dbPath);

    var results = await database.rawQuery('SELECT * FROM Quiz WHERE quizId=? AND userId=?',
      [quizId, userId]
    );

    if (results.isNotEmpty) {
      print('[SqliteService] getQuiz ${results.first}');
      return new QuizModel.fromMap(results.first);
    }

    return null;
  }
}
