import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/budget.dart';
import '../services/database_service.dart';
import 'category_expenses_screen.dart';

class SummaryScreen extends StatefulWidget {
  final List<Expense> expenses;

  const SummaryScreen({
    super.key,
    required this.expenses,
  });

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final _databaseService = DatabaseService();
  final _budgetController = TextEditingController();
  Map<String, double> _budgets = {};

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    final budgets = await _databaseService.getAllBudgets();
    setState(() {
      _budgets = budgets;
    });
  }

  Future<void> _setBudget(String monthYear) async {
    final currentBudget = _budgets[monthYear];
    _budgetController.text = currentBudget?.toString() ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Budget for $monthYear'),
        content: TextField(
          controller: _budgetController,
          decoration: const InputDecoration(
            labelText: 'Budget Amount',
            prefixText: '฿',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final amount = double.tryParse(_budgetController.text);
              if (amount != null && amount >= 0) {
                await _databaseService.setBudget(
                  Budget(monthYear: monthYear, amount: amount),
                );
                await _loadBudgets();
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Map<String, double> _getMonthlySummary() {
    final monthlySummary = <String, double>{};
    for (final expense in widget.expenses) {
      final monthYear =
          '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      monthlySummary[monthYear] =
          (monthlySummary[monthYear] ?? 0) + expense.amount;
    }
    return monthlySummary;
  }

  Map<String, Map<String, double>> _getMonthlyCategorySummary() {
    final monthlyCategorySummary = <String, Map<String, double>>{};
    for (final expense in widget.expenses) {
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
              final budget = _budgets[monthEntry.key] ?? 0;
              final remaining = budget - monthTotal;
              final remainingColor = remaining >= 0 ? Colors.green : Colors.red;

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
                          Row(
                            children: [
                              Text(
                                'Total: ฿${monthTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => _setBudget(monthEntry.key),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (budget > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Budget: ฿${budget.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Remaining: ฿${remaining.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: remainingColor,
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
                                          expenses: widget.expenses,
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

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }
}
