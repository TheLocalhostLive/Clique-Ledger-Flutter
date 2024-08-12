import 'package:flutter/material.dart';

class SpendTransactionSliderPage extends StatefulWidget {
  final List<Map<String, String>> selectedMembers;
  final double amount;

  const SpendTransactionSliderPage({
    Key? key,
    required this.selectedMembers,
    required this.amount,
  }) : super(key: key);

  @override
  State<SpendTransactionSliderPage> createState() => _SpendTransactionSliderPageState();
}

class _SpendTransactionSliderPageState extends State<SpendTransactionSliderPage> {
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Allocate Spend Amount'),
      ),
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
                        Text('Allocate for $memberName', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Slider(
                          value: memberAllocations[memberId]!,
                          min: 0,
                          max: widget.amount,
                          divisions: 1000,
                          label: memberAllocations[memberId]!.toStringAsFixed(2),
                          onChanged: (value) {
                            setState(() {
                              memberAllocations[memberId] = value;
                            });
                          },
                        ),
                        TextFormField(
                          initialValue: memberAllocations[memberId]!.toStringAsFixed(2),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Amount',
                            border: OutlineInputBorder(),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text('₹', style: TextStyle(fontSize: 18)),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              double? parsedValue = double.tryParse(value);
                              if (parsedValue != null && parsedValue <= widget.amount) {
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
              onPressed: () {
                // Handle the submission of allocated amounts
                print(memberAllocations);
              },
              child: Text('Submit Allocations'),
            ),
          ],
        ),
      ),
    );
  }
}
