import 'dart:convert';

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
  String result;
  int score;
  String examIcon;

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
    this.result = 'none',
    this.score = 0,
    this.examIcon = '',
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
        updatedAt: jsonData['updated_at'] ?? '1900-01-01T00:00',
        result: jsonData['result'] ?? 'none',
        score: jsonData['exam_user_score'] ?? 0,
        examIcon: jsonData['exam_icon'] ?? '',
      );

  Map<String, dynamic> toMap() {
    return {
      'id': quizId,
      'name': name,
      'description': description,
      'passing_score': passingScore,
      'stuff_emails': staffEmail,
      'file_path': '',
      'quiz_content_path': '',
      'downloaded': 'false',
      'exam_icon': examIcon,
      'score': score,
      'result': result,
    };
  }
}
