import 'dart:convert';

import 'package:cliqueledger/models/cliqeue.dart';
import 'package:cliqueledger/providers/Clique_list_provider.dart';
import 'package:cliqueledger/service/authservice.dart';
import 'package:cliqueledger/utility/constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class CliqueApi{
  static String? accessToken = Authservice.instance.accessToken;
  static Future<void> deleteClique(Clique clique , CliqueListProvider cliqueListProvider, BuildContext context) async {
      final uriDelete =  Uri.parse('$BASE_URL/cliques/${clique.id}');
      try {
        final response = await http.delete(uriDelete ,headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        });

        if(response.statusCode == 204){
          cliqueListProvider.deleteClique(clique.id);
      
           // ignore: use_build_context_synchronously
           ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Deleted Succussfully')),
                    );
        }else{
          
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to Delete the Clique')),
                    );
        }
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to Delete the Clique')),
                    );
      }
  }
  static Future<int> changeCliqueName(String cliqueId , String newName, CliqueListProvider cliqueListProvider, BuildContext context) async{
   
    final uriDelete =  Uri.parse('$BASE_URL/cliques/$cliqueId');
    int  code=400;
    try {
      final response = await http.patch(uriDelete,headers:{
         'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
      },
       body: json.encode({"name":newName})
      );
      if(response.statusCode == 200){
          code = response.statusCode;
          cliqueListProvider.nameChange(cliqueId, newName);
           // ignore: use_build_context_synchronously
           ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Clique Name updated Succussfully')),
                    );
      }else{
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Operation Failed')),
                    );
      }
      //return response.statusCode;
    } catch (e) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Operation Failed')),
                    );
    }

     return code;
  }
  
 

}