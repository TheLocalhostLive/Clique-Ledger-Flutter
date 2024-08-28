import 'package:cliqueledger/models/abstruct_report.dart';
import 'package:cliqueledger/models/details_report.dart';
import 'package:flutter/material.dart';

class ReportsProvider with ChangeNotifier {
  Map<String,List<AbstructReport>> _reportList={};

  Map<String,List<AbstructReport>> get reportList => _reportList;



  void setReport(String cliqueId,List<AbstructReport> reports) {
    reportList[cliqueId] = reports;
    notifyListeners();
  }
  void setDetailsReport(String cliqueId, String memberId,List<DetailsReport> details){
      _reportList.forEach((k,v){
          if(k==cliqueId){
            for (var reports in v) {
              if(reports.memberId == memberId){
                reports.detailsReport = details;
                notifyListeners();
                return;
              }
            }
          }
      });
  }
  
}