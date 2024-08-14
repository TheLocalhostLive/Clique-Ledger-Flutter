import 'package:cliqueledger/models/member.dart';
import 'package:cliqueledger/models/participants.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Transaction {
  @JsonKey(name: "transaction_id")
  final String id;
  @JsonKey(name: "clique_id")
  final String cliqueId;
  @JsonKey(name: "transaction_type")
  final String type;
  @JsonKey(name: "sender_id")
  final Member sender;
  final List<Participant> participants;
  @JsonKey(name: "amount")
  final num amount;
  @JsonKey(name: "done_at")
  final DateTime date;
  final String description;
  @JsonKey(name: "is_verified")
  final String isVerified;

  Transaction({
    required this.id,
    required this.cliqueId,
    required this.type,
    required this.sender,
    required this.participants,
    required this.amount,
    required this.date,
    required this.description,
    required this.isVerified,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    try {
      // Print each field to debug
      print("Parsing transaction_id: ${json['transaction_id']}");
      print("Parsing clique_id: ${json['clique_id']}");
      print("Parsing transaction_type: ${json['transaction_type']}");
      print("Parsing sender: ${json['sender']}");
      print("Parsing participants: ${json['participants']}");
      print("Parsing amount: ${json['amount']}");
      print("Parsing done_at: ${json['done_at']}");
      print("Parsing description: ${json['description']}");
      print("Parsing is_verified: ${json['is_verified']}");

      return Transaction(
        id: json['transaction_id'] as String,
        cliqueId: json['clique_id'] as String,
        type: json['transaction_type'] as String? ?? 'unknown',
        sender: Member.fromJson(json['sender']),
        participants: (json['participants'] as List)
            .map((e) => Participant.fromJson(e))
            .toList(),
        amount: json['amount'] as num? ?? 0,
        date: DateTime.parse(json['done_at'] as String),
        description: json['description'] as String? ?? '',
        isVerified: json['is_verified'] as String? ?? 'not_verified',
      );
    } catch (e) {
      print("Error parsing Transaction object: $e");
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': id,
      'clique_id': cliqueId,
      'transaction_type': type,
      'sender_id': sender.toJson(),
      'participants': participants.map((e) => e.toJson()).toList(),
      'amount': amount,
      'done_at': date.toIso8601String(),
      'description': description,
      'is_verified': isVerified,
    };
  }
}
