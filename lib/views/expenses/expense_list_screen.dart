import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/expense_viewmodel.dart';

class ExpenseListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense List'),
      ),
      body: FutureBuilder(
        future: Provider.of<ExpenseViewModel>(context, listen: false).fetchExpenses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading expenses.'));
          }
          return Consumer<ExpenseViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.expenses.isEmpty) {
                return const Center(child: Text('No expenses added.'));
              }

              return ListView.builder(
                itemCount: viewModel.expenses.length,
                itemBuilder: (context, index) {
                  final expense = viewModel.expenses[index];
                  return ListTile(
                    title: Text(expense.description),
                    subtitle: Text('${expense.category} - \$${expense.amount.toStringAsFixed(2)}'),
                    trailing: Text(expense.date.toLocal().toString().split(' ')[0]),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}