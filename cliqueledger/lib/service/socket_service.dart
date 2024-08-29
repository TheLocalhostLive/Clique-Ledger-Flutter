import 'dart:convert';

import 'package:cliqueledger/models/transaction.dart';
import 'package:cliqueledger/providers/Clique_list_provider.dart';
import 'package:cliqueledger/providers/transaction_provider.dart';
import 'package:cliqueledger/providers/clique_provider.dart';
import 'package:cliqueledger/providers/clique_media_provider.dart';
import 'package:cliqueledger/service/authservice.dart';
import 'package:cliqueledger/service/socket_event_handler.dart';
import 'package:cliqueledger/utility/constant.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService instance = SocketService._internal();

  static IO.Socket? socket;
  static TransactionProvider? transactionProvider;
  static CliqueListProvider? cliqueListProvider;
  static CliqueMediaProvider? cliqueMediaProvider;
  static CliqueProvider? cliqueProvider;

  final Map<String, dynamic> _eventHandlerMap = {
    "transaction-created": (data) => SocketEventHandler.handleCreateTranscation(data, transactionProvider, cliqueListProvider),
    "transaction-deleted": SocketEventHandler.handleDeleteTransaction,
    "transaction-accepted": SocketEventHandler.handleAcceptTransaction,
    "transaction-rejected": SocketEventHandler.handleRejectTransaction,
    "added-to-clique": (data) => SocketEventHandler.handleAddToClique(data, cliqueListProvider, socket),
    "removed-from-clique": SocketEventHandler.handleRemoveFromClique,
    "media-created": (data) => SocketEventHandler.handleMediaCreated(data, cliqueMediaProvider, cliqueProvider)
  };

  SocketService._internal();

  Transaction? transaction;

  Function(dynamic data)? onLoginEvent;
  Function(dynamic data)? onLogoutEvent;

  factory SocketService() {
    return instance;
  }
  String? token = Authservice.instance.accessToken;
  void connectAndListen() {
    if (socket != null) return;
    debugPrint("Connection to socket...");
    socket ??= IO.io('http://$HOST/?token=$token',
        IO.OptionBuilder().setTransports(['websocket']).build());

    socket!.onConnect((data) => {print("Connected to socket")});

    socket!.on('session-expired', (data) => {onLogoutEvent?.call(data)});

    socket!.on('session-join', (data) => {onLogoutEvent?.call(data)});
  }

  //rooms are basically cliqueId
  void joinRooms(List<String> rooms) {
    socket!.emit('join-rooms', jsonEncode(rooms));
  }

  void setupListeners() {
    _eventHandlerMap.keys.toList().forEach((event) {
      socket!.on(event, (data) {
        _eventHandlerMap[event](data);
      });
    });
  }

  void dispose() {
    if (socket != null) {
      socket!.disconnect();
    }
  }
}
