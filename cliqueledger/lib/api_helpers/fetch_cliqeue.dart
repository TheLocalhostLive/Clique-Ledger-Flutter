import 'package:cliqueledger/models/cliqeue.dart'; // fixed typo
import 'package:cliqueledger/providers/Clique_list_provider.dart';
import 'package:cliqueledger/service/authservice.dart';
import 'package:cliqueledger/utility/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CliqueList {

  List<Clique> cliqueList = [];
  Map<String, Clique> activeCliqueList = {};
  Map<String, Clique> finishedCliqueList = {};

  Future<void> fetchData(CliqueListProvider cliqueListProvider) async {
    String? accessToken = Authservice.instance.accessToken;
   
    
    final uriGet = Uri.parse('$BASE_URL/cliques');
    try {
      final response = await http.get(uriGet,headers: {
        'Authorization' : 'Bearer $accessToken'
        });
      if (response.statusCode == 200) {
     
        final List<dynamic> jsonList = json.decode(response.body);
         // ignore: use_build_context_synchronously
   


        cliqueList = jsonList.map((jsonItem) => Clique.fromJson(jsonItem)).toList();
      
        cliqueListProvider.setCliqueList(cliqueList);
      } else {
        // Handle error response
        // ignore: use_build_context_synchronously
        

       
      }
    } catch (e) {
      // Handle exceptions
      // ignore: use_build_context_synchronously
    //
      
    }

    // Return an empty list in case of failure
  
  }
}
