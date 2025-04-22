import 'package:flutter/material.dart';
import '../models/expense.dart';

class CategoryExpensesScreen extends StatelessWidget {
  final String monthYear;
  final String category;
  final List<Expense> expenses;

  const CategoryExpensesScreen({
    super.key,
    required this.monthYear,
    required this.category,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final categoryExpenses = expenses.where((expense) {
      final expenseMonthYear =
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      return expenseMonthYear == monthYear && expense.category == category;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('$category - $monthYear'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: categoryExpenses.length,
        itemBuilder: (context, index) {
          final expense = categoryExpenses[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(expense.description),
              subtitle: Text(expense.date.toString().split(' ')[0]),
              trailing: Text(
                '฿${expense.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
