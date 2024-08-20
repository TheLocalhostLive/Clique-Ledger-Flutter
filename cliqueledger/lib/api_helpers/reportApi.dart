import 'dart:convert';

import 'package:cliqueledger/models/abstructReport.dart';
import 'package:cliqueledger/models/detailsReport.dart';
import 'package:cliqueledger/providers/reportsProvider.dart';
import 'package:cliqueledger/service/authservice.dart';
import 'package:cliqueledger/utility/constant.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class ReportApi {
  String? accessToken = Authservice.instance.accessToken;
  List<AbstructReport> abstructReport = [];
  List<DetailsReport> detailsReport =[];
  Future <void> getOverAllReport(String cliqueId,ReportsProvider reportsProvider ,BuildContext context) async{
    print('Abstruct Report : $cliqueId');
    Uri uriGet = Uri.parse('$BASE_URL/ledgers/clique/$cliqueId');
    try {
      final response = await http.get(uriGet,
      headers: {
        'Authorization': 'Bearer $accessToken',
      });
      if(response.statusCode == 200){
         print('Response Body: ${response.body}');
        final List<dynamic> jsonList = json.decode(response.body);
        abstructReport = jsonList.map((jsonItem)=>AbstructReport.fromJson(jsonItem)).toList();
        print("Data Fetched Sucessfully");
        reportsProvider.setReport(cliqueId,abstructReport);
        ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Report fetched Successfully')),
                    );
      }else{
          print("Error while fetching data: ${response.statusCode}");
          ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Report fetched Failed')),
                    );
      }
    } catch (e) {
      print("Exception occurred: $e");
    }

  }

  Future<void> getDetailsReport(String cliqueId , String memberId,ReportsProvider reportsProvider) async{
    print("Details Report :");
    print('memberId:$memberId');
    print('cliqueId:$cliqueId');
    Uri uriGet = Uri.parse('${BASE_URL}/ledgers/clique/$cliqueId/member/$memberId');
    try {
      final response = await http.get(uriGet,
      headers: {
        'Authorization': 'Bearer $accessToken',
      });
      if(response.statusCode == 200){
         print('Response Body: ${response.body}');
        final List<dynamic> jsonList = json.decode(response.body);
        detailsReport = jsonList.map((jsonItem)=>DetailsReport.fromJson(jsonItem)).toList();
        print("Data Fetched Sucessfully");
        reportsProvider.setDetailsReport(cliqueId, memberId, detailsReport);
      }else{
        print("Error while fetching data: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception occurred: $e");
    }
  }


}
