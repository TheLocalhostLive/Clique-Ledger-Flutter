import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';


import 'package:cliqueledger/api_helpers/Member_api.dart';

import 'package:cliqueledger/models/user.dart';
import 'package:cliqueledger/providers/Clique_list_provider.dart';
import 'package:cliqueledger/providers/clique_provider.dart';
import 'package:cliqueledger/themes/app_bar_theme.dart';

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
      // ignore: use_build_context_synchronously
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

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Member added successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get current theme

    return Consumer2<CliqueProvider, CliqueListProvider>(
      builder: (context, cliqueProvider, cliqueListProvider, child) {
        var buttonCol = theme.colorScheme.secondary;
        return Scaffold(
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
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  cursorColor: theme.colorScheme.tertiary, // Set cursor color based on theme
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
                        style: TextStyle(color: theme.textTheme.titleSmall?.color),
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
                          style: TextStyle(color: theme.textTheme.titleSmall?.color),
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
