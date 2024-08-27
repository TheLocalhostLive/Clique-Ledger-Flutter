import 'package:cliqueledger/models/member.dart';
import 'package:cliqueledger/models/transaction.dart';

class Clique {
  final String id;
   String name;
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
    num? fund, // Corrected from int? to num?
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
  

  static List<Member> _parseMembers(dynamic membersJson) {
    if (membersJson is List) {
      return membersJson.map((item) => Member.fromJson(item as Map<String, dynamic>)).toList();
    } else if (membersJson is Map) {
      return [Member.fromJson(membersJson as Map<String, dynamic>)];
    }
    return [];
  }

 static Transaction _formatLastTransaction(Map<String, dynamic> json) {
  List<Member> allMembers = _parseMembers(json['members']);
  LastTransaction lastTransaction = LastTransaction.fromJson(json['last_transaction']);
  
  Member? senderMember = allMembers.firstWhere(
    (member) => member.memberId == lastTransaction.sender,
    orElse: () => Member(name: '', memberId: '', userId: '', email: '' , isAdmin: false),
  );

  return Transaction(
    id: lastTransaction.id,
    cliqueId: lastTransaction.cliqueId,
    type: lastTransaction.type,
    sender: senderMember,
    participants: [],
    amount: lastTransaction.amount,
    date: lastTransaction.date,
    description: lastTransaction.description ?? '', // Provide a default empty string
    isVerified: lastTransaction.isVerified ?? '',  // Provide a default empty string
  );
}

  factory Clique.fromJson(Map<String, dynamic> json) {
    return Clique(
      id: json['clique_id'] as String? ?? '',
      name: json['clique_name'] as String? ?? '', 
      admins: _parseMembers(json['admins']),
      members: _parseMembers(json['members']),
      isActive: json['isActive'] as bool? ?? false, 
      latestTransaction: json['last_transaction'] != null
          ? _formatLastTransaction(json)
          : null, 
      fund: json['fund'] ?? 0, 
      isFund: json['isFund'] as bool? ?? false, 
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

class LastTransaction {
  final String id;
  final String cliqueId;
  final String type;
  final String sender;
  final num amount;
  final DateTime date;
  final String? description; // Made nullable
  final String? isVerified; // Made nullable

  LastTransaction({
    required this.id,
    required this.cliqueId,
    required this.type,
    required this.sender,
    required this.amount,
    required this.date,
    this.description, // Nullable
    this.isVerified, // Nullable
  });

  factory LastTransaction.fromJson(Map<String, dynamic> json) {
    return LastTransaction(
      id: json['transaction_id'] ?? '', // Default to empty string if null
      cliqueId: json['clique_id'] ?? '', // Default to empty string if null
      type: json['transaction_type'] ?? '', // Default to empty string if null
      sender: json['sender_id'] ?? '', // Default to empty string if null
      amount: json['amount'] ?? 0, // Default to 0 if null
      date: DateTime.parse(json['done_at']), // Parsing date properly
      description: json['description'], // Nullable
      isVerified: json['is_verified'], // Nullable
    );
  }
}