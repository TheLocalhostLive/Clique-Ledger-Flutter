import 'package:cliqueledger/api_helpers/transactionPost.dart';
import 'package:cliqueledger/models/ParticipantsPost.dart';
import 'package:cliqueledger/models/TransactionPostSchema.dart';
import 'package:cliqueledger/models/participants.dart';
import 'package:cliqueledger/providers/CliqueListProvider.dart';
import 'package:cliqueledger/providers/TransactionProvider.dart';
import 'package:cliqueledger/providers/cliqueProvider.dart';
import 'package:cliqueledger/themes/appBarTheme.dart';
import 'package:cliqueledger/utility/routers_constant.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SpendTransactionSliderPage extends StatefulWidget {
  final List<Map<String, String>> selectedMembers;
  final num amount;
  final String description;

  const SpendTransactionSliderPage(
      {Key? key,
      required this.selectedMembers,
      required this.amount,
      required this.description})
      : super(key: key);

  @override
  State<SpendTransactionSliderPage> createState() =>
      _SpendTransactionSliderPageState();
}

class _SpendTransactionSliderPageState
    extends State<SpendTransactionSliderPage> {
  // State to store allocated amounts for each member
  late Map<String, double> memberAllocations;

  @override
  void initState() {
    super.initState();
    // Initialize member allocations with 0.0 for each selected member
    memberAllocations = {
      for (var member in widget.selectedMembers) member['memberId']!: 0.0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<TransactionProvider, CliqueProvider, CliqueListProvider>(
        builder: (context, transactionProvider, cliqueProvider,
            CliqueListProvider, child) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: GradientAppBar(title: "Allocate Spend Amoung"),
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
                          Text('Allocate for $memberName',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Slider(
                            activeColor: Color(0xFFE4003A),
                            value: memberAllocations[memberId]!,
                            min: 0,
                            max: widget.amount.toDouble(),
                            divisions: 1000,
                            label:
                                memberAllocations[memberId]!.toStringAsFixed(2),
                            onChanged: (value) {
                              setState(() {
                                memberAllocations[memberId] = value;
                              });
                            },
                          ),
                          TextFormField(
                            cursorColor: const Color.fromARGB(255, 188, 5, 51),
                            initialValue:
                                memberAllocations[memberId]!.toStringAsFixed(2),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                color: Color.fromARGB(255, 114, 4, 32),
                              )),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                color: Color.fromARGB(255, 114, 4, 32),
                              )),
                              floatingLabelStyle: TextStyle(color: Color(0xFFE4003A)),
                              labelText: 'Amount',
                              border: OutlineInputBorder(),
                              prefixIcon: Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 8.0),
                                child:
                                    Text('₹', style: TextStyle(fontSize: 18)),
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
                    backgroundColor: Color(0xFFFFB200)),
                onPressed: () async {
                  double totalAmount =
                      memberAllocations.values.reduce((a, b) => a + b);

                  if (totalAmount > widget.amount) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
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
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
