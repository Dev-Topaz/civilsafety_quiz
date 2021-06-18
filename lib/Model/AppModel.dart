import 'package:flutter/material.dart';

class AppModel extends ChangeNotifier {
  late String _currentUserToken;
  late bool _isOnline;

  String get currentUserToken => _currentUserToken;
  set currentUserToken(String currentUserToken) {
    _currentUserToken = currentUserToken;
    notifyListeners();
  }

  bool get isOnline => _isOnline;
  set isOnline(bool isOnline) {
    _isOnline = isOnline;
    notifyListeners();
  }
}
