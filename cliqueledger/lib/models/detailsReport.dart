class DetailsReport{
  final String transactionId;
  final String date;
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
      date: json['date'],
      description: json['description'],
      sendAmount: json['send_amount'],
      receiveAmount: json['receive_amount']
    );
  }
}