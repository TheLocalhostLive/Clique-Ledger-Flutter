import 'dart:convert';
import 'package:cliqueledger/models/cliqeue.dart';
import 'package:cliqueledger/models/clique_post_schema.dart';
import 'package:cliqueledger/providers/Clique_list_provider.dart';
import 'package:cliqueledger/service/authservice.dart';
import 'package:cliqueledger/service/socket_service.dart';
import 'package:cliqueledger/utility/constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateCliquePost {
  final Uri uriPost = Uri.parse('$BASE_URL/cliques');
  static String? accessToken = Authservice.instance.accessToken;

  Future<void> postData(CliquePostSchema object, CliqueListProvider cliqueListProvider ,BuildContext context) async {
    var payload = jsonEncode(object.toJson());  // Encode to JSON string

    try {
      final response = await http.post(
        uriPost,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },  // Set Content-Type header
        body: payload,
      );

      if (response.statusCode == 201) {
       
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        // Check if response body is a Map, not a List
        // Assuming the response body is a single Clique object
        Clique newClique = Clique.fromJson(responseBody);
         // ignore: use_build_context_synchronously
         ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Created Succussfully')),
                    );

        // Update the provider
        cliqueListProvider.setClique(newClique);
        SocketService.instance.joinRooms([newClique.id]);
       
      } else {
        // Handle non-success status codes
         // ignore: use_build_context_synchronously
         ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed Creating Clique')),
                    );

      
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed Creating Clique')),
                    );
    }
  }
}
