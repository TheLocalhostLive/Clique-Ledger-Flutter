import 'package:cliqueledger/models/cliqeue.dart';
import 'package:cliqueledger/models/member.dart';
import 'package:flutter/material.dart';

class CliqueListProvider with ChangeNotifier {
  Map<String,Clique> _activeCliqueList={};
  Map<String,Clique> _finishedCliqueList={};

  Map<String,Clique> get activeCliqueList => _activeCliqueList;
  Map<String,Clique> get finishedCliqueList => _finishedCliqueList;


  void setClique(Clique clique) {
    _activeCliqueList[clique.id] = clique;
    notifyListeners();
  }
  void setCliqueList(List<Clique> cliqueList){
      for(Clique cl in cliqueList){
        if(cl.isActive){
          _activeCliqueList[cl.id]=cl;
        }else{
          _finishedCliqueList[cl.id] = cl;
        }
      }
      notifyListeners();
  }
  void deleteMember(String cliqueId , String memberId){
    for(Member member in  _activeCliqueList[cliqueId]!.members){
      if(member.memberId == memberId){
        _activeCliqueList[cliqueId]!.members.remove(member);
        break;
      }
    }
    notifyListeners();
    
  }
  
}