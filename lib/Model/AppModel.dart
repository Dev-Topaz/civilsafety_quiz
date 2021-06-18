import 'package:flutter/material.dart';

class AppModel extends ChangeNotifier {
  late String _currentUserToken;
  bool _isOnline = false;

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
