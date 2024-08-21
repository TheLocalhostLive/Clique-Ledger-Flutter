import 'package:cliqueledger/api_helpers/MemberApi.dart';
import 'package:cliqueledger/models/member.dart';
import 'package:cliqueledger/models/user.dart';
import 'package:cliqueledger/providers/CliqueListProvider.dart';
import 'package:cliqueledger/providers/cliqueProvider.dart';
import 'package:cliqueledger/themes/appBarTheme.dart';
import 'package:cliqueledger/utility/routers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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

  Future<void> _addMember(CliqueListProvider cl , CliqueProvider c) async{
    await MemberApi.addUserPost(selectedUsers, cl, c);
    
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CliqueProvider, CliqueListProvider>(
      builder: (context, cliqueProvider, cliqueListProvider, child) {
        return Scaffold(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          appBar: const GradientAppBar(title: "Clique Ledger"),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Search Member",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 220, 220, 220),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    hintText: "eg: ant@example.com",
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _searchMember(_searchController.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF874CCC),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),

                      child: const Text("Search",style: TextStyle(color: Color(0xFFE8E8E8)),),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: ()async{
                          await _addMember(cliqueListProvider,cliqueProvider);
                          context.pop();
                      },
                      
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF874CCC),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      child: const Text("Add Member",style: TextStyle(color: Color(0xFFE8E8E8)),),
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
                          activeColor: Color(0xFFF27BBD),
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
