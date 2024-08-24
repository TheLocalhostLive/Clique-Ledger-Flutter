import 'package:cliqueledger/api_helpers/MemberApi.dart';
import 'dart:io';

import 'package:cliqueledger/api_helpers/clique_media.dart';
import 'package:cliqueledger/api_helpers/fetchTransactions.dart';
import 'package:cliqueledger/api_helpers/reportApi.dart';
import 'package:cliqueledger/api_helpers/transactionPost.dart';
import 'package:cliqueledger/models/ParticipantsPost.dart';
import 'package:cliqueledger/models/TransactionPostSchema.dart';
import 'package:cliqueledger/models/cliqeue.dart';
import 'package:cliqueledger/models/abstructReport.dart';
import 'package:cliqueledger/models/detailsReport.dart';
import 'package:cliqueledger/models/member.dart';
import 'package:cliqueledger/models/participants.dart';
import 'package:cliqueledger/pages/spendTransactionSliderPage.dart';
import 'package:cliqueledger/providers/CliqueListProvider.dart';
import 'package:cliqueledger/providers/TransactionProvider.dart';
import 'package:cliqueledger/providers/cliqueProvider.dart';
import 'package:cliqueledger/providers/reportsProvider.dart';
import 'package:cliqueledger/providers/clique_media_provider.dart';
import 'package:cliqueledger/themes/appBarTheme.dart';
import 'package:cliqueledger/utility/routers_constant.dart';
import 'package:cliqueledger/widgets/media_tab.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:cliqueledger/models/transaction.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Cliquepage extends StatefulWidget {
  const Cliquepage({super.key});

  @override
  State<Cliquepage> createState() => _CliquepageState();
}

class _CliquepageState extends State<Cliquepage>
    with SingleTickerProviderStateMixin {
  final TransactionList transactionList = TransactionList();
  final ReportApi reportApi = ReportApi();

  late TransactionProvider transactionProvider;
  late CliqueProvider cliqueProvider;
  late TabController _tabController;
  bool isGenerateButtonClicked = false;

  PickImage pickImage = PickImage();

  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cliqueProvider = context.read<CliqueProvider>();
      final transactionProvider = context.read<TransactionProvider>();
      final cliqueMediaProvider = context.read<CliqueMediaProvider>();
      fetchTransactions(cliqueProvider, transactionProvider);
      if (cliqueProvider.currentClique != null) {
        CliqueMedia.getMedia(
            cliqueMediaProvider, cliqueProvider.currentClique!.id);
      }
    });
  }

  Future<void> fetchTransactions(CliqueProvider cliqueProvider,
      TransactionProvider transactionProvider) async {
    if (cliqueProvider.currentClique != null) {
      final cliqueId = cliqueProvider.currentClique!.id;
      if (!transactionProvider.transactionMap.containsKey(cliqueId)) {
        print('Clique Id : $cliqueId');
        await transactionList.fetchData(cliqueId);
        transactionProvider.addAllTransaction(
            cliqueId, transactionList.transactions);
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> getAbstructReport(String cliqueId,
      ReportsProvider reportsProvider, BuildContext context) async {
    setState(() {
      isLoading = true; // Show loading while fetching
    });
    try {
      await reportApi.getOverAllReport(cliqueId, reportsProvider, context);
    } catch (e) {
      print("Error fetching abstract report: $e");
    } finally {
      setState(() {
        isLoading = false; // Hide loading after fetching
      });
    }
  }

  void _createTransaction(
      BuildContext context,
      CliqueProvider cliqueProvider,
      TransactionProvider transactionProvider,
      CliqueListProvider cliqueListProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Define state variables
        String transactionType = 'spend';
        num amount = 0.0;
        List<Map<String, String>> selectedMembers = [];
        String? amountError;
        String? transactionTypeError;
        String description = "Description is not Present";
        String? descriptionError;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // Calculate available height by considering the keyboard height
            double availableHeight = MediaQuery.of(context).size.height -
                MediaQuery.of(context).viewInsets.bottom -
                100;

            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                'Create Transaction',
                style: TextStyle(fontWeight: FontWeight.w200),
              ),
              content: SingleChildScrollView(
                child: Container(
                  width: double.maxFinite,
                  constraints: BoxConstraints(maxHeight: availableHeight),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Amount Field
                      TextFormField(
                        cursorColor: Color.fromARGB(255, 114, 4, 32),
                        decoration: InputDecoration(
                          floatingLabelStyle:
                              TextStyle(color: Color(0xFFE4003A)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 114, 4, 32),
                          )),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 114, 4, 32),
                          )),
                          labelText: 'Amount',
                          border: OutlineInputBorder(),
                          errorText: amountError,
                          prefixIcon: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '₹', // Indian Rupee symbol
                                  style: TextStyle(fontSize: 18),
                                ),
                                SizedBox(
                                    width:
                                        4), // Space between the symbol and the input
                              ],
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            try {
                              amount = num.parse(value);
                              amountError = null; // Clear error if valid
                            } catch (e) {
                              amountError = 'Invalid amount';
                            }
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Amount is required';
                          }
                          try {
                            double.parse(value);
                            return null;
                          } catch (e) {
                            return 'Invalid amount';
                          }
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        cursorColor: Color.fromARGB(255, 114, 4, 32),
                        decoration: InputDecoration(
                          floatingLabelStyle:
                              TextStyle(color: Color(0xFFE4003A)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 114, 4, 32),
                          )),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Color.fromARGB(255, 114, 4, 32),
                          )),
                          labelText: 'Description',
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFE4003A))),
                          errorText: descriptionError,
                          prefixIcon: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              '₹', // Indian Rupee symbol
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          setState(() {
                            description = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Description is required';
                          }
                          return null; // No error if the value is valid
                        },
                      ),

                      // Transaction Type Dropdown
                      DropdownButton<String>(
                        value: transactionType,
                        items: <String>['send', 'spend'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            transactionType = newValue!;
                            transactionTypeError = null; // Clear error if valid
                          });
                        },
                        isExpanded: true,
                      ),
                      if (transactionTypeError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            transactionTypeError!,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      SizedBox(height: 16),
                      // Members Checkboxes
                      Expanded(
                        child: ListView(
                          children: cliqueProvider.currentClique!.members
                              .map((member) {
                            if (transactionType == "send") {
                              return RadioListTile(
                                activeColor: Color(0xFFE4003A),
                                title: Text(member.name),
                                value: member.memberId,
                                groupValue: selectedMembers.isNotEmpty
                                    ? selectedMembers[0]['memberId']
                                    : null,
                                onChanged: (String? value) {
                                  setState(() {
                                    selectedMembers.clear();
                                    selectedMembers.add({
                                      'memberId': value!,
                                      'name': member.name,
                                    });
                                  });
                                },
                                controlAffinity: ListTileControlAffinity
                                    .trailing, // Add this line to move the radio button to the end
                              );
                            } else {
                              return CheckboxListTile(
                                activeColor: Color(0xFFE4003A),
                                title: Text(member.name),
                                value: selectedMembers.any((element) =>
                                    element['memberId'] == member.memberId),
                                onChanged: (bool? checked) {
                                  setState(() {
                                    if (checked == true) {
                                      selectedMembers.add({
                                        'memberId': member.memberId,
                                        'name': member.name,
                                      });
                                    } else {
                                      selectedMembers.removeWhere((element) =>
                                          element['memberId'] ==
                                          member.memberId);
                                    }
                                  });
                                },
                              );
                            }
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    // Validation
                    bool isValid = true;

                    if (amount <= 0) {
                      setState(() {
                        amountError = 'Amount cannot be empty or zero';
                      });
                      isValid = false;
                    }
                    if (transactionType.isEmpty) {
                      setState(() {
                        transactionTypeError =
                            'Please select a transaction type';
                      });
                      isValid = false;
                    }

                    if (transactionType == "send" &&
                        selectedMembers.length > 1) {
                      setState(() {
                        transactionTypeError =
                            'When Send is Selected only one Member can be chosen';
                      });
                      isValid = false;
                    }

                    if (isValid) {
                      if (transactionType == "send") {
                        String type = transactionType;
                        List<Participantspost> participants = [
                          Participantspost(
                              id: selectedMembers[0]['memberId']!,
                              amount: amount)
                        ];
                        String cliqueId = cliqueProvider.currentClique!.id;
                        TransactionPostschema tSchema = TransactionPostschema(
                            cliqueId: cliqueId,
                            type: type,
                            participants: participants,
                            amount: amount,
                            description: description);
                        print('description : $description');
                        print('cliqueId : $cliqueId');
                        print('amount: $amount');
                        await TransactionPost.postData(
                            tSchema,
                            transactionProvider,
                            cliqueProvider,
                            cliqueListProvider);
                      } else {
                        context.push(
                          RoutersConstants.SPEND_TRANSACTION_SLIDER_PAGE,
                          extra: {
                            'selectedMembers': selectedMembers,
                            'amount': amount,
                            'description': description
                          },
                        );
                      }
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFB200),
                  ),
                  child: Text(
                    'Create Transaction',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ReportsProvider reportsProvider = Provider.of<ReportsProvider>(context);
    CliqueMediaProvider cliqueMediaProvider =
        Provider.of<CliqueMediaProvider>(context);
    return Consumer3<CliqueListProvider, CliqueProvider, TransactionProvider>(
      builder: (context, cliqueListProvider, cliqueProvider,
          transactionProvider, child) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                "Clique Ledger",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: <Widget>[
                IconButton(
                  onPressed: () {
                    context.push(RoutersConstants.CLIQUE_SETTINGS_ROUTE);
                  },
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.white,
                  ),
                )
              ],
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  //color: Color(0xFF800000),
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 128, 6,
                          37), // Note the use of 0xFF prefix for hex colors
                      Color(0xFFEB5B00),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            body: Column(
              children: [
                TabBar(
                    indicatorColor: const Color(0xFFFFB200),
                    controller: _tabController,
                    tabs: [
                      Tab(
                        child: Text("Transaction",
                            style: TextStyle(
                                color: Color.fromARGB(255, 102, 2, 27))),
                      ),
                      Tab(
                        child: Text("Media",
                            style: TextStyle(
                                color: Color.fromARGB(255, 102, 2, 27))),
                      ),
                      Tab(
                        child: Text("Report",
                            style: TextStyle(
                                color: Color.fromARGB(255, 102, 2, 27))),
                      ),
                    ]),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : transactionProvider
                                      .transactionMap[
                                          cliqueProvider.currentClique!.id]
                                      ?.isEmpty ??
                                  true
                              ? const Center(
                                  child: Text("No Transaction to show"))
                              : TransactionsTab(
                                  transactions:
                                      transactionProvider.transactionMap[
                                          cliqueProvider.currentClique!.id]!,
                                ),
                      CliqueMediaTab(cliqueMediaProvider: cliqueMediaProvider),
                      !isGenerateButtonClicked ||
                              !reportsProvider.reportList
                                  .containsKey(cliqueProvider.currentClique!.id)
                          ? const Center(child: Text('Report is Empty'))
                          : ReportTab(
                              cliqueProvider: cliqueProvider,
                              reportsProvider: reportsProvider),
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButton: IndexedStack(
              index: _tabController.index,
              children: [
                FloatingActionButton(
                  heroTag: 'btn1',
                  onPressed: () => _createTransaction(
                    context,
                    cliqueProvider,
                    transactionProvider,
                    cliqueListProvider,
                  ),
                  tooltip: 'Create Transaction',
                  backgroundColor: const Color(0xFFFFB200),
                  child: const Icon(
                    Icons.add,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
                FloatingActionButton(
                  heroTag: 'btn2',
                  onPressed: () {
                    // Handle action for the "Media" tab
                    pickImage.showImagePickerOption(context);
                  },
                  tooltip: 'Add Media',
                  backgroundColor: const Color(0xFFFFB200),
                  child: const Icon(
                    Icons.photo,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
                FloatingActionButton(
                  heroTag: 'btn3',
                  onPressed: () async {
                    print('clicked');
                    await getAbstructReport(cliqueProvider.currentClique!.id,
                        reportsProvider, context);
                    setState(() {
                      isGenerateButtonClicked = true;
                    });
                  },
                  tooltip: 'Generate Report',
                  backgroundColor: const Color(0xFFFFB200),
                  child: const Icon(
                    Icons.report,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TransactionsTab extends StatelessWidget {
  final List<Transaction> transactions;

  const TransactionsTab({required this.transactions});

  void _checkTransaction(BuildContext context, Transaction t) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text(
                'Transaction Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (t.type == "send") ...[
                      Text(
                        "Send Transaction",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w200,
                            fontSize: 16),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        '${t.sender.name} : \u{20B9}${t.amount.toStringAsFixed(2) ?? 'N/A'} paid to ${t.participants[0].name}',
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ] else ...[
                      Text(
                        "Spend Transaction",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w200,
                            fontSize: 16),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        '${t.sender.name} Paid Total: \u{20B9}${t.amount?.toStringAsFixed(2) ?? 'N/A'} To -',
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 10),
                      ...t.participants
                          .map(
                            (p) => Text(
                              '${p.name} - \u{20B9}${p.partAmount}',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey[700],
                              ),
                            ),
                          )
                          .toList(),
                    ],
                    SizedBox(height: 20),
                    Text(
                      'Description:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${t.description}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () => {},
                      child: const Text(
                        "Verify",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 150, 4, 41),
                        minimumSize:
                            Size(double.infinity, 36), // Full-width button
                        padding: const EdgeInsets.symmetric(
                            vertical: 12), // Add vertical padding
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    'Close',
                    style: TextStyle(color: Color.fromARGB(255, 150, 4, 41)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: transactions.map((tx) {
        return Center(
          child: Container(
            // margin:
            //     const EdgeInsets.symmetric(vertical: 10.0, horizontal: 100.0),
            margin: const EdgeInsets.fromLTRB(60, 10, 5, 10),
            width: MediaQuery.of(context).size.width * 0.7,
            height: 100, // Set desired height
            child: Card(
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: InkWell(
                borderRadius: BorderRadius.circular(20.0),
                focusColor: Colors.amberAccent,
                onTap: () => _checkTransaction(context, tx),
                child: Container(
                  decoration: BoxDecoration(
                      color: Color.fromARGB(255, 254, 246, 235),
                      // gradient: const LinearGradient(
                      //   colors: [
                      //     Colors.redAccent,
                      //         // Note the use of 0xFF prefix for hex colors
                      //     Colors.yellowAccent,
                      //   ],
                      // ),
                      borderRadius: BorderRadius.circular(20)),

                  padding: const EdgeInsets.all(
                      8.0), // Add padding for better appearance
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${tx.sender.name} - \u{20B9}${tx.amount != null ? tx.amount!.toStringAsFixed(2) : tx.amount!.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(tx.date.toLocal())}',
                        style: TextStyle(
                            color: const Color.fromARGB(255, 32, 30, 30)),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        tx.description,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class ReportTab extends StatefulWidget {
  final CliqueProvider cliqueProvider;
  ReportsProvider reportsProvider;
  ReportTab(
      {Key? key, required this.cliqueProvider, required this.reportsProvider})
      : super(key: key);

  @override
  State<ReportTab> createState() => _ReportTabState(
      cliqueProvider: cliqueProvider, reportsProvider: reportsProvider);
}

class _ReportTabState extends State<ReportTab> {
  final CliqueProvider cliqueProvider;
  ReportsProvider reportsProvider;
  final ReportApi reportApi = ReportApi();
  bool isLoading = false; // Loading state for the overall report

  _ReportTabState({
    required this.cliqueProvider,
    required this.reportsProvider,
  });

  Future<void> getDetailsReport(
      String cliqueId, String memberId, ReportsProvider reportsProvider) async {
    await reportApi.getDetailsReport(cliqueId, memberId, reportsProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: ListView.builder(
          itemCount: reportsProvider
              .reportList[cliqueProvider.currentClique!.id]!.length,
          itemBuilder: (context, index) {
            AbstructReport report = reportsProvider
                .reportList[cliqueProvider.currentClique!.id]![index];
            Color tileColor = report.isDue
                ? const Color.fromARGB(255, 172, 72, 10)
                : const Color.fromARGB(255, 20, 135, 97);

            return Column(
              children: [
                ExpansionTile(
                  backgroundColor: tileColor,
                  title: Row(
                    children: [
                      Container(
                        width: 80,
                        child: Text(report.userName),
                      ),
                      const SizedBox(width: 80),
                      Container(
                        width: 50,
                        child: Text(
                          report.isDue ? "Due" : "Extra",
                          style: TextStyle(
                              color: report.isDue
                                  ? const Color.fromARGB(255, 199, 27, 47)
                                  : const Color.fromARGB(255, 35, 141, 105),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 50),
                      Text('${report.amount}'),
                    ],
                  ),
                  onExpansionChanged: (bool expanded) async {
                    if (expanded) {
                      report.detailsReport ??
                          await getDetailsReport(
                              cliqueProvider.currentClique!.id,
                              report.memberId,
                              reportsProvider);
                    }
                  },
                  children: report.detailsReport?.map((details) {
                        return ListTile(
                          title: Text(details.transactionId),
                          subtitle: Text(
                              '${DateFormat('yyyy-MM-dd HH:mm').format(details.date.toLocal())} - ${details.description}'),
                          trailing: Text(
                            'Sent: ${details.sendAmount ?? 0}, Received: ${details.receiveAmount ?? 0}',
                          ),
                        );
                      }).toList() ??
                      [],
                ),
              ],
            );
          },
        ));
  }
}
