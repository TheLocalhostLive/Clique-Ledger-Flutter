import 'package:cliqueledger/models/cliqeue.dart';
import 'package:cliqueledger/models/clique_media.dart';
import 'package:cliqueledger/models/member.dart';
import 'package:cliqueledger/models/transaction.dart';
import 'package:cliqueledger/providers/TransactionProvider.dart';
import 'package:cliqueledger/providers/cliqueProvider.dart';
import 'package:cliqueledger/providers/clique_media_provider.dart';
import 'package:cliqueledger/service/authservice.dart';
import 'package:flutter/material.dart';

class SocketEventHandler {

  static void handleCreateTranscation(dynamic data, TransactionProvider? transactionProvider) {
    final Transaction newTransaction = Transaction.fromJson(data);
    
    if(Authservice.instance.profile!.cliqueLedgerAppUid != newTransaction.sender.userId) {
      transactionProvider!.addSingleEntry(newTransaction.cliqueId, newTransaction);
    }
    
  }
  static void handleDeleteTransaction(data) {

  }
  static void handleAcceptTransaction(data) {

  }
  static void handleRejectTransaction(data) {

  }
  static void handleAddToClique(data) {

  }
  static void handleRemoveFromClique(data) {

  }

  static void handleMediaCreated(dynamic data, CliqueMediaProvider? cliqueMediaProvider, CliqueProvider? cliquesProvider) {
    final CliqueMediaResponse newMedia = CliqueMediaResponse.fromJson(data);
    debugPrint('new_media ${newMedia.senderId}');

    Member member = cliquesProvider!.getMemberById(newMedia.senderId);
    debugPrint('member=>> ${member.userId}');
    if(Authservice.instance.profile!.cliqueLedgerAppUid == member.userId) {
      cliqueMediaProvider!.deleteByMediaId (newMedia.cliqueId, "DUMMY");
    } 
    cliqueMediaProvider!.addItem(newMedia.cliqueId, newMedia);
  }


  void handleEvent(String event, dynamic data) {
    
    
    
  }  
  
  SocketEventHandler._internal();
}