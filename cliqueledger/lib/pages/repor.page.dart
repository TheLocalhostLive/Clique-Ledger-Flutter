// import 'package:cliqueledger/models/abstructReport.dart';
// import 'package:cliqueledger/models/detailsReport.dart';
// import 'package:flutter/material.dart';

// class ReportListPage extends StatefulWidget {
//   @override
//   _ReportListPageState createState() => _ReportListPageState();
// }

// class _ReportListPageState extends State<ReportListPage> {
//   List<AbstructReport> reports = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchReports();
//   }

//   Future<void> fetchReports() async {
//     // Fetch reports from your API
//     // Example:
//     // final response = await http.get('https://api.example.com/reports');
//     // List<AbstructReport> fetchedReports = (response.data as List).map((json) => AbstructReport.fromJson(json)).toList();

//     // For demonstration, we'll mock the data
//     List<AbstructReport> fetchedReports = [
//       AbstructReport(
//         userId: '1',
//         userName: 'John Doe',
//         email: 'john@example.com',
//         memberId: '123',
//         amount: 100,
//         isDue: true,
//         cliqueId: 'clique_1',
//         detailsReport: [
//           DetailsReport(
//             transactionId: 'tx_001',
//             date: '2024-08-01',
//             description: 'Transaction 1',
//             sendAmount: 50,
//             receiveAmount: 50,
//           ),
//           DetailsReport(
//             transactionId: 'tx_002',
//             date: '2024-08-02',
//             description: 'Transaction 2',
//             sendAmount: 30,
//             receiveAmount: 70,
//           ),
//         ],
//       ),
//       AbstructReport(
//         userId: '2',
//         userName: 'Jane Smith',
//         email: 'jane@example.com',
//         memberId: '124',
//         amount: 200,
//         isDue: false,
//         cliqueId: 'clique_2',
//         detailsReport: [
//           DetailsReport(
//             transactionId: 'tx_003',
//             date: '2024-08-03',
//             description: 'Transaction 3',
//             sendAmount: 80,
//             receiveAmount: 120,
//           ),
//         ],
//       ),
//       AbstructReport(
//         userId: '3',
//         userName: 'Alice Johnson',
//         email: 'alice@example.com',
//         memberId: '125',
//         amount: 150,
//         isDue: true,
//         cliqueId: 'clique_3',
//         detailsReport: [
//           DetailsReport(
//             transactionId: 'tx_004',
//             date: '2024-08-04',
//             description: 'Transaction 4',
//             sendAmount: 40,
//             receiveAmount: 110,
//           ),
//           DetailsReport(
//             transactionId: 'tx_005',
//             date: '2024-08-05',
//             description: 'Transaction 5',
//             sendAmount: 60,
//             receiveAmount: 90,
//           ),
//         ],
//       ),
//       AbstructReport(
//         userId: '4',
//         userName: 'Bob Brown',
//         email: 'bob@example.com',
//         memberId: '126',
//         amount: 250,
//         isDue: false,
//         cliqueId: 'clique_4',
//         detailsReport: [
//           DetailsReport(
//             transactionId: 'tx_006',
//             date: '2024-08-06',
//             description: 'Transaction 6',
//             sendAmount: 120,
//             receiveAmount: 130,
//           ),
//         ],
//       ),
//       AbstructReport(
//         userId: '5',
//         userName: 'Carol White',
//         email: 'carol@example.com',
//         memberId: '127',
//         amount: 180,
//         isDue: true,
//         cliqueId: 'clique_5',
//         detailsReport: [
//           DetailsReport(
//             transactionId: 'tx_007',
//             date: '2024-08-07',
//             description: 'Transaction 7',
//             sendAmount: 70,
//             receiveAmount: 110,
//           ),
//         ],
//       ),
//       AbstructReport(
//         userId: '6',
//         userName: 'Dave Green',
//         email: 'dave@example.com',
//         memberId: '128',
//         amount: 220,
//         isDue: false,
//         cliqueId: 'clique_6',
//         detailsReport: [
//           DetailsReport(
//             transactionId: 'tx_008',
//             date: '2024-08-08',
//             description: 'Transaction 8',
//             sendAmount: 100,
//             receiveAmount: 120,
//           ),
//         ],
//       ),
//       AbstructReport(
//         userId: '7',
//         userName: 'Eve Black',
//         email: 'eve@example.com',
//         memberId: '129',
//         amount: 140,
//         isDue: true,
//         cliqueId: 'clique_7',
//         detailsReport: [
//           DetailsReport(
//             transactionId: 'tx_009',
//             date: '2024-08-09',
//             description: 'Transaction 9',
//             sendAmount: 60,
//             receiveAmount: 80,
//           ),
//         ],
//       ),
//       AbstructReport(
//         userId: '8',
//         userName: 'Frank Gray',
//         email: 'frank@example.com',
//         memberId: '130',
//         amount: 190,
//         isDue: false,
//         cliqueId: 'clique_8',
//         detailsReport: [
//           DetailsReport(
//             transactionId: 'tx_010',
//             date: '2024-08-10',
//             description: 'Transaction 10',
//             sendAmount: 90,
//             receiveAmount: 100,
//           ),
//         ],
//       ),
//       AbstructReport(
//         userId: '9',
//         userName: 'Grace Lewis',
//         email: 'grace@example.com',
//         memberId: '131',
//         amount: 170,
//         isDue: true,
//         cliqueId: 'clique_9',
//         detailsReport: [
//           DetailsReport(
//             transactionId: 'tx_011',
//             date: '2024-08-11',
//             description: 'Transaction 11',
//             sendAmount: 50,
//             receiveAmount: 120,
//           ),
//         ],
//       ),
//       AbstructReport(
//         userId: '10',
//         userName: 'Henry Clark',
//         email: 'henry@example.com',
//         memberId: '132',
//         amount: 210,
//         isDue: false,
//         cliqueId: 'clique_10',
//         detailsReport: [
//           DetailsReport(
//             transactionId: 'tx_012',
//             date: '2024-08-12',
//             description: 'Transaction 12',
//             sendAmount: 110,
//             receiveAmount: 100,
//           ),
//         ],
//       ),
//       AbstructReport(
//         userId: '11',
//         userName: 'Ivy King',
//         email: 'ivy@example.com',
//         memberId: '133',
//         amount: 230,
//         isDue: true,
//         cliqueId: 'clique_11',
//         detailsReport: [
//           DetailsReport(
//             transactionId: 'tx_013',
//             date: '2024-08-13',
//             description: 'Transaction 13',
//             sendAmount: 130,
//             receiveAmount: 100,
//           ),
//         ],
//       ),
//       AbstructReport(
//         userId: '12',
//         userName: 'Jack Scott',
//         email: 'jack@example.com',
//         memberId: '134',
//         amount: 160,
//         isDue: false,
//         cliqueId: 'clique_12',
//         detailsReport: [
//           DetailsReport(
//             transactionId: 'tx_014',
//             date: '2024-08-14',
//             description: 'Transaction 14',
//             sendAmount: 80,
//             receiveAmount: 80,
//           ),
//         ],
//       ),
//     ];

//     setState(() {
//       reports = fetchedReports;
//     });
//   }

//   @override
//  Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFF10439F),
//       body: ListView.builder(
//         itemCount: reports.length,
//         itemBuilder: (context, index) {
//           Color tileColor = reports[index].isDue ? const Color(0xFFF27BBD) : const Color.fromARGB(255, 76, 204, 161)!;

//           return Container(
//             color: tileColor,
//             child: ExpansionTile(
//               title: Container(
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 80,
//                       child: Text('${reports[index].userName}'),
//                     ),
//                     const SizedBox(width: 80),
//                    Container(
//                     width: 50,
//                      child:reports[index].isDue ? Text("Due") : Text("Extra"),
//                    ),
//                     const SizedBox(width: 50),
//                     Text('${reports[index].amount}'),
//                   ],
//                 ),
//               ),
//               children: reports[index].detailsReport?.map((details) {
//                 return ListTile(
//                   title: Text(details.transactionId),
//                   subtitle: Text('${details.date} - ${details.description}'),
//                   trailing: Text(
//                     'Sent: ${details.sendAmount}, Received: ${details.receiveAmount}',
//                   ),
//                 );
//               }).toList() ?? [],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// void main() {
//   runApp(MaterialApp(home: ReportListPage()));
// }
