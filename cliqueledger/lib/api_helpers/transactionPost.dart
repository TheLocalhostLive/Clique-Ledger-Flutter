import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cliqueledger/models/TransactionPostSchema.dart';
import 'package:cliqueledger/utility/constant.dart';

class TransactionPost{
  static final uriPost = Uri.parse('${BASE_URL}/transaction');

  static Future<void> PostData(TransactionPostschema object) async{
    var _payload = json.encode(object);
       final response = await http.post(uriPost , body: _payload);
  }

}