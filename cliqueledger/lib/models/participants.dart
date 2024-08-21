

import 'package:json_annotation/json_annotation.dart';

class Participant {
  @JsonKey(name: "member_name")  // Adjusted to match JSON field
  final String name;
  
  @JsonKey(name: "member_id")
  final String memberId;

  @JsonKey(name: "part_amount")
  final int partAmount;

  Participant({
    required this.name,
    required this.memberId,
    required this.partAmount,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      name: json['member_name'] as String,
      memberId: json['member_id'] as String,
      partAmount: json['part_amount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_name': name,
      'member_id': memberId,
      'part_amount': partAmount,
    };
  }
}


