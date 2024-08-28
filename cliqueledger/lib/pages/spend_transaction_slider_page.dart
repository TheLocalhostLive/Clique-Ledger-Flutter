import 'package:cliqueledger/api_helpers/transaction_post.dart';
import 'package:cliqueledger/models/Participants_post.dart';
import 'package:cliqueledger/models/Transaction_post_schema.dart';

import 'package:cliqueledger/providers/Clique_list_provider.dart';
import 'package:cliqueledger/providers/transaction_provider.dart';
import 'package:cliqueledger/providers/clique_provider.dart';
import 'package:cliqueledger/themes/app_bar_theme.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SpendTransactionSliderPage extends StatefulWidget {
  final List<Map<String, String>> selectedMembers;
  final num amount;
  final String description;

  const SpendTransactionSliderPage(
      {super.key,
      required this.selectedMembers,
      required this.amount,
      required this.description});

  @override
  State<SpendTransactionSliderPage> createState() =>
      _SpendTransactionSliderPageState();
}

class _SpendTransactionSliderPageState
    extends State<SpendTransactionSliderPage> {
  late Map<String, double> memberAllocations;

  @override
  void initState() {
    super.initState();
    memberAllocations = {
      for (var member in widget.selectedMembers) member['memberId']!: 0.0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer3<TransactionProvider, CliqueProvider, CliqueListProvider>(
        builder: (context, transactionProvider, cliqueProvider,
            // ignore: avoid_types_as_parameter_names, non_constant_identifier_names
            CliqueListProvider, child) {
      return Scaffold(
        appBar: const GradientAppBar(title: "Allocate Spend Among"),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: widget.selectedMembers.length,
                  itemBuilder: (context, index) {
                    final member = widget.selectedMembers[index];
                    final memberId = member['memberId']!;
                    final memberName = member['name']!;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Allocate for $memberName',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                          Slider(
                            activeColor: theme.colorScheme.secondary,
                            value: memberAllocations[memberId]!,
                            min: 0,
                            max: widget.amount.toDouble(),
                            divisions: 1000,
                            label: memberAllocations[memberId]!
                                .toStringAsFixed(2),
                            onChanged: (value) {
                              setState(() {
                                memberAllocations[memberId] = value;
                              });
                            },
                          ),
                          TextFormField(
                            cursorColor: theme.colorScheme.primary,
                            initialValue: memberAllocations[memberId]!
                                .toStringAsFixed(2),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                              floatingLabelStyle: TextStyle(
                                color: theme.colorScheme.tertiary,
                              ),
                              labelText: 'Amount',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Padding(
                                padding:
                                     EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  '₹',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                double? parsedValue = double.tryParse(value);
                                if (parsedValue != null &&
                                    parsedValue <= widget.amount) {
                                  memberAllocations[memberId] = parsedValue;
                                } else {
                                  // Handle invalid input or input exceeding the total amount
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                ),
                onPressed: () async {
                  double totalAmount =
                      memberAllocations.values.reduce((a, b) => a + b);

                  if (totalAmount > widget.amount) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text("Total amount is exceeding the spend amount"),
                      ),
                    );
                  } else {
                    List<Participantspost> participants = [];
                    memberAllocations.forEach((k, v) {
                      Participantspost participant =
                          Participantspost(id: k, amount: v);
                      participants.add(participant);
                    });
                    TransactionPostschema tSchema = TransactionPostschema(
                        cliqueId: cliqueProvider.currentClique!.id,
                        type: "spend",
                        participants: participants,
                        amount: widget.amount,
                        description: widget.description);
                    await TransactionPost.postData(tSchema, transactionProvider,
                        cliqueProvider, CliqueListProvider);
                    // ignore: use_build_context_synchronously
                    context.pop();
                  }
                },
                child: Text(
                  'Submit Allocations',
                  style: TextStyle(color: theme.textTheme.titleSmall?.color),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
