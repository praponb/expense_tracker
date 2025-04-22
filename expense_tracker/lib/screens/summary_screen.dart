import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'category_expenses_screen.dart';

class SummaryScreen extends StatelessWidget {
  final List<Expense> expenses;

  const SummaryScreen({
    super.key,
    required this.expenses,
  });

  Map<String, double> _getMonthlySummary() {
    final monthlySummary = <String, double>{};
    for (final expense in expenses) {
      final monthYear =
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      monthlySummary[monthYear] =
          (monthlySummary[monthYear] ?? 0) + expense.amount;
    }
    return monthlySummary;
  }

  Map<String, Map<String, double>> _getMonthlyCategorySummary() {
    final monthlyCategorySummary = <String, Map<String, double>>{};
    for (final expense in expenses) {
      final monthYear =
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      if (!monthlyCategorySummary.containsKey(monthYear)) {
        monthlyCategorySummary[monthYear] = {};
      }
      monthlyCategorySummary[monthYear]![expense.category] =
          (monthlyCategorySummary[monthYear]![expense.category] ?? 0) +
              expense.amount;
    }
    return monthlyCategorySummary;
  }

  @override
  Widget build(BuildContext context) {
    final monthlySummary = _getMonthlySummary();
    final monthlyCategorySummary = _getMonthlyCategorySummary();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Summary'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Category Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...monthlyCategorySummary.entries.map((monthEntry) {
              final monthTotal = monthlySummary[monthEntry.key] ?? 0;
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            monthEntry.key,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Total: ฿${monthTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    ...monthEntry.value.entries.map((categoryEntry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(categoryEntry.key),
                            Row(
                              children: [
                                Text(
                                  '฿${categoryEntry.value.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.visibility),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CategoryExpensesScreen(
                                          monthYear: monthEntry.key,
                                          category: categoryEntry.key,
                                          expenses: expenses,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
