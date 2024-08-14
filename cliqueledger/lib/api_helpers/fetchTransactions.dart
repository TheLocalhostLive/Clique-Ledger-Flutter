import 'dart:convert';

import 'package:cliqueledger/models/member.dart';
import 'package:cliqueledger/models/participants.dart';
import 'package:cliqueledger/models/transaction.dart';
import 'package:cliqueledger/service/authservice.dart';
import 'package:cliqueledger/utility/constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert'; // Required for json.decode
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:http/http.dart' as http;

class TransactionList {
  List<Transaction> transactions = [];
 String? accessToken = Authservice.instance.accessToken;

  Future<void> fetchData(String cliqueId) async {
    final queryParams = {"cliqueId": cliqueId};
    final uriGet = Uri.parse('http://13.234.48.56:3000/api/v1/transactions').replace(queryParameters: queryParams);
            
    try {
      final response = await http.get(uriGet,headers:{
            'Authorization' : 'Bearer $accessToken'
      });
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        transactions = jsonList.map((jsonItem) => Transaction.fromJson(jsonItem)).toList();
        print("Data fetched successfully: ${response.body}");
      } else {
        print("Error fetching data: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception occurred: $e");
    }
  }
}
