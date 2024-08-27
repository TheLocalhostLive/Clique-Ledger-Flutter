import 'dart:convert';

import 'package:cliqueledger/models/cliqeue.dart';
import 'package:cliqueledger/providers/CliqueListProvider.dart';
import 'package:cliqueledger/service/authservice.dart';
import 'package:cliqueledger/utility/constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class CliqueApi{
  static String? accessToken = Authservice.instance.accessToken;
  static Future<void> deleteClique(Clique clique , CliqueListProvider cliqueListProvider, BuildContext context) async {
      final uriDelete =  Uri.parse('${BASE_URL}/cliques/${clique.id}');
      try {
        final response = await http.delete(uriDelete ,headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        });

        if(response.statusCode == 204){
             print(response.statusCode);
          print('response body : ${response.body}');
          cliqueListProvider.deleteClique(clique.id);
          print("Cliqued Deleted Successfully");
           ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Deleted Succussfully')),
                    );
        }else{
            print(response.statusCode);
        ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to Delete the Clique')),
                    );
        }
      } catch (e) {
        print('Exception Occured in Delete cliqye :$e');
      }
  }
  static Future<int> changeCliqueName(String cliqueId , String newName, CliqueListProvider cliqueListProvider, BuildContext context) async{
    print('${BASE_URL}/cliques/${cliqueId}');
    final uriDelete =  Uri.parse('${BASE_URL}/cliques/${cliqueId}');
    int  code=400;
    try {
      final response = await http.patch(uriDelete,headers:{
         'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
      },
       body: json.encode({"name":newName})
      );
       print(response.statusCode);
          print('response body : ${response.body}');

      if(response.statusCode == 200){
          code = response.statusCode;
          cliqueListProvider.nameChange(cliqueId, newName);
          print("Cliqued Name changed Successfully");
           ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Clique Name updated Succussfully')),
                    );
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Operation Failed')),
                    );
      }
      //return response.statusCode;
    } catch (e) {
      
    }

     return code;
  }
  
 

}