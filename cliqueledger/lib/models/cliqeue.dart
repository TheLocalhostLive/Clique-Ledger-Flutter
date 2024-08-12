import 'package:cliqueledger/models/member.dart';
import 'package:cliqueledger/models/transaction.dart';

class Clique {
  final String id;
  final String name;
  final List<Member> admins;
  final List<Member> members;
  final bool isActive;
  Transaction? latestTransaction;
  final num fund; 
  final bool isFund;

  Clique({
    required this.id,
    required this.name,
    required this.admins,
    required this.members,
    required this.isActive,
    this.latestTransaction,
    required this.fund,
    required this.isFund,
  });

  Clique copyWith({
    String? id,
    String? name,
    List<Member>? admins,
    List<Member>? members,
    bool? isActive,
    Transaction? latestTransaction,
    int? fund,
    bool? isFund,
  }) {
    return Clique(
      id: id ?? this.id,
      name: name ?? this.name,
      admins: admins ?? this.admins,
      members: members ?? this.members,
      isActive: isActive ?? this.isActive,
      latestTransaction: latestTransaction ?? this.latestTransaction,
      fund: fund ?? this.fund,
      isFund: isFund ?? this.isFund,
    );
  }

  factory Clique.fromJson(Map<String, dynamic> json) {
    return Clique(
      id: json['clique_id'] as String? ?? '', // Default to empty string if null
      name: json['clique_name'] as String? ?? '', // Default to empty string if null
      admins: (json['admins'] as List<dynamic>?)
              ?.map((item) => Member.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [], // Default to empty list if null
      members: (json['members'] as List<dynamic>?)
              ?.map((item) => Member.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [], // Default to empty list if null
      isActive: json['isActive'] as bool? ?? false, // Default to false if null
      latestTransaction: json['latestTransaction'] != null
          ? Transaction.fromJson(json['latestTransaction'] as Map<String, dynamic>)
          : null, // Handle nullable Transaction
      fund: json['fund'] ?? 0, // Default to 0.0 if null
      isFund: json['isFund'] as bool? ?? false, // Default to false if null
    );    
  }         
  Map<String, dynamic> toJson() => {
        'clique_id': id,
        'clique_name': name,
        'admins': admins.map((admin) => admin.toJson()).toList(),
        'members': members.map((member) => member.toJson()).toList(),
        'isActive': isActive,
        'latestTransaction': latestTransaction?.toJson(), // Handle nullable Transaction
        'fund': fund,
        'isFund': isFund,
      };
            
}
