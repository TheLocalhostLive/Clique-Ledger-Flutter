import 'package:cliqueledger/models/cliqeue.dart';
import 'package:cliqueledger/models/member.dart';
import 'package:cliqueledger/models/transaction.dart';
import 'package:flutter/material.dart';

class CliqueProvider with ChangeNotifier {
  Clique? _currentClique;

  Clique? get currentClique => _currentClique;

  void setClique(Clique clique) {
    _currentClique = clique;
    notifyListeners();
  }

  void chaneLatestTransaction(Transaction t) {
    _currentClique!.latestTransaction = t;
  }

  Member getMemberById(String id) {
    Member member =
        currentClique!.members.firstWhere((member) => member.memberId == id);

    return member;
  }
}
