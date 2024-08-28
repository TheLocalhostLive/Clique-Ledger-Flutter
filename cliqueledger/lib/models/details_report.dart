class DetailsReport{
  final String transactionId;
  final DateTime date;
  final String description;
  final num? sendAmount;
  final num? receiveAmount;

  DetailsReport({
    required this.transactionId,
    required this.date,
    required this.description,
    this.sendAmount,
    this.receiveAmount,
  });
  
  factory DetailsReport.fromJson(Map<String,dynamic> json){
    return DetailsReport
    (
      transactionId: json['transaction_id'],
      date: DateTime.parse(json['date'] as String),
      description: json['description'],
      sendAmount: json['send_amount'],
      receiveAmount: json['receive_amount']
    );
  }
}