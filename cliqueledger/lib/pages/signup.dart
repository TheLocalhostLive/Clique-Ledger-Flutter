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
  // Create ValueNotifiers to manage the button state
  final ValueNotifier<bool> isClicked = ValueNotifier<bool>(false);
  final ValueNotifier<bool> successLogin = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

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
                color: theme.textTheme.displayLarge!.color,
              ),
            ),
            const SizedBox(
              height: 40.0,
            ),
            Material(
              color: theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(50),
              child: InkWell(
                onTap: () async {
                  isClicked.value = true;
                  await Authservice.instance.login();
                  if (!mounted) return;

                  if (Authservice.instance.loginInfo.isLoggedIn) {
                    successLogin.value = true;
                    // ignore: use_build_context_synchronously
                    context.go('/dashboard');
                   
                  } else {
                    isClicked.value = false;
                    successLogin.value = false; // Revert success state on failure
                  }
                },
                child: ValueListenableBuilder<bool>(
                  valueListenable: isClicked,
                  builder: (context, isClickedValue, child) {
                    return ValueListenableBuilder<bool>(
                      valueListenable: successLogin,
                      builder: (context, successLoginValue, child) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: isClickedValue ? 50 : 150,
                          height: 50,
                          alignment: Alignment.center,
                          child: isClickedValue
                              ? (successLoginValue
                                  ? const Icon(
                                      Icons.done,
                                      color: Colors.white,
                                    )
                                  : const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ))
                              : Text(
                                  "Register | Login",
                                  style: textTheme.displayMedium?.copyWith(
                                    fontSize: 18,
                                    fontFamily:
                                        GoogleFonts.lato().fontFamily,
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
