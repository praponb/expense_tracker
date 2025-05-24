class Budget {
  final String monthYear;
  final double amount;

  Budget({
    required this.monthYear,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'monthYear': monthYear,
      'amount': amount,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      monthYear: map['monthYear'],
      amount: map['amount'],
    );
  }
}
