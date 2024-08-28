import 'dart:convert';
import 'package:cliqueledger/models/transaction.dart';
import 'package:cliqueledger/providers/Clique_list_provider.dart';
import 'package:cliqueledger/providers/transaction_provider.dart';
import 'package:cliqueledger/providers/clique_provider.dart';
import 'package:cliqueledger/service/authservice.dart';
import 'package:http/http.dart' as http;
import 'package:cliqueledger/models/Transaction_post_schema.dart';
import 'package:cliqueledger/utility/constant.dart';

class TransactionPost {
  static final uriPost = Uri.parse('$BASE_URL/transactions');
  static String? accessToken = Authservice.instance.accessToken;
  static Future<void> postData(TransactionPostschema object,
      TransactionProvider transactionProvider , CliqueProvider cliqueProvider , CliqueListProvider cliqueListProvider) async {
    print("In Transaction Post");
    var payload = json.encode(object.toJson());
    try {
      final response = await http.post(
        uriPost,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: payload,
      );

      if (response.statusCode == 201) {
       
        // Handle successful response
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
      

        try {
          Transaction ts = Transaction.fromJson(responseBody);
          transactionProvider.addSingleEntry(ts.cliqueId, ts);
          cliqueProvider.chaneLatestTransaction(ts);
          cliqueListProvider.activeCliqueList[cliqueProvider.currentClique!.id]!.latestTransaction = ts;
        } catch (e) {
         //
        }
      } else {
        // Handle error response
        
      }
    } catch (e) {
      // Handle exceptions
     
    }
  }
}
