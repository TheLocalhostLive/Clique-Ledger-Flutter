import 'package:cliqueledger/models/clique_media.dart';
import 'package:flutter/foundation.dart';

class CliqueMediaProvider with ChangeNotifier {
  final Map<String, List<CliqueMediaResponse>> _cliqueMediaMap = {};
  bool isMediaScreenPreview = false;
  String filePath = '';
  Map<String, List<CliqueMediaResponse>> get cliqueMediaMap => _cliqueMediaMap;
  
  void initMap(String cliqueId, List<CliqueMediaResponse> ts) {
    _cliqueMediaMap[cliqueId] = ts;
    notifyListeners();
  }

 void addItem(String cliqueId, CliqueMediaResponse mediaRes) {
    if (_cliqueMediaMap.containsKey(cliqueId)) {
      _cliqueMediaMap[cliqueId]?.add(mediaRes);
    } else {
      _cliqueMediaMap[cliqueId] = [mediaRes];
    }
    notifyListeners();
  }

  void togglePreviewScreen() {
    isMediaScreenPreview = !isMediaScreenPreview;
    notifyListeners();
    
  }
}
