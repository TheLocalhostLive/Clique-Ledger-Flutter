import 'package:cliqueledger/models/ParticipantsPost.dart';

class TransactionPostschema {
  final String cliqueId;
  final String type;
  List<Participantspost> participants;
  final num amount;
  final String description;

  TransactionPostschema({
    required this.cliqueId,
    required this.type,
    required this.participants,
    required this.amount,
    required this.description
  });

  // Convert a TransactionPostschema instance to a Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'cliqueId' : cliqueId,
      'type': type,
      'participants': participants.map((p) => p.toJson()).toList(),
      'amount': amount,
      'description':description
    };
  }

  // Create a TransactionPostschema instance from a Map (JSON)
  factory TransactionPostschema.fromJson(Map<String, dynamic> json) {
    return TransactionPostschema(
      cliqueId: json['clique_id'],
      type: json['type'] as String,
      participants: (json['participants'] as List<dynamic>)
          .map((p) => Participantspost.fromJson(p as Map<String, dynamic>))
          .toList(),
      amount: json['amount'] as double,
      description: json['description'] as String
    );
  }
}