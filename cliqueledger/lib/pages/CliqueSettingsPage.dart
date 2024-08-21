import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cliqueledger/api_helpers/fetchMemeber.dart';
import 'package:cliqueledger/models/member.dart';
import 'package:cliqueledger/providers/CliqueListProvider.dart';
import 'package:cliqueledger/providers/cliqueProvider.dart';
import 'package:cliqueledger/providers/userProvider.dart';
import 'package:cliqueledger/themes/appBarTheme.dart';
import 'package:cliqueledger/utility/routers_constant.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<Member> memberList = [];
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Consumer2<CliqueListProvider, CliqueProvider>(
      builder: (context, cliqueListProvider, cliqueProvider, child) {
        TextEditingController _nameController =
            TextEditingController(text: cliqueProvider.currentClique!.name);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: GradientAppBar(title: "Clique Ledger"),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color:Colors.white,width: 3.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            60), // Half of the container's size
                        child: Image.asset(
                          "assets/images/cliqueDefault.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                                color: Colors.black, width: 1.5),
                            color: Colors.white,
                          ),
                          child: isEditing
                              ? TextField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  style: TextStyle(fontSize: 20.0),
                                )
                              : Text(
                                  _nameController.text,
                                  style: TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Color(0xFFFFB200)),
                        onPressed: () {
                          setState(() {
                            isEditing = true;
                          });
                        },
                      ),
                    ],
                  ),
                  if (isEditing)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isEditing = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFB200),
                          ),
                          child: Text(
                            "Save",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        "Participants",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          context.push(RoutersConstants.ADD_MEMBER_ROUTE);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFB200),
                        ),
                        child: Text(
                          "Add Member",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: cliqueListProvider.activeCliqueList[cliqueProvider.currentClique!.id]!.members.length,
                    itemBuilder: (context, index) {
                      final member =
                          cliqueListProvider.activeCliqueList[cliqueProvider.currentClique!.id]!.members[index];
                      return Card(
                        color: Color.fromARGB(255, 254, 246, 235),
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(
                            member.name,
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.black,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete,
                                color: const Color.fromARGB(255, 146, 12, 2)),
                            onPressed: () {
                              // Implement delete functionality
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
