import 'package:cliqueledger/api_helpers/createCliquePost.dart';
import 'package:cliqueledger/api_helpers/fetchCliqeue.dart';
import 'package:cliqueledger/models/cliqeue.dart';
import 'package:cliqueledger/models/cliquePostSchema.dart';
import 'package:cliqueledger/models/transaction.dart';
import 'package:cliqueledger/providers/CliqueListProvider.dart';
import 'package:cliqueledger/providers/TransactionProvider.dart';
import 'package:cliqueledger/providers/cliqueProvider.dart';
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
  //final WebSocketChannel channel = IOWebSocketChannel.connect('wss://echo.wesocket.org');
  final CreateCliquePost createCliquePost = CreateCliquePost();
  late TransactionProvider transactionProvider;
  late CliqueListProvider cliqueListProvider;

  final CliqueList cliqueList = CliqueList();

  // _DashboardState(){
  //   channel.stream.listen((data){
  //       Transaction t=data;
  //       if(transactionProvider.transactionMap.containsKey(t.cliqueId)){
  //         transactionProvider.addSingleEntry(t.cliqueId,t);
  //       }else{
  //         if(cliqueList.activeCliqueList.containsKey(t.cliqueId)){
  //             cliqueList.activeCliqueList[t.cliqueId]!.latestTransaction=t;
  //             setState(() {});
  //         }
  //       }
  //   });
  // }
  bool isCliquesLoading = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize transactionProvider here
    transactionProvider = Provider.of<TransactionProvider>(context);
    cliqueListProvider = Provider.of<CliqueListProvider>(context);
  }

  @override
  void initState() {
    super.initState();
     WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchCliques();
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
                      await createCliquePost.postData(cls,cliqueListProvider);
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
                          : LedgerTab(cliqueList: cliqueListProvider.activeCliqueList),
                        cliqueListProvider.finishedCliqueList.isEmpty
                      ? const Center(
                          child: Text("No Ledgers to Show"),
                        )
                      : LedgerTab(cliqueList: cliqueListProvider.finishedCliqueList)
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
            //margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
            width: MediaQuery.of(context).size.width * 0.95,
            height: 90,
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

                    //
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 213, 225, 236),
                        borderRadius: BorderRadius.circular(5)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 5, 5, 5),
                      child: Container(
                        child: Column(
                          children: [
                            Text(
                              '${clique.name}',
                              style: TextStyle(
                                fontSize: 22.0,
                              ),
                            ),
                            Text(
                              clique.latestTransaction != null
                                  ? '${clique.latestTransaction!.sender.name}-${clique.latestTransaction!.amount!= null ? clique.latestTransaction!.amount : clique.latestTransaction!.amount} \u{20B9}'
                                  : 'No transactions yet',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            Text(
                              clique.latestTransaction != null
                                  ? '${clique.latestTransaction!.date}'
                                  : '',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 10),
                            )
                          ],
                        ),
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
