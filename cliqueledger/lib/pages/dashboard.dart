import 'dart:io';

import 'package:cliqueledger/api_helpers/createCliquePost.dart';
import 'package:cliqueledger/api_helpers/fetchCliqeue.dart';
import 'package:cliqueledger/models/cliqeue.dart';
import 'package:cliqueledger/models/cliquePostSchema.dart';
import 'package:cliqueledger/models/transaction.dart';
import 'package:cliqueledger/providers/CliqueListProvider.dart';
import 'package:cliqueledger/providers/TransactionProvider.dart';
import 'package:cliqueledger/providers/cliqueProvider.dart';
import 'package:cliqueledger/service/socket_service.dart';
import 'package:cliqueledger/themes/appBarTheme.dart';
import 'package:cliqueledger/utility/routers_constant.dart';
import 'package:flutter/material.dart';
import 'package:cliqueledger/service/authservice.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  final CreateCliquePost createCliquePost = CreateCliquePost();
  late TransactionProvider transactionProvider;
  late CliqueListProvider cliqueListProvider;

  final CliqueList cliqueList = CliqueList();


  bool isCliquesLoading = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize transactionProvider here
    transactionProvider = Provider.of<TransactionProvider>(context);
    cliqueListProvider = Provider.of<CliqueListProvider>(context);
    
  }

  void _initSocket() {
    
    SocketService.instance.connectAndListen();
    SocketService.transactionProvider = transactionProvider;
    SocketService.cliquesProvider = cliqueListProvider;
    List<String> rooms = cliqueListProvider.activeCliqueList.keys.toList();

    SocketService.instance.joinRooms(rooms);
    SocketService.instance.setupListeners();
  }

  @override
  void initState() {
    super.initState();
     WidgetsBinding.instance.addPostFrameCallback((_)async {
      await fetchCliques();
      _initSocket();
    });
  }

  Future<void> fetchCliques() async {
    await cliqueList.fetchData(cliqueListProvider);
    setState(() {
      isCliquesLoading = false;
    });
  }

  void _createClique(BuildContext context) {
    // Navigate to create page or show a dialog
    // For demonstration, we'll show a simple dialog

    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool withFunds = false;
        final TextEditingController amountController = TextEditingController();
        final TextEditingController cliqueNameController =
            TextEditingController();
        final TextEditingController MembersController = TextEditingController();
        final GlobalKey<FormState> formKey = GlobalKey<FormState>();

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Create Clique'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      controller: cliqueNameController,
                      decoration: const InputDecoration(
                        hintText: "Enter Clique Name",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Clique Name cannot be empty";
                        }
                        return null;
                      },
                    ),
                    Row(
                      children: <Widget>[
                        Checkbox(
                          value: withFunds,
                          onChanged: (bool? value) {
                            setState(() {
                              withFunds = value ?? false;
                            });
                          },
                        ),
                        const Text("With funds"),
                      ],
                    ),
                    if (withFunds)
                      TextFormField(
                        controller: amountController,
                        decoration:
                            const InputDecoration(hintText: "Enter Amount"),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Amount cannot be empty";
                          }
                          return null;
                        },
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Create'),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      // Handle the create action
                      String amount = amountController.text;
                      String cliqueName = cliqueNameController.text;
                      // String members = MembersController.text;
                      bool isActive = true;
                      //List<String> membersList = members.split(',');
                      CliquePostSchema cls = amount.isEmpty
                          ? CliquePostSchema(name: cliqueName, fund: "0")
                          : CliquePostSchema(name: cliqueName, fund: amount);
                      await createCliquePost.postData(cls, cliqueListProvider);
                      Navigator.of(context).pop();
                    }
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              onPressed: () async {
                await Authservice.instance.logout();
              },
              icon: Icon(IconData(0xe3b3, fontFamily: 'MaterialIcons')),
              color: Colors.white,
            )
          ],
          title: Text(
            "Clique Ledger",
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(
                      0xFF10439F), // Note the use of 0xFF prefix for hex colors
                  Color(0xFF874CCC),
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
              Tab(
                child: Text(
                  "Active Ledger",
                  style: TextStyle(color: Color.fromARGB(255, 14, 97, 130)),
                ),
              ),
              Tab(
                child: Text("Finished Ledger",
                    style: TextStyle(color: Color.fromARGB(255, 14, 97, 130))),
              )
            ]),
            Expanded(
              child: TabBarView(
                children: [
                  isCliquesLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : cliqueListProvider.activeCliqueList.isEmpty
                          ? const Center(
                              child: Text("No Ledgers to show"),
                            )
                          : LedgerTab(
                              cliqueList: cliqueListProvider.activeCliqueList),
                  cliqueListProvider.finishedCliqueList.isEmpty
                      ? const Center(
                          child: Text("No Ledgers to Show"),
                        )
                      : LedgerTab(
                          cliqueList: cliqueListProvider.finishedCliqueList)
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _createClique(context),
          tooltip: 'Create Clique',
          child: const Icon(Icons.add),
          backgroundColor: Color.fromARGB(255, 165, 229, 244),
        ),
      ),
    );
  }
}

class LedgerTab extends StatefulWidget {
  final Map<String, Clique> cliqueList;
  const LedgerTab({required this.cliqueList});

  @override
  State<LedgerTab> createState() => _LedgerTabState();
}

class _LedgerTabState extends State<LedgerTab> {
  @override
  Widget build(BuildContext context) {
    CliqueProvider cliqueProvider = Provider.of<CliqueProvider>(context);
    return ListView(
      children: widget.cliqueList.values.map((clique) {
        return Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            height: 100,
            child: Card(
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              child: InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onTap: () {
                    cliqueProvider.setClique(clique);
                    context.push(RoutersConstants.CLIQUE_ROUTE);
                    setState(() {
                      widget.cliqueList[cliqueProvider.currentClique!.id] =
                          widget.cliqueList[cliqueProvider.currentClique!.id]!
                              .copyWith(
                        latestTransaction:
                            cliqueProvider.currentClique!.latestTransaction,
                      );
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 143, 177, 240),
                          Color.fromARGB(255, 222, 155, 228)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 5, 5, 5),
                      child: Row(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: Image.asset(
                                "assets/images/groupSelfie.png",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10), // Space between photo and text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  clique.name,
                                  style: TextStyle(
                                    fontSize: 26.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w200,
                                  ),
                                ),
                                Text(
                                  clique.latestTransaction != null
                                      ? '${clique.latestTransaction!.sender.name}-${clique.latestTransaction!.amount != null ? clique.latestTransaction!.amount : clique.latestTransaction!.amount} \u{20B9}'
                                      : 'No transactions yet',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 54, 24, 56),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w100,
                                  ),
                                ),
                                Text(
                                  clique.latestTransaction != null
                                      ? '${clique.latestTransaction!.date}'
                                      : '',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 51, 22, 54),
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text("Logout"),
      onPressed: () async {
        Authservice.instance.logout();
      },
    );
  }
}
