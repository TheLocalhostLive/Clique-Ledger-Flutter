
import 'dart:convert';
import 'package:cliqueledger/models/cliqeue.dart';
import 'package:cliqueledger/models/cliquePostSchema.dart';
import 'package:cliqueledger/providers/CliqueListProvider.dart';
import 'package:cliqueledger/utility/constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class CreateCliquePost {
  final Uri uriPost = Uri.parse('${BASE_URL}/cliques');

  Future<void> postData(CliquePostSchema object , CliqueListProvider cliqueListProvider) async {
    var _payload = jsonEncode(object.toJson());  // Encode to JSON string
    try {
      final response = await http.post(
        uriPost,
        headers: {'Content-Type': 'application/json'},  // Set Content-Type header
        body: _payload,
      );
      
      if(response.statusCode == 201) print("Data Posted Successfully");
      
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      Clique newClique = Clique.fromJson(responseBody);
      cliqueListProvider.setClique(newClique);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    } catch (e) {
      print('Error: $e');
    }
  }
}