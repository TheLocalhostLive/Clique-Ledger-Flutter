import 'package:cliqueledger/utility/routers_constant.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate font size based on screen width
    final double fontSize = screenWidth * 0.1; // Adjust the multiplier as needed

    return Material(
      child: Column(
        children: [
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Image.asset(
              "assets/images/get_started.png",
              height: 400,
              width: 400,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            "Welcome to",
            style: textTheme.displayMedium?.copyWith(
              fontSize: fontSize, // Adjusting for the first line
              fontFamily: GoogleFonts.dancingScript().fontFamily,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          Text(
            "Clique Ledger",
            style: textTheme.displayMedium?.copyWith(
              fontSize: fontSize * 1.7, // Full size for the second line
              fontFamily: GoogleFonts.dancingScript().fontFamily,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.textTheme.titleSmall?.color,
            ),
            child: const Text("Get Started"),
            onPressed: () {
              context.push(RoutersConstants.SIGNUP_PAGE_ROUTE);
            },
          )
        ],
      ),
    );
  }
}