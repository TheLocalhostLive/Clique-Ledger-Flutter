import 'dart:convert';
import 'package:cliqueledger/models/member.dart';
import 'package:cliqueledger/providers/CliqueListProvider.dart';
import 'package:cliqueledger/providers/cliqueProvider.dart';
import 'package:cliqueledger/service/authservice.dart';
import 'package:cliqueledger/utility/constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cliqueledger/models/user.dart';
class MemberApi{
   static String? accessToken = Authservice.instance.accessToken;
   static Future<User?> searchUser(String email) async {
    print('Access Token: $accessToken');

    // Construct the URI with the email appended to the path
    final uriGet = Uri.parse('${BASE_URL}/users/email/$email');

    try {
      final response = await http.get(uriGet, headers: {
        'Authorization': 'Bearer $accessToken',
      });
      if (response.statusCode == 200) {
        print('Response Body: ${response.body}');
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        return User.fromJson(jsonResponse["data"]);
      } else {
        // Handle error response
        print("Error while fetching data: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      // Handle exceptions
      print("Exception occurred: $e");
      return null;
    }
  }
  static Future<void> addUserPost(List<String> userIds , 
  CliqueListProvider cliqueListProvider , CliqueProvider cliqueProvider) async{
    print("Add Member Post");
    final uriPost = Uri.parse('${BASE_URL}/cliques/${cliqueProvider.currentClique!.id}/members');
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
            print("Response Status Code: ${response.statusCode}"); // Debug print
           print("Response Body: ${response.body}"); // Debug print
      if(response.statusCode == 201){
          print('Members Added Successfully');
          final Map<String, dynamic> jsonResponse = json.decode(response.body);
          final List<dynamic> data = jsonResponse['data'];
          List<Member> members = data.map((item) => Member.fromJson(item)).toList();
          for(Member m in members){
            cliqueListProvider.activeCliqueList[cliqueProvider.currentClique!.id]!.members.add(m);
          }
      }

  }catch(e){
    print('Exception Occured : $e');
  }
  }
  static Future<void> removeMember(String cliqueId , String memberId , CliqueListProvider cliquelistProvider , BuildContext context) async{
    final uriDelete = Uri.parse('${BASE_URL}/cliques/${cliqueId}/members/');
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
        print(response.statusCode);
          print('response body : ${response.body}');
          cliquelistProvider.deleteMember(cliqueId, memberId);
          print("Member Deleted Successfully");
           ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Removed Succussfully')),
                    );
      }else{
        print(response.statusCode);
        ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to Remove the member')),
                    );
      }

      }
    catch (e) {
      print('Exception Occured :$e');
    }
  }
}