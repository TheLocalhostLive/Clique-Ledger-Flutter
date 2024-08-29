import 'package:cliqueledger/models/transaction.dart';
import 'package:flutter/foundation.dart';

class TransactionProvider with ChangeNotifier {
  Map<String, Map<String, Transaction>> _transactionMap = {};

  Map<String, Map<String, Transaction>> get transactionMap => _transactionMap;

  // Method to add a list of transactions to a specific clique
  void addAllTransaction(String cliqueId, List<Transaction> ts) {
    if (!_transactionMap.containsKey(cliqueId)) {
      _transactionMap[cliqueId] = {};
    }
    for (var tx in ts) {
      _transactionMap[cliqueId]![tx.id] = tx;
    }
    notifyListeners();
  }

  // Method to add a single transaction to a specific clique
  void addSingleEntry(String cliqueId, Transaction tx) {
    if (!_transactionMap.containsKey(cliqueId)) {
      _transactionMap[cliqueId] = {};
    }
    _transactionMap[cliqueId]![tx.id] = tx;
    notifyListeners();
  }
}