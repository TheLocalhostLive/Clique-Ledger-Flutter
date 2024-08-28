
import 'package:cliqueledger/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:cliqueledger/api_helpers/clique_delete.dart';
import 'package:cliqueledger/api_helpers/create_cliique_post.dart';
import 'package:cliqueledger/api_helpers/fetch_cliqeue.dart';
import 'package:cliqueledger/models/cliqeue.dart';
import 'package:cliqueledger/models/clique_post_schema.dart';
import 'package:cliqueledger/providers/Clique_list_provider.dart';
import 'package:cliqueledger/providers/transaction_provider.dart';
import 'package:cliqueledger/providers/clique_provider.dart';
import 'package:cliqueledger/providers/clique_media_provider.dart';
import 'package:cliqueledger/service/socket_service.dart';

import 'package:cliqueledger/utility/routers_constant.dart';

import 'package:cliqueledger/service/authservice.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


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
  late CliqueMediaProvider cliqueMediaProvider;
  late CliqueProvider  cliqueProvider;
  final CliqueList cliqueList = CliqueList();

  bool isCliquesLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    transactionProvider = Provider.of<TransactionProvider>(context);
    cliqueListProvider = Provider.of<CliqueListProvider>(context);
    cliqueMediaProvider = Provider.of<CliqueMediaProvider>(context);
    cliqueProvider = Provider.of<CliqueProvider>(context);
  }

  void _initSocket() {
    SocketService.instance.connectAndListen();
    SocketService.transactionProvider = transactionProvider;
    SocketService.cliqueListProvider = cliqueListProvider;
    SocketService.cliqueProvider = cliqueProvider;
    SocketService.cliqueMediaProvider = cliqueMediaProvider;
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
                      await createCliquePost.postData(cls, cliqueListProvider,context);
                      // ignore: use_build_context_synchronously
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
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: secondaryColor, // Color for the Cancel button
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: tertiaryColor, // Color for the Confirm button
              ),
              onPressed: () async {
                await Authservice.instance.logout();
                // ignore: use_build_context_synchronously
                context.go(RoutersConstants.SIGNUP_PAGE_ROUTE);
              },
              child: const Text("Confirm"),
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
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              onPressed: () async {
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
              icon: const Icon(IconData(0xe3b3, fontFamily: 'MaterialIcons')),
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
            Expanded(
              child:  isCliquesLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : cliqueListProvider.activeCliqueList.isEmpty
                          ? const Center(
                              child: Text("No Ledgers to show"),
                            )
                          : LedgerTab(
                              cliqueList: cliqueListProvider.activeCliqueList),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
              onPressed: () => _createClique(context),
              tooltip: 'Create Clique',
              backgroundColor: theme.colorScheme.secondary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
        );
  }
}

class LedgerTab extends StatefulWidget {
  final Map<String, Clique> cliqueList;

  const LedgerTab({super.key, required this.cliqueList});
  

  @override
  State<LedgerTab> createState() => _LedgerTabState();
}

class _LedgerTabState extends State<LedgerTab> {
  Future<void> _showDeleteConfirmationDialog(Clique clique , CliqueListProvider cliqueListProvider) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
       final ThemeData theme = Theme.of(context);
       final Color secondaryColor = theme.colorScheme.secondary;
       final Color tertiaryColor = theme.colorScheme.tertiary;

      return AlertDialog(
        title: const Text('Delete Clique'),
        content: const Text('Are you sure you want to delete this Clique?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel',style: TextStyle(color: secondaryColor,),),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Delete',style: TextStyle(color: tertiaryColor ),),
            onPressed: ()  async{
              await CliqueDelete.deleteClique(clique,cliqueListProvider,context);
              // ignore: use_build_context_synchronously
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
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.95,
            height: 100,
            child: Card(
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
                  shadowColor: const Color.fromARGB(255, 158, 158, 158),
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
