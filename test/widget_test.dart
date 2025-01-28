import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:expensive_tracker/viewmodels/transaction_viewmodel.dart'; // Ensure the correct import
import 'package:expensive_tracker/models/transaction_model.dart'; // Ensure the correct import


void main() {
testWidgets('Expense is added', (WidgetTester tester) async {
  final expense = Expense(description: 'Test Expense', amount: 100.0, category: 'Food', date: DateTime.now());

  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (context) => TransactionViewModel(),
      child: MaterialApp(
        home: Scaffold(
          body: Consumer<TransactionViewModel>(
            builder: (context, viewModel, _) {
              return Column(
                children: [
                  TextButton(
                    onPressed: () {
                      // viewModel.addExpense(expense); // Use addExpense here
                    },
                    child: const Text('Add Expense'),
                  ),
                  ListView.builder(
                    itemCount: viewModel.expenses.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(viewModel.expenses[index].description),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );

  // Trigger the Add Expense button
  await tester.tap(find.text('Add Expense'));
  await tester.pump();

  // Verify if the expense is added
  expect(find.text('Test Expense'), findsOneWidget);
});
}