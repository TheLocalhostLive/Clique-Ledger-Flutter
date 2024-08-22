import 'dart:convert';

import 'package:cliqueledger/api_helpers/http_wrapper.dart';
import 'package:cliqueledger/models/clique_media.dart';
import 'package:cliqueledger/providers/clique_media_provider.dart';
import 'package:cliqueledger/service/authservice.dart';
import 'package:cliqueledger/utility/constant.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class CliqueMedia {
  

  static Future<CliqueMediaResponse?> uploadFile(File file, String cliqueId) async {
    String? accessToken = Authservice.instance.accessToken; 
    final uri = Uri.http('192.168.0.103:3000', 'api/v1/cliques/$cliqueId/media');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $accessToken';

    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    try {
      final response = await request.send();
      if (response.statusCode == 201) {
        debugPrint('File uploaded successfully.');
        String responseBody = await response.stream.bytesToString();
        debugPrint(responseBody);
        final jsonResponse = jsonDecode(responseBody); 
        return CliqueMediaResponse.fromJson(jsonResponse);
      } 
      
      debugPrint('File upload failed with status: ${response.statusCode}');
        
      
    } catch (e) {
      debugPrint('Error uploading file: $e');
    }

    return null;
  }

  static void getMedia(
      CliqueMediaProvider cliqueMediaProvider, String cliqueId) async {
    String? accessToken = Authservice.instance.accessToken;

    try {
      HTTPWrapper request = HTTPWrapper(
          endpoint: 'cliques/$cliqueId/media', method: 'GET', accessToken: accessToken);
      String response = await request.sendRequest();
      List<Map<String, dynamic>> jsonArr = List<Map<String, dynamic>>.from(jsonDecode(response));

      List<CliqueMediaResponse> cliqueMediaResponses = jsonArr.map((json) {
        return CliqueMediaResponse.fromJson(json);
      }).toList();

      cliqueMediaProvider.initMap(cliqueId, cliqueMediaResponses);
    } catch (err) {
      debugPrint("Error while Media response");
      print(err);
    }
  }
}
