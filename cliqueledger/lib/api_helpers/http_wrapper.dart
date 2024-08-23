import 'package:cliqueledger/utility/constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HTTPWrapper {
  String? apiResponse;
  String? apiError;
  String endpoint;
  String method;
  String? accessToken;
  Map<String, String>? addtionalHeaders;

  final Map<String, Function> _requestMethodMap = {
    "GET": http.get,
    "POST": http.post,
    "PATCH": http.patch,
    "DELETE": http.delete
  };

  HTTPWrapper(
      {required this.endpoint,
      required this.method,
      this.accessToken,
      this.addtionalHeaders}) {
    method.toUpperCase();
    if (!_requestMethodMap.containsKey(method)) {
      throw ArgumentError('Invalid HTTP method: $method');
    }
  }

  Uri? _url;
  Map<String, String> _headers = {};

  void _prepareRequest() {
    _url = Uri.parse('$BASE_URL/$endpoint');
    
    _headers = {'Content-Type': 'application/json'};
    if (accessToken != null) {
      _headers.addEntries({'Authorization': 'Bearer $accessToken'}.entries);
    }
    if (addtionalHeaders != null) {
      _headers.addEntries(addtionalHeaders!.entries);
    }
  }

  Future<String> sendRequest() async {
    _prepareRequest();
    debugPrint("Sending request to ${_url.toString()}");
    try {
      http.Response response = await _requestMethodMap[method]!(_url, headers: _headers);
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        debugPrint("Response is successful! Code ${response.statusCode}");
        debugPrint('We recieved: ${response.body}');

        return response.body;
      }

      debugPrint("The request was unsuccessful!");
      debugPrint("The response code is ${response.statusCode}");
      debugPrint("API Response Body");
      debugPrint(response.body);

      return response.body;
    } catch (err) {
      debugPrint("ERROR:: There was an error while sending the request");
      debugPrint(err.toString());
    }

    return "";
  }

  void handleErrors() {}
}
