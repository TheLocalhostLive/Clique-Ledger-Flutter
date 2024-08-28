import 'dart:convert';
import 'package:cliqueledger/models/member.dart';
import 'package:cliqueledger/providers/Clique_list_provider.dart';
import 'package:cliqueledger/providers/clique_provider.dart';
import 'package:cliqueledger/service/authservice.dart';
import 'package:cliqueledger/utility/constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cliqueledger/models/user.dart';
class MemberApi{
   static String? accessToken = Authservice.instance.accessToken;
   static Future<User?> searchUser(String email) async {
  

    // Construct the URI with the email appended to the path
    final uriGet = Uri.parse('$BASE_URL/users/email/$email');

    try {
      final response = await http.get(uriGet, headers: {
        'Authorization': 'Bearer $accessToken',
      });
      if (response.statusCode == 200) {
       
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        return User.fromJson(jsonResponse["data"]);
      } else {
        // Handle error response
     
        return null;
      }
    } catch (e) {
      // Handle exceptions
     
      return null;
    }
  }
  static Future<void> addUserPost(List<String> userIds , 
  CliqueListProvider cliqueListProvider , CliqueProvider cliqueProvider) async{
   
    final uriPost = Uri.parse('$BASE_URL/cliques/${cliqueProvider.currentClique!.id}/members');
    final jsonBody = json.encode(userIds);

    try {
      final response = await http.post(
        uriPost,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonBody
      );
        
      if(response.statusCode == 201){
       
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          final List<dynamic> data = jsonResponse['data'];
          List<Member> members = data.map((item) => Member.fromJson(item)).toList();
          for(Member m in members){
            cliqueListProvider.activeCliqueList[cliqueProvider.currentClique!.id]!.members.add(m);
          }
      }

  }catch(e){
   //
  }
  }
  static Future<void> removeMember(String cliqueId , String memberId , CliqueListProvider cliquelistProvider , BuildContext context) async{
    final uriDelete = Uri.parse('$BASE_URL/cliques/$cliqueId/members/');
    List<String> deleteUser = [];
    deleteUser.add(memberId);
    final jsonBody = json.encode(deleteUser);
    try {
      final response = await http.delete(uriDelete ,headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
      },
          body: jsonBody
      );
      if(response.statusCode==204){
        
          cliquelistProvider.deleteMember(cliqueId, memberId);
         
           // ignore: use_build_context_synchronously
           ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Removed Succussfully')),
                    );
      }else{
       
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to Remove the member')),
                    );
      }

      }
    catch (e) {
      //
    }
  }
}