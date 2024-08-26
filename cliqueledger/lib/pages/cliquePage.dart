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
            final theme = Theme.of(context); // Get current theme

            // Calculate available height by considering the keyboard height
            double availableHeight = MediaQuery.of(context).size.height -
                MediaQuery.of(context).viewInsets.bottom -
                100;

            return AlertDialog(
              backgroundColor: theme.colorScheme.surface,
              title: Text(
                'Create Transaction',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: theme.textTheme.titleSmall?.color,
                ),
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
                        cursorColor: theme.colorScheme.tertiary,
                        decoration: InputDecoration(
                          floatingLabelStyle:
                              TextStyle(color: theme.colorScheme.tertiary),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
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
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: theme.textTheme.bodySmall?.color),
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
                        cursorColor: theme.colorScheme.tertiary,
                        decoration: InputDecoration(
                          floatingLabelStyle:
                              TextStyle(color: theme.colorScheme.tertiary),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                          labelText: 'Description',
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: theme.colorScheme.tertiary)),
                          errorText: descriptionError,
                          prefixIcon: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              '>',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: theme.textTheme.bodySmall?.color),
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
                            child: Text(value,
                                style: TextStyle(
                                    color: theme.textTheme.bodySmall?.color)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            transactionType = newValue!;
                            transactionTypeError = null; // Clear error if valid
                          });
                        },
                        isExpanded: true,
                        dropdownColor: theme.dialogBackgroundColor,
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
                                activeColor: theme.colorScheme.tertiary,
                                title: Text(member.name,
                                    style: TextStyle(
                                        color:
                                            theme.textTheme.titleSmall?.color)),
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
                                controlAffinity:
                                    ListTileControlAffinity.trailing,
                              );
                            } else {
                              return CheckboxListTile(
                                activeColor: theme.colorScheme.tertiary,
                                title: Text(member.name,
                                    style: TextStyle(
                                        color:
                                            theme.textTheme.titleSmall?.color)),
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
                    backgroundColor: theme.colorScheme.tertiary,
                  ),
                  child: Text(
                    'Create Transaction',
                    style: TextStyle(color: theme.colorScheme.onPrimary),
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
    ThemeData theme = Theme.of(context);

    return Consumer3<CliqueListProvider, CliqueProvider, TransactionProvider>(
      builder: (context, cliqueListProvider, cliqueProvider,
          transactionProvider, child) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                "Clique Ledger",
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: <Widget>[
                IconButton(
                  onPressed: () {
                    context.push(RoutersConstants.CLIQUE_SETTINGS_ROUTE);
                  },
                  icon: Icon(
                    Icons.settings,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                )
              ],
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
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
                  indicatorColor: theme.colorScheme.secondary,
                  controller: _tabController,
                  tabs: [
                    Tab(
                      child: Text("Transaction",
                          style: TextStyle(color: theme.colorScheme.tertiary)),
                    ),
                    Tab(
                      child: Text("Media",
                          style: TextStyle(color: theme.colorScheme.tertiary)),
                    ),
                    Tab(
                      child: Text("Report",
                          style: TextStyle(color: theme.colorScheme.tertiary)),
                    ),
                  ],
                ),
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
                  backgroundColor: theme.colorScheme.secondary,
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
                FloatingActionButton(
                  heroTag: 'btn2',
                  onPressed: () {
                    // Handle action for the "Media" tab
                    pickImage.showImagePickerOption(context);
                  },
                  tooltip: 'Add Media',
                  backgroundColor: theme.colorScheme.secondary,
                  child: const Icon(
                    Icons.photo,
                    color: Colors.white,
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
                  backgroundColor: theme.colorScheme.secondary,
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
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(
                'Transaction Details',
                style: theme.textTheme.titleLarge?.copyWith(
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
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${t.sender.name} : \u{20B9}${t.amount.toStringAsFixed(2) ?? 'N/A'} paid to ${t.participants[0].name}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ] else ...[
                      Text(
                        "Spend Transaction",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w200,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${t.sender.name} Paid Total: \u{20B9}${t.amount?.toStringAsFixed(2) ?? 'N/A'} To -',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...t.participants
                          .map(
                            (p) => Text(
                              '${p.name} - \u{20B9}${p.partAmount}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          )
                          .toList(),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      'Description:',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${t.description}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 30),
                    // ElevatedButton(
                    //   onPressed: () => {},
                    //   child: const Text(
                    //     "Verify",
                    //     style: TextStyle(
                    //       color: Colors.white,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: const Color.fromARGB(255, 150, 4, 41),
                    //     minimumSize:
                    //         Size(double.infinity, 36), // Full-width button
                    //     padding: const EdgeInsets.symmetric(
                    //         vertical: 12), // Add vertical padding
                    //   ),
                    // ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Close',
                    style: TextStyle(color: theme.colorScheme.secondary),
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
    final theme = Theme.of(context);

    return ListView(
      children: transactions.map((tx) {
        return Center(
          child: Container(
            margin: const EdgeInsets.fromLTRB(60, 10, 5, 10),
            width: MediaQuery.of(context).size.width * 0.7,
            height: 100,
            child: Card(
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: InkWell(
                borderRadius: BorderRadius.circular(20.0),
                focusColor: theme.colorScheme.secondary,
                onTap: () => _checkTransaction(context, tx),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${tx.sender.name} - \u{20B9}${tx.amount != null ? tx.amount!.toStringAsFixed(2) : tx.amount!.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(tx.date.toLocal())}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        tx.description,
                        style: theme.textTheme.bodySmall,
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
  final ReportsProvider reportsProvider;

  ReportTab(
      {Key? key, required this.cliqueProvider, required this.reportsProvider})
      : super(key: key);

  @override
  State<ReportTab> createState() => _ReportTabState(
      cliqueProvider: cliqueProvider, reportsProvider: reportsProvider);
}

class _ReportTabState extends State<ReportTab> {
  final CliqueProvider cliqueProvider;
  final ReportsProvider reportsProvider;
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
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    return Scaffold(
      body: ListView.builder(
        itemCount: reportsProvider
            .reportList[cliqueProvider.currentClique!.id]!.length,
        itemBuilder: (context, index) {
          AbstructReport report = reportsProvider
              .reportList[cliqueProvider.currentClique!.id]![index];
          return Column(
            children: [
              ExpansionTile(
                title: Row(
                  children: [
                    Container(
                      width: 80,
                      child: Text(
                        report.userName,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: 80),
                    Container(
                      width: 50,
                      child: Text(
                        report.isDue ? "Due" : "Extra",
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: report.isDue
                              ? Color.fromRGBO(222, 75, 95, 1)
                              : Color.fromRGBO(99, 220, 190, 1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 50),
                    Text(
                      '${report.amount}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                onExpansionChanged: (bool expanded) async {
                  if (expanded) {
                    report.detailsReport ??
                        await getDetailsReport(cliqueProvider.currentClique!.id,
                            report.memberId, reportsProvider);
                  }
                },
                children: report.detailsReport?.map((details) {
                      // Determine the color based on sendAmount for each detail
                      Color detailTileColor = details.sendAmount == null
                          ? Color.fromRGBO(222, 75, 95, 0.2)
                          : Color.fromRGBO(99, 220, 190, 0.2);

                      return ListTile(
                        tileColor:
                            detailTileColor, // Set tile color here for each ListTile
                        title: Text(
                          details.transactionId,
                          style: theme.textTheme.bodyMedium,
                        ),
                        subtitle: Text(
                          '${DateFormat('yyyy-MM-dd HH:mm').format(details.date.toLocal())} - ${details.description}',
                          style: theme.textTheme.bodySmall,
                        ),
                        trailing: Text(
                          'Sent: ${details.sendAmount ?? 0}, Received: ${details.receiveAmount ?? 0}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      );
                    }).toList() ??
                    [],
              ),
            ],
          );
        },
      ),
    );
  }
}
