import 'package:cliqueledger/api_helpers/Member_api.dart';
import 'package:cliqueledger/api_helpers/clique_api.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:cliqueledger/models/member.dart';
import 'package:cliqueledger/providers/Clique_list_provider.dart';
import 'package:cliqueledger/providers/clique_provider.dart';

import 'package:cliqueledger/themes/app_bar_theme.dart';
import 'package:cliqueledger/utility/routers_constant.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<Member> memberList = [];
  bool isEditing = false;

  Future<String> setNewName(CliqueProvider cliqueProvider, String cliqueId,
      CliqueListProvider cliqueListProvider, String cliqeName) async {
    int code = await CliqueApi.changeCliqueName(
        cliqueId, cliqeName, cliqueListProvider, context);
    if (code == 200) {
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
        TextEditingController nameController =
            TextEditingController(text: cliqueProvider.currentClique!.name);

        return Scaffold(
          appBar: const GradientAppBar(title: "Clique Ledger"),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
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
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color:
                                  theme.colorScheme.secondary, // Border color
                              width: 1.5,
                            ),
                          ),
                          child: isEditing
                              ? TextField(
                                  controller: nameController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  style: theme.textTheme.bodyLarge,
                                  cursorColor: theme.colorScheme.primary,
                                )
                              : Text(
                                  nameController.text,
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
                            await setNewName(
                                cliqueProvider,
                                cliqueProvider.currentClique!.id,
                                cliqueListProvider,
                                nameController.text);
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
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    member.name,
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  member.isAdmin
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.secondary,
                                            borderRadius: BorderRadius.circular(
                                                8), // Rounded rectangle border
                                          ),
                                          child: Text(
                                            "Admin",
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: theme
                                                  .textTheme.bodySmall?.color,
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ],
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
                              color:
                                  theme.colorScheme.error, // Delete icon color
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
