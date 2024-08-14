import 'package:cliqueledger/models/cliqeue.dart'; // fixed typo
import 'package:cliqueledger/providers/CliqueListProvider.dart';
import 'package:cliqueledger/service/authservice.dart';
import 'package:cliqueledger/utility/constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CliqueList {

  List<Clique> cliqueList = [];
  Map<String, Clique> activeCliqueList = {};
  Map<String, Clique> finishedCliqueList = {};

  Future<void> fetchData(CliqueListProvider cliqueListProvider) async {
    String? accessToken = Authservice.instance.accessToken;
    print('Access Token : $accessToken');
    
    final uriGet = Uri.parse('${BASE_URL}/cliques');
    try {
      final response = await http.get(uriGet,headers: {
        'Authorization' : 'Bearer $accessToken'
        });
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        cliqueList = jsonList.map((jsonItem) => Clique.fromJson(jsonItem)).toList();
        print("Data fetched successfully: ${cliqueList.length} items");
        cliqueListProvider.setCliqueList(cliqueList);
      } else {
        // Handle error response
        print("Error while fetching data: ${response.statusCode}");
      }
    } catch (e) {
      // Handle exceptions
      print("Exception occurred: $e");
    }

    // Return an empty list in case of failure
  
  }
}
