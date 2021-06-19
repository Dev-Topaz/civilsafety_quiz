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
        quizId: jsonData['quizId'],
        title: jsonData['title'],
        description: jsonData['description'],
        passingScore: jsonData['passingScore'],
        staffEmail: jsonData['staffEmail'],
        quizContent: jsonData['quizContent'],
        isDownload: jsonData['isDownload'],
      );

  Map<String, dynamic> toMap() => {
        'quizId': quizId,
        'title': title,
        'description': description,
        'passingScore': passingScore,
        'staffEmail': staffEmail,
        'quizContent': quizContent,
        'isDownload': isDownload,
      };
}
