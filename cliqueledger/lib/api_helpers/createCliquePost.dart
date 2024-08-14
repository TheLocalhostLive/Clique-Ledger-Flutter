import 'dart:convert';
import 'package:cliqueledger/models/cliqeue.dart';
import 'package:cliqueledger/models/cliquePostSchema.dart';
import 'package:cliqueledger/providers/CliqueListProvider.dart';
import 'package:cliqueledger/service/authservice.dart';
import 'package:cliqueledger/utility/constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateCliquePost {
  final Uri uriPost = Uri.parse('${BASE_URL}/cliques');
  static String? accessToken = Authservice.instance.accessToken;

  Future<void> postData(CliquePostSchema object, CliqueListProvider cliqueListProvider) async {
    var _payload = jsonEncode(object.toJson());  // Encode to JSON string

    try {
      final response = await http.post(
        uriPost,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },  // Set Content-Type header
        body: _payload,
      );

      if (response.statusCode == 201) {
        // Successfully posted data
        print("Data Posted Successfully");

        // Print raw response body
        print('Raw response body: ${response.body}');

        // Decode the response body
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        // Check if response body is a Map, not a List
        if (responseBody is Map<String, dynamic>) {
          // Assuming the response body is a single Clique object
          Clique newClique = Clique.fromJson(responseBody);

          // Update the provider
          cliqueListProvider.setClique(newClique);

          print('Response status: ${response.statusCode}');
          print('Response body: ${response.body}');
        } else {
          print('Unexpected response format: ${responseBody}');
        }
      } else {
        // Handle non-success status codes
        print("Failed to post data: ${response.statusCode}");
      }
    } catch (e) {
      print('Error Clique Post: $e');
    }
  }
}
