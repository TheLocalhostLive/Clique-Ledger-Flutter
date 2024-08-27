import 'dart:io';

import 'package:cliqueledger/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:cliqueledger/api_helpers/cliqueDelete.dart';
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
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  final CreateCliquePost createCliquePost = CreateCliquePost();
  late TransactionProvider transactionProvider;
  late CliqueListProvider cliqueListProvider;
  late TabController _tabController;

  final CliqueList cliqueList = CliqueList();

  bool isCliquesLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool withFunds = false;
        final TextEditingController amountController = TextEditingController();
        final TextEditingController cliqueNameController =
            TextEditingController();
        final GlobalKey<FormState> formKey = GlobalKey<FormState>();

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final ThemeData theme = Theme.of(context);
            final Color secondaryColor = theme.colorScheme.secondary;
            final Color surfaceColor = theme.colorScheme.surface;
            final Color onSurfaceColor = theme.colorScheme.onSurface;
            final Color tertiaryColor = theme.colorScheme.tertiary;

            return AlertDialog(
              title: Text('Create Clique',
                  style: TextStyle(color: secondaryColor)),
              backgroundColor: surfaceColor,
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      cursorColor: secondaryColor,
                      controller: cliqueNameController,
                      decoration: InputDecoration(
                        hintText: "Enter Clique Name",
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: onSurfaceColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: secondaryColor,
                          ),
                        ),
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
                          activeColor: tertiaryColor,
                          onChanged: (bool? value) {
                            setState(() {
                              withFunds = value ?? false;
                            });
                          },
                        ),
                        Text("With funds",
                            style: TextStyle(color: tertiaryColor)),
                      ],
                    ),
                    if (withFunds)
                      TextFormField(
                        cursorColor: secondaryColor,
                        controller: amountController,
                        decoration: InputDecoration(
                          hintText: "Enter Amount",
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: onSurfaceColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: secondaryColor,
                            ),
                          ),
                        ),
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
                  child:
                      Text('Cancel', style: TextStyle(color: secondaryColor)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Create', style: TextStyle(color: tertiaryColor)),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      String amount = amountController.text;
                      String cliqueName = cliqueNameController.text;
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

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final ThemeData theme = Theme.of(context);
        Color tertiaryColor = theme.colorScheme.tertiary;
        Color secondaryColor = theme.colorScheme.secondary;

        return AlertDialog(
          title: Text("Confirm Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              style: TextButton.styleFrom(
                foregroundColor: secondaryColor, // Color for the Cancel button
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Confirm"),
              style: TextButton.styleFrom(
                foregroundColor: tertiaryColor, // Color for the Confirm button
              ),
              onPressed: () async {
                await Authservice.instance.logout();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    var theme = themeProvider.themeData;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              onPressed: () {
                themeProvider.toggleMode();
              },
              icon: Icon(
                theme.brightness == Brightness.dark
                    ? Icons.wb_sunny
                    : Icons.nightlight_round,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            IconButton(
              onPressed: _confirmLogout,
              icon: Icon(IconData(0xe3b3, fontFamily: 'MaterialIcons')),
              color: theme.textTheme.bodyLarge?.color,
            )
          ],
          title: Text(
            "Clique Ledger",
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold,
            ),
          ),
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
                    child: Text(
                      "Active Clique",
                      style: TextStyle(color: theme.colorScheme.tertiary),
                    ),
                  ),
                  Tab(
                    child: Text("Finished Clique",
                        style: TextStyle(color: theme.colorScheme.tertiary)),
                  )
                ]),
            Expanded(
              child: TabBarView(
                controller: _tabController,
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
        floatingActionButton: IndexedStack(
          index: _tabController.index,
          children: [
            FloatingActionButton(
              onPressed: () => _createClique(context),
              tooltip: 'Create Clique',
              child: const Icon(Icons.add, color: Colors.white),
              backgroundColor: theme.colorScheme.secondary,
            ),
            Text("")
          ],
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
  Future<void> _showDeleteConfirmationDialog(Clique clique , CliqueListProvider cliqueListProvider) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Clique'),
        content: const Text('Are you sure you want to delete this Clique?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel',style: TextStyle(color: Color.fromARGB(255, 161, 2, 41),),),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Delete',style: TextStyle(color: Color(0xFFFFB200) ),),
            onPressed: ()  async{
              await CliqueDelete.deleteClique(clique,cliqueListProvider,context);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    CliqueProvider cliqueProvider = Provider.of<CliqueProvider>(context);
    var theme = Theme.of(context);
    CliqueListProvider cliqueListProvider=context.read<CliqueListProvider>();
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
                  shadowColor: Color.fromARGB(255, 158, 158, 158),
              child: InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onLongPress: () async {
                    await _showDeleteConfirmationDialog(clique,cliqueListProvider);
                  },
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
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(clique.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.tertiary,
                                    )),
                                Text(
                                   clique.latestTransaction != null
                                      ? '${clique.latestTransaction!.sender.name}-${clique.latestTransaction!.amount} \u{20B9} ${DateFormat('yyyy-MM-dd HH:mm').format(clique.latestTransaction!.date.toLocal())}'
                                      : 'No transactions yet',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: theme.colorScheme.tertiary,
                                    )),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios,
                              color: theme.colorScheme.secondary)
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
