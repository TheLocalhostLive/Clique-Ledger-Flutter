class Participantspost {
  String id;
  num amount;

  Participantspost({
    required this.id,
    required this.amount,
  });

  // Convert a Participantspost instance to a Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
    };
  }

  // Create a Participantspost instance from a Map (JSON)
  factory Participantspost.fromJson(Map<String, dynamic> json) {
    return Participantspost(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(), // Convert num to double
    );
  }
}
