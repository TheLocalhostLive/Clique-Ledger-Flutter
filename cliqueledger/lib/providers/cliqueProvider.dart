import 'package:cliqueledger/models/cliqeue.dart';
import 'package:flutter/material.dart';

class CliqueProvider with ChangeNotifier {
  Clique? _currentClique;

  Clique? get currentClique => _currentClique;

  void setClique(Clique clique) {
    _currentClique = clique;
    notifyListeners();
  }
}