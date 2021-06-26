import 'dart:convert';

import 'package:flutter/material.dart';

class QuizModel extends ChangeNotifier {
  String quizId;
  String title;
  String description;
  int passingScore;
  String staffEmail;
  String quizContent;
  bool isDownload;

  static String get tableName => 'quiz';

  QuizModel({
    this.quizId = 'unknown',
    this.title = 'Quiz',
    this.description = '',
    this.passingScore = 100,
    this.staffEmail = 'rto@civilsafetyonline.com.au',
    this.quizContent = '',
    this.isDownload = false,
  });

  factory QuizModel.fromJson(String str) => QuizModel.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory QuizModel.fromMap(Map<String, dynamic> jsonData) => QuizModel(
        quizId: jsonData['id'].toString(),
        title: jsonData['name'],
        description: jsonData['description'] != null ? jsonData['description'] : '',
        passingScore: jsonData['passing_score'],
        staffEmail: jsonData['stuff_emails'],
        quizContent: jsonData['quizContent'] != null ? jsonData['quizContent'] : '',
        isDownload: jsonData['downloaded'] == 1,
      );

  Map<String, dynamic> toMap() => {
        'id': quizId,
        'title': title,
        'description': description,
        'passing_score': passingScore,
        'staff_email': staffEmail,
        'file_path': '',
      };
}
