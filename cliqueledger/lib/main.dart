import 'package:cliqueledger/pages/addMember.dart';
import 'package:cliqueledger/pages/cliquePage.dart';
import 'package:cliqueledger/pages/dashboard.dart';
import 'package:cliqueledger/pages/CliqueSettingsPage.dart';
import 'package:cliqueledger/pages/repor.page.dart';
import 'package:cliqueledger/providers/CliqueListProvider.dart';
import 'package:cliqueledger/providers/TransactionProvider.dart';
import 'package:cliqueledger/providers/cliqueProvider.dart';
import 'package:cliqueledger/providers/reportsProvider.dart';
import 'package:cliqueledger/providers/clique_media_provider.dart';
import 'package:cliqueledger/providers/userProvider.dart';
import 'package:cliqueledger/service/authservice.dart';
import 'package:cliqueledger/utility/routers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter bindings are initialized
  
  try {
    bool isInitialized = await Authservice.instance.init(); // Await Authservice initialization
    if (!isInitialized) {
      // Handle the case where initialization fails (optional)
      print("No refresh token");
    }
  } catch (e) {
    // Handle any exceptions thrown during initialization
    print("Error during initialization: $e");
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CliqueProvider()),
        ChangeNotifierProvider(create: (_)=>UserProvider()),
         ChangeNotifierProvider(create: (_) => TransactionProvider()),
         ChangeNotifierProvider(create: (_) => CliqueListProvider()),
         ChangeNotifierProvider(create: (_) => ReportsProvider()),
         ChangeNotifierProvider(create: (_) => CliqueMediaProvider()),
        // You can add other providers here as needed
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
       routerConfig: Routers.routers(true),
    );
    // return MaterialApp(
    //   home: ReportListPage(),
    // );
   
  }
}
