
import 'package:cliqueledger/pages/CliqueSettingsPage.dart';
import 'package:cliqueledger/pages/addMember.dart';
import 'package:cliqueledger/pages/dashboard.dart';
import 'package:cliqueledger/pages/cliquePage.dart';
import 'package:cliqueledger/pages/login.dart';
import 'package:cliqueledger/pages/signup.dart';
import 'package:cliqueledger/pages/spendTransactionSliderPage.dart';
import 'package:cliqueledger/pages/welcome_page.dart';
import 'package:cliqueledger/service/authservice.dart';
import 'package:cliqueledger/utility/routers_constant.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';



class Routers {
  static GoRouter routers(bool isAuth) {
    final GoRouter router = GoRouter(
      redirect: (context, state) {
        final loggedIn = Authservice.instance.loginInfo.isLoggedIn;
        final isLogging = state.uri.toString() == '/signup';
        final isOnWelcome = state.uri.toString() == '/';

        if (!loggedIn && !isLogging && !isOnWelcome) return '/signup';
        if (loggedIn && isLogging) return '/dashboard';
        return null;
      },
      refreshListenable: Authservice.instance.loginInfo,
      debugLogDiagnostics: true, // Enable diagnostics for debugging
      initialLocation: Authservice.instance.loginInfo.isLoggedIn ? '/dashboard' : '/',
      routes: <GoRoute>[
        GoRoute(
          path: RoutersConstants.WELCOME_ROUTE,
          name: 'Welcome',
          builder: (context, state) => WelcomePage(),
        ),
        GoRoute(
          path: RoutersConstants.SIGNUP_PAGE_ROUTE,
          name: 'Signup',
          builder: (context, state) => Signup(),
        ),
        GoRoute(
          path: RoutersConstants.LOGIN_ROUTE,
          name: 'Login',
          builder: (context, state) => LoginPage(),
        ),
        GoRoute(
          path: RoutersConstants.DASHBOARD,
          name: 'Dashboard',
          builder: (context, state) => Dashboard(),
        ),
        GoRoute(
          path: RoutersConstants.CLIQUE_ROUTE,
          name: 'Clique',
          builder: (context, state) => Cliquepage()
        ),
        GoRoute(
          path: RoutersConstants.CLIQUE_SETTINGS_ROUTE,
          name: 'CliqueSettings',
          builder: (context, state) => SettingsPage(),
        ),
        GoRoute(
          path: RoutersConstants.ADD_MEMBER_ROUTE,
          name: 'AddMember',
          builder: (context, state) => AddMember(),
        ),
        GoRoute(
          path: RoutersConstants.SPEND_TRANSACTION_SLIDER_PAGE,
          name: 'SliderPage',
          builder: (context, state) {
            final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
            final List<Map<String, String>> selectedMembers = extra['selectedMembers'];
            final num amount = extra['amount'];
            final String description = extra['description'];

            return SpendTransactionSliderPage(
              selectedMembers: selectedMembers,
              amount: amount,
              description: description,
            );
          },
        ),
        // Fallback route for unmatched paths
        GoRoute(
          path: '/:path',
          name: 'Fallback',
          builder: (context, state) => Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        ),
      ],
    );
    return router;
  }
}

