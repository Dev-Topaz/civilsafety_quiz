import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';

class QuizModel extends ChangeNotifier {
  String quizId;
  String name;
  String description;
  int passingScore;
  String staffEmail;
  String quizContentPath;
  String updatedAt;
  bool isDownload;

  static String get tableName => 'quiz';

  QuizModel({
    this.quizId = 'unknown',
    this.name = 'Quiz',
    this.description = '',
    this.passingScore = 100,
    this.staffEmail = 'rto@civilsafetyonline.com.au',
    this.quizContentPath = '',
    this.isDownload = false,
    this.updatedAt = '',
  });

  factory QuizModel.fromJson(String str) => QuizModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory QuizModel.fromMap(Map<String, dynamic> jsonData) => QuizModel(
        quizId: jsonData['id'].toString(),
        name: jsonData['name'],
        description:
            jsonData['description'] != null ? jsonData['description'] : '',
        passingScore: jsonData['passing_score'],
        staffEmail: jsonData['stuff_emails'],
        quizContentPath: jsonData['quiz_content_path'] != null
            ? jsonData['quiz_content_path']
            : '',
        isDownload: jsonData['downloaded'] == 1,
        updatedAt: jsonData['updated_at'],
      );

  Map<String, dynamic> toMap() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-ddTkk:mm:ss').format(now);

    return {
      'id': quizId,
      'name': name,
      'description': description,
      'passing_score': passingScore,
      'stuff_emails': staffEmail,
      'file_path': '',
      'quiz_content_path': '',
      'downloaded': 'false',
      'updated_at': formattedDate
    };
  }
}
