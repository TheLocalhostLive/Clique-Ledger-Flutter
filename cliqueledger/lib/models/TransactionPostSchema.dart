import 'package:cliqueledger/models/ParticipantsPost.dart';

class TransactionPostschema {
  final String type;
  final String sender;
  List<Participantspost> participants;
  final double amount;

  TransactionPostschema({
    required this.type,
    required this.sender,
    required this.participants,
    required this.amount,
  });

  // Convert a TransactionPostschema instance to a Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'sender': sender,
      'participants': participants.map((p) => p.toJson()).toList(),
      'amount': amount,
    };
  }

  // Create a TransactionPostschema instance from a Map (JSON)
  factory TransactionPostschema.fromJson(Map<String, dynamic> json) {
    return TransactionPostschema(
      type: json['type'] as String,
      sender: json['sender'] as String,
      participants: (json['participants'] as List<dynamic>)
          .map((p) => Participantspost.fromJson(p as Map<String, dynamic>))
          .toList(),
      amount: json['amount'] as double,
    );
  }
}