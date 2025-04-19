class Expense {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String category;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
  });

  Expense copyWith({
    String? id,
    String? description,
    double? amount,
    DateTime? date,
    String? category,
  }) {
    return Expense(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      description: map['description'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      category: map['category'],
    );
  }
}
