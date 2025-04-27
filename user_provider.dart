// user_provider.dart
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? userId;
  String? userName;
  String? userEmail;
  
  void setUser(String id, String name, String email) {
    userId = id;
    userName = name;
    userEmail = email;
    notifyListeners();
  }
  
  void clearUser() {
    userId = null;
    userName = null;
    userEmail = null;
    notifyListeners();
  }
  
  bool get isLoggedIn => userId != null;
}