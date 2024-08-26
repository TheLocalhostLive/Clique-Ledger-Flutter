import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:cliqueledger/themes/theme.dart';
import 'package:cliqueledger/api_helpers/MemberApi.dart';
import 'package:cliqueledger/models/member.dart';
import 'package:cliqueledger/models/user.dart';
import 'package:cliqueledger/providers/CliqueListProvider.dart';
import 'package:cliqueledger/providers/cliqueProvider.dart';
import 'package:cliqueledger/themes/appBarTheme.dart';
import 'package:cliqueledger/utility/routers.dart';

class AddMember extends StatefulWidget {
  const AddMember({super.key});

  @override
  State<AddMember> createState() => _AddMemberState();
}

class _AddMemberState extends State<AddMember> {
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = false;
  List<User> users = [];
  List<String> selectedUsers = [];

  Future<void> _searchMember(String email) async {
    setState(() {
      isLoading = true;
      users.clear(); // Clear previous search results
    });

    User? user = await MemberApi.searchUser(email);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nothing Found")),
      );
    } else {
      setState(() {
        users.add(user);
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _addMember(CliqueListProvider cl, CliqueProvider c) async {
    await MemberApi.addUserPost(selectedUsers, cl, c);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Member added successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get current theme

    return Consumer2<CliqueProvider, CliqueListProvider>(
      builder: (context, cliqueProvider, cliqueListProvider, child) {
        var buttonCol = theme.colorScheme.primary;
        var textCol1 = theme.colorScheme.tertiary;
        var textCol2 = theme.colorScheme.secondary;
        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: const GradientAppBar(title: "Clique Ledger"),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Search Member",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textCol1,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  cursorColor: theme.colorScheme.secondary, // Set cursor color based on theme
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: theme.colorScheme.primary,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    hintText: "eg: ant@example.com",
                    prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _searchMember(_searchController.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonCol,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: Text(
                        "Search",
                        style: TextStyle(color: textCol1),
                      ),
                    ),
                    const Spacer(),
                    if (users.isNotEmpty)
                      ElevatedButton(
                        onPressed: () async {
                          await _addMember(cliqueListProvider, cliqueProvider);
                          context.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonCol,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: Text(
                          "Add Member",
                          style: TextStyle(color: textCol1),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return CheckboxListTile(
                          title: Text(user.name),
                          activeColor: theme.colorScheme.secondary,
                          value: selectedUsers.contains(user.id),
                          onChanged: (bool? checked) {
                            setState(() {
                              if (checked == true) {
                                selectedUsers.add(user.id);
                              } else {
                                selectedUsers.remove(user.id);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
