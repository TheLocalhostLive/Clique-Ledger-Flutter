import 'dart:convert';
import 'package:cliqueledger/models/member.dart';
import 'package:http/http.dart' as http;

class MemberList {
  List<Member> members = [];


  Future<void> fetchMembersByEmail(String email) async {
    final uriGet = Uri.parse("https://yourapi.com/users?email=$email"); 
    try {
      final response = await http.get(uriGet);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        members = jsonList.map((jsonItem) => Member.fromJson(jsonItem)).toList();
       
      } else {
        // Handle error response
       
      }
    } catch (e) {
      // Handle exceptions
     ;
    }
   
  }
}
