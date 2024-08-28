import 'package:cliqueledger/models/details_report.dart';

class AbstructReport{
  final String userId;
  final String userName;
  final String email;
  final String memberId;
  final num    amount;
  final bool   isDue;
  final String cliqueId;
   List<DetailsReport>? detailsReport;
  AbstructReport({
        required this.userId,
        required this.userName,
        required this.email,
        required this.memberId,
        required this.amount,
        required this.isDue,
        required this.cliqueId,
        this.detailsReport,

  });
   factory AbstructReport.fromJson(Map<String, dynamic> json) {
    return AbstructReport(
      userId: json['user_id'],
      userName: json['user_name'],
      email: json['mail'],
      memberId: json['member_id'],
      amount: json['amount'],
      isDue: json['is_due'],
      cliqueId: json['clique_id'],
      detailsReport: json['details_report'] != null
          ? (json['details_report'] as List)
              .map((item) => DetailsReport.fromJson(item))
              .toList()
          : null,
    );
  }

}