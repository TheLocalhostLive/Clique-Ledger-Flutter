import 'dart:convert';
import 'package:cliqueledger/models/transaction.dart';
import 'package:cliqueledger/providers/TransactionProvider.dart';
import 'package:cliqueledger/service/authservice.dart';
import 'package:http/http.dart' as http;
import 'package:cliqueledger/models/TransactionPostSchema.dart';
import 'package:cliqueledger/utility/constant.dart';

class TransactionPost {
  static final uriPost = Uri.parse('${BASE_URL}/transactions');
  static String? accessToken = Authservice.instance.accessToken;
  static Future<void> postData(TransactionPostschema object,
      TransactionProvider transactionProvider) async {
    print("In Transaction Post");
    var _payload = json.encode(object.toJson());
    try {
      final response = await http.post(
        uriPost,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: _payload,
      );

      if (response.statusCode == 201) {
        print("Data Posted Successfully\n");
        // Handle successful response
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        print("Decoded response body: $responseBody");

        try {
          Transaction ts = Transaction.fromJson(responseBody);
          transactionProvider.addSingleEntry(ts.cliqueId, ts);
        } catch (e) {
          print("Error parsing Transaction object: $e");
        }
      } else {
        // Handle error response
        print("Error posting data: ${response.statusCode}");
        print("Response: ${response.body}");
      }
    } catch (e) {
      // Handle exceptions
      print("Exception occurred: $e");
    }
  }
}
