import 'dart:convert';
import 'package:cliqueledger/models/transaction.dart';
import 'package:cliqueledger/service/authservice.dart';
import 'package:cliqueledger/utility/constant.dart';
import 'package:http/http.dart' as http;


class TransactionList {
  List<Transaction> transactions = [];
 String? accessToken = Authservice.instance.accessToken;

  Future<void> fetchData(String cliqueId ,) async {
  
    final queryParams = {"cliqueId": cliqueId};
    final uriGet = Uri.parse('$BASE_URL/transactions').replace(queryParameters: queryParams);
            
    try {
      final response = await http.get(uriGet,headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        });
      if (response.statusCode == 200) {
     
        final List<dynamic> jsonList = json.decode(response.body);
        transactions = jsonList.map((jsonItem) => Transaction.fromJson(jsonItem)).toList();
        
      } else {
       //
      }
    } catch (e) {
     //
    }
  }
}
