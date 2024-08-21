import 'package:cliqueledger/service/authservice.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  @override
  Widget build(BuildContext context) {
    ValueNotifier<bool> changedButton = ValueNotifier(false);

    return Material(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: [
            
            Padding(
              padding: EdgeInsets.all(1),
              child: Image.asset(
                "assets/images/hey_red.png",
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
                fontSize: 30.0,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            const SizedBox(
              height: 40.0,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB200),
              ),
              onPressed: () async {
                // Attempt to login/signup
                await Authservice.instance.login();
                if (!mounted) return;

                // Check if login/signup was successful
                if (Authservice.instance.loginInfo.isLoggedIn) {
                  // Navigate to the dashboard
                  context.push('/dashboard');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login successful')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Login failed')),
                  );
                }
              },
              child: const Text("Register | Login",style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}
