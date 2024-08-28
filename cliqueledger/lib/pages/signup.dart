import 'package:cliqueledger/service/authservice.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
   

    return Material(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(1),
              child: Image.asset(
                "assets/images/register.png",
                height: 450,
                width: 450,
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Text(
              "New here?",
              style: TextStyle(
                fontFamily: GoogleFonts.dancingScript().fontFamily,
                fontSize: 40.0,
                color: theme.textTheme.displayLarge!.color, // Use displayLarge color from theme
              ),
            ),
            const SizedBox(
              height: 40.0,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary, // Use primary color from theme
              ),
              onPressed: () async {
                // Attempt to login/signup
                await Authservice.instance.login();
                if (!mounted) return;

                // Check if login/signup was successful
                if (Authservice.instance.loginInfo.isLoggedIn) {
                  // Navigate to the dashboard
                  // ignore: use_build_context_synchronously
                  context.push('/dashboard');
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login successful', style: TextStyle(color: theme.textTheme.bodyLarge!.color))),
                  );
                } else {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login failed', style: TextStyle(color: theme.textTheme.bodyLarge!.color))),
                  );
                }
              },
              child: Text(
                "Register | Login",
                style: TextStyle(color: theme.textTheme.bodyLarge!.color), // Use bodyLarge color from theme
              ),
            ),
          ],
        ),
      ),
    );
  }
}
