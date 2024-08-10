import 'package:cliqueledger/models/cliqeue.dart';
import 'package:cliqueledger/utility/constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CliqueList{

  List<Clique> cliqueList = [];
  Map<String,Clique> activeCliqueList={};
  Map<String,Clique> finishedCliqueList={};
  Future<void> fetchData() async{
   final uriGet = Uri.parse('${BASE_URL}/cliques');
    try {
      final response = await http.get(uriGet);
      if (response.statusCode == 200) {
         final List<dynamic> jsonList = json.decode(response.body);
         print(jsonList.length);
         cliqueList  = jsonList.map((jsonItem) => Clique .fromJson(jsonItem)).toList();
         
         for(Clique cl in cliqueList){
            if(cl.isActive){
              activeCliqueList[cl.id]=cl;
            }else{
              finishedCliqueList[cl.id]=cl;
            }
         }
        print("Data fetched successfully: ${response.body}");
      } else {
        // Handle error response
        print("Error fetching data: ${response.statusCode}");
      }
    } catch (e) {
      // Handle exceptions
      print("Exception occurred: $e");
    }
    //ledgerList = ledgerListDemo;
  }

}

