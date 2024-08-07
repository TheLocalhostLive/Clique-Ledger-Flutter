import 'package:cliqueledger/models/transaction.dart';
import 'package:flutter/foundation.dart';

class TransactionProvider with ChangeNotifier {
  Map<String, List<Transaction>> _transactionMap = {};
  Map<String, List<Transaction>> get transactionMap => _transactionMap;

  void addAllTransaction(String cliqueId, List<Transaction> ts) {
    _transactionMap[cliqueId] = ts;
    notifyListeners();
  }

 void addSingleEntry(String cliqueId, Transaction tx) {
    if (_transactionMap.containsKey(cliqueId)) {
      _transactionMap[cliqueId]?.add(tx);
    } else {
      _transactionMap[cliqueId] = [tx];
    }
    notifyListeners();
  }
}
