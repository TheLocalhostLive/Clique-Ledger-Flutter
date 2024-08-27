import 'package:cliqueledger/api_helpers/MemberApi.dart';
import 'package:cliqueledger/api_helpers/cliqueApi.dart';
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

  Future<String> setNewName(CliqueProvider cliqueProvider,String cliqueId , CliqueListProvider cliqueListProvider,String cliqeName) async{
      int code = await CliqueApi.changeCliqueName(cliqueId, cliqeName, cliqueListProvider, context);
      if(code == 200){
        cliqueProvider.currentClique!.name = cliqeName;
        return cliqeName;
      }
      return "";

  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer2<CliqueListProvider, CliqueProvider>(
      builder: (context, cliqueListProvider, cliqueProvider, child) {
        TextEditingController _nameController =
            TextEditingController(text: cliqueProvider.currentClique!.name);

        return Scaffold(
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
                        border: Border.all(
                          color: theme.colorScheme.onSurface, // Border color
                          width: 3.0,
                        ),
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
                              color: theme.colorScheme.secondary, // Border color
                              width: 1.5,
                            ),
                          ),
                          child: isEditing
                              ? TextField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  style: theme.textTheme.bodyLarge,
                                  cursorColor: theme.colorScheme.primary,
                                )
                              : Text(
                                  _nameController.text,
                                  style: theme.textTheme.titleMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: theme.colorScheme.secondary, // Icon color
                        ),
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
                          onPressed: () async {
                            String newName = await setNewName(cliqueProvider,cliqueProvider.currentClique!.id,cliqueListProvider,_nameController.text);
                            setState(() {
                              isEditing = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary,
                          ),
                          child: Text(
                            "Save",
                            style: theme.textTheme.labelLarge!.copyWith(
                              color: theme.textTheme.titleSmall?.color,
                            ),
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        "Participants",
                        style: theme.textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          context.push(RoutersConstants.ADD_MEMBER_ROUTE);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.secondary,
                        ),
                        child: Text(
                          "Add Member",
                          style: theme.textTheme.labelLarge!.copyWith(
                            color: theme.textTheme.titleSmall?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: cliqueListProvider
                        .activeCliqueList[cliqueProvider.currentClique!.id]!
                        .members
                        .length,
                    itemBuilder: (context, index) {
                      final member = cliqueListProvider
                          .activeCliqueList[cliqueProvider.currentClique!.id]!
                          .members[index];
                      return Card(
                        color: theme.colorScheme.primary,
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                member.name,
                                style: theme.textTheme.bodyLarge,
                              ),
                              Text(
                                member.email,
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: theme.colorScheme.error, // Delete icon color
                            ),
                            onPressed: () async {
                              await MemberApi.removeMember(
                                cliqueProvider.currentClique!.id,
                                member.memberId,
                                cliqueListProvider,
                                context,
                              );
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
