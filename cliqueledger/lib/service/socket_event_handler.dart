import 'dart:convert';

import 'package:cliqueledger/api_helpers/http_wrapper.dart';
import 'package:cliqueledger/models/cliqeue.dart';
import 'package:cliqueledger/models/clique_media.dart';
import 'package:cliqueledger/models/member.dart';
import 'package:cliqueledger/models/transaction.dart';
import 'package:cliqueledger/providers/Clique_list_provider.dart';
import 'package:cliqueledger/providers/transaction_provider.dart';
import 'package:cliqueledger/providers/clique_provider.dart';
import 'package:cliqueledger/providers/clique_media_provider.dart';
import 'package:cliqueledger/service/authservice.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketEventHandler {
  static void handleCreateTranscation(
      dynamic data,
      TransactionProvider? transactionProvider,
      CliqueListProvider? cliqueListProvider) {
    final Transaction newTransaction = Transaction.fromJson(data);

    if (Authservice.instance.profile!.cliqueLedgerAppUid !=
        newTransaction.sender.userId) {
      transactionProvider!
          .addSingleEntry(newTransaction.cliqueId, newTransaction);
      cliqueListProvider!.activeCliqueList[newTransaction.cliqueId]!
          .latestTransaction = newTransaction;
    }
  }

  static void handleDeleteTransaction(data) {}
  static void handleAcceptTransaction(data) {}
  static void handleRejectTransaction(data) {}

  static void handleAddToClique(
      dynamic data, CliqueListProvider? cliqueListProvider, IO.Socket? socket) async {
    
    print(data);
    final jsonBody = jsonDecode(data);
    
    String cliqueId = jsonBody["data"]["cliqueId"];
    String? accessToken = Authservice.instance.accessToken;


    try {
      HTTPWrapper request = HTTPWrapper(
          endpoint: 'cliques/$cliqueId/',
          method: 'GET',
          accessToken: accessToken);
      dynamic response = await request.sendRequest();

      Clique clique = Clique.fromJson(jsonDecode(response));
      
      cliqueListProvider!.setClique(clique);
      

    } catch (err) {
      debugPrint(
          "SocketEventHanlder:: There is an error in handleAddToClique ");
    }
  }

  static void handleRemoveFromClique(data) {}

  static void handleMediaCreated(
      dynamic data,
      CliqueMediaProvider? cliqueMediaProvider,
      CliqueProvider? cliquesProvider) {
    final CliqueMediaResponse newMedia = CliqueMediaResponse.fromJson(data);
    debugPrint('new_media ${newMedia.senderId}');

    Member member = cliquesProvider!.getMemberById(newMedia.senderId);
    debugPrint('member=>> ${member.userId}');
    if (Authservice.instance.profile!.cliqueLedgerAppUid != member.userId) {
      cliqueMediaProvider!.addItem(newMedia.cliqueId, newMedia);
    }
  }

  void handleEvent(String event, dynamic data) {}

  SocketEventHandler._internal();
}
