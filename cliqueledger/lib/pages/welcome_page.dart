import 'package:cliqueledger/service/authservice.dart';
import 'package:cliqueledger/utility/routers_constant.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePage extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
        child: Column(

      children: [
        const SizedBox(height: 30,),
        Padding(padding: EdgeInsets.all(20),
          child: Image.asset("assets/images/take_love_red.png",
          height: 400,
          width: 400,
          ),
        ),
        const SizedBox(height: 30,),
        Text(
          "Welcome to Cliqeue Ledger",
          
          style: TextStyle(fontSize: 55.0,
          fontFamily: GoogleFonts.qwitcherGrypen().fontFamily,
          ),
        ),
        const SizedBox(height: 30,),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFFB200)
          ),
          child: const Text("Get Started",style: TextStyle(color: Colors.white,),),
          onPressed: () {
            context.push(RoutersConstants.SIGNUP_PAGE_ROUTE);
          },
        )
      ],
    ));
  }
}
