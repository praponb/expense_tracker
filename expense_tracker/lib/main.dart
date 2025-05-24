import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'models/expense.dart';
import 'models/category.dart';
import 'screens/search_screen.dart';
import 'screens/summary_screen.dart';
import 'screens/settings_screen.dart';
import 'services/database_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ExpenseTracker(),
    );
  }
}

class ExpenseTracker extends StatefulWidget {
  const ExpenseTracker({super.key});

  @override
  State<ExpenseTracker> createState() => _ExpenseTrackerState();
}

class _ExpenseTrackerState extends State<ExpenseTracker> {
  final List<Expense> _expenses = [];
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  final _databaseService = DatabaseService();
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
    _loadCategories();
  }

  Future<void> _loadExpenses() async {
    final expenses = await _databaseService.getExpenses();
    setState(() {
      _expenses.addAll(expenses);
    });
  }

  Future<void> _loadCategories() async {
    final categories = await _databaseService.getCategories();
    setState(() {
      _categories = categories;
      if (_categories.isNotEmpty && _selectedCategory == null) {
        _selectedCategory = _categories[0].name;
      }
    });
  }

  Future<void> _addExpense() async {
    if (_formKey.currentState!.validate()) {
      final expense = Expense(
        id: const Uuid().v4(),
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        category: _selectedCategory ?? _categories[0].name,
      );

      await _databaseService.insertExpense(expense);
      setState(() {
        _expenses.add(expense);
        _descriptionController.clear();
        _amountController.clear();
        _selectedCategory = null;
      });
    }
  }

  Future<void> _updateExpense(Expense expense) async {
    _descriptionController.text = expense.description;
    _amountController.text = expense.amount.toString();
    _selectedDate = expense.date;
    _selectedCategory = expense.category;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Expense'),
        content: _buildExpenseForm(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final updatedExpense = expense.copyWith(
                  description: _descriptionController.text,
                  amount: double.parse(_amountController.text),
                  date: _selectedDate,
                  category: _selectedCategory,
                );

                await _databaseService.updateExpense(updatedExpense);
                setState(() {
                  final index = _expenses.indexWhere((e) => e.id == expense.id);
                  if (index != -1) {
                    _expenses[index] = updatedExpense;
                  }
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteExpense(Expense expense) async {
    await _databaseService.deleteExpense(expense.id);
    setState(() {
      _expenses.removeWhere((e) => e.id == expense.id);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildExpenseForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an amount';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(labelText: 'Category'),
            items: _categories.map((Category category) {
              return DropdownMenuItem<String>(
                value: category.name,
                child: Text(category.name),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a category';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            title: Text('Date: ${_selectedDate.toString().split(' ')[0]}'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _selectDate(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
              _loadCategories();
            },
          ),
          IconButton(
            icon: const Icon(Icons.summarize),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SummaryScreen(expenses: _expenses),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(expenses: _expenses),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _expenses.length,
              itemBuilder: (context, index) {
                final sortedExpenses = List<Expense>.from(_expenses)
                  ..sort((a, b) => b.date.compareTo(a.date));
                final expense = sortedExpenses[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    title: Text(expense.description),
                    subtitle: Text(
                      '${expense.category} - ${expense.date.toString().split(' ')[0]}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '฿${expense.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _updateExpense(expense),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteExpense(expense),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Add New Expense'),
              content: _buildExpenseForm(),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    _addExpense();
                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}
