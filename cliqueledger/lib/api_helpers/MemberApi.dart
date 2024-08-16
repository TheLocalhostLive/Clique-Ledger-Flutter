import 'dart:convert';
import 'package:cliqueledger/service/authservice.dart';
import 'package:cliqueledger/utility/constant.dart';
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
  static Future<void> addUserPost(List<String> userIds) async{

  }
}