import 'package:cliqueledger/models/cliqeue.dart';
import 'package:cliqueledger/providers/CliqueListProvider.dart';
import 'package:cliqueledger/service/authservice.dart';
import 'package:cliqueledger/utility/constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class CliqueDelete{
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
  

}