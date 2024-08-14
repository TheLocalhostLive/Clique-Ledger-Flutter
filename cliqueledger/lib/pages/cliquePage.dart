import 'package:cliqueledger/api_helpers/fetchTransactions.dart';
import 'package:cliqueledger/api_helpers/transactionPost.dart';
import 'package:cliqueledger/models/ParticipantsPost.dart';
import 'package:cliqueledger/models/TransactionPostSchema.dart';
import 'package:cliqueledger/models/cliqeue.dart';
import 'package:cliqueledger/models/member.dart';
import 'package:cliqueledger/models/participants.dart';
import 'package:cliqueledger/pages/spendTransactionSliderPage.dart';
import 'package:cliqueledger/providers/TransactionProvider.dart';
import 'package:cliqueledger/providers/cliqueProvider.dart';
import 'package:cliqueledger/themes/appBarTheme.dart';
import 'package:cliqueledger/utility/routers_constant.dart';
import 'package:flutter/material.dart';
import 'package:cliqueledger/models/transaction.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Cliquepage extends StatefulWidget {
  const Cliquepage({super.key});

  @override
  State<Cliquepage> createState() => _CliquepageState();
}

class _CliquepageState extends State<Cliquepage> {
  final TransactionList transactionList = TransactionList();
  late TransactionProvider transactionProvider;
  late CliqueProvider cliqueProvider;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cliqueProvider = context.read<CliqueProvider>();
      final transactionProvider = context.read<TransactionProvider>();
      fetchTransactions(cliqueProvider, transactionProvider);
    });
  }

  Future<void> fetchTransactions(CliqueProvider cliqueProvider,
      TransactionProvider transactionProvider) async {
    if (cliqueProvider.currentClique != null) {
      final cliqueId = cliqueProvider.currentClique!.id;
      if (!transactionProvider.transactionMap.containsKey(cliqueId)) {
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

  void _createTransaction(BuildContext context, CliqueProvider cliqueProvider,
      TransactionProvider transactionProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Define state variables
        String transactionType = 'spend';
        num amount = 0.0;
        List<Map<String, String>> selectedMembers = [];
        String? amountError;
        String? transactionTypeError;
        String description="Description is not Present";
        String? descriptionError;
        

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // Calculate available height by considering the keyboard height
            double availableHeight = MediaQuery.of(context).size.height -
                MediaQuery.of(context).viewInsets.bottom -
                100;

            return AlertDialog(
              title: Text('Create Transaction'),
              content: SingleChildScrollView(
                child: Container(
                  width: double.maxFinite,
                  constraints: BoxConstraints(maxHeight: availableHeight),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Amount Field
                      TextFormField(
                        decoration: InputDecoration(
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
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
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
                          children: cliqueProvider.currentClique!.members.map((member) {
                            return CheckboxListTile(
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
                                        element['memberId'] == member.memberId);
                                  }
                                });
                              },
                            );
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
                        TransactionPostschema tSchema =
                             TransactionPostschema(
                                cliqueId: cliqueId,
                                type: type,
                                participants: participants,
                                amount: amount,
                                description: description);
                        print('description : $description');
                        print('cliqueId : $cliqueId');
                        print('amount: $amount');
                        await TransactionPost.postData(tSchema,transactionProvider);
                      } else {
                        context.go(
                          RoutersConstants.SPEND_TRANSACTION_SLIDER_PAGE,
                          extra: {
                            'selectedMembers': selectedMembers,
                            'amount': amount,
                            'description':description
                          },
                        );
                      }
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Create Transaction'),
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
    return Consumer2<CliqueProvider, TransactionProvider>(
      builder: (context, cliqueProvider, transactionProvider, child) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
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
                    // Your navigation logic here
                  },
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.white,
                  ),
                )
              ],
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(
                          0xFF5588A3), // Note the use of 0xFF prefix for hex colors
                      Color(0xFF145374),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            body: Column(
              children: [
                const TabBar(tabs: [
                  Tab(text: "Transaction"),
                  Tab(text: "Media"),
                  Tab(text: "Report"),
                ]),
                Expanded(
                  child: TabBarView(
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
                      const Center(child: Text('Media')),
                      const Center(child: Text('Report')),
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _createTransaction(
                  context, cliqueProvider, transactionProvider),
              tooltip: 'Create Transaction',
              backgroundColor: const Color.fromARGB(255, 27, 62, 75),
              child: const Icon(
                Icons.add,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
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
                        '${t.sender.name} : \u{20B9}${t.amount.toStringAsFixed(2) ?? 'N/A'} paid to ${t.participants[0].name}',
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ] else ...[
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
                        backgroundColor: const Color(0xFF00334E),
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
                    style: TextStyle(color: Color.fromARGB(255, 1, 47, 63)),
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
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 235, 165,
                              43), // Note the use of 0xFF prefix for hex colors
                          Color.fromARGB(255, 241, 205, 58),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20)),

                  padding: const EdgeInsets.all(
                      8.0), // Add padding for better appearance
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${tx.sender} - \u{20B9}${tx.amount != null ? tx.amount!.toStringAsFixed(2) : tx.amount!.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Date: ${tx.date.toLocal()}',
                        style: TextStyle(color: Colors.grey),
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
