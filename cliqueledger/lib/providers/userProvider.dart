import 'package:cliqueledger/models/user.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  User ? _currentUser;
  User ? get  currentUser => _currentUser;

  void setUserDetails(User user){
    _currentUser = user;
    notifyListeners();
  }

}