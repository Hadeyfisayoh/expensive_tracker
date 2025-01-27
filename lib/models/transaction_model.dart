import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final double amount;
  final String category;
  final String description;
  final DateTime date;

  Expense({
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
  });

  // Convert Expense object to JSON
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'category': category,
      'description': description,
      'date': Timestamp.fromDate(date), // Convert DateTime to Timestamp
    };
  }

  // Convert JSON to Expense object
  static Expense fromJson(Map<String, dynamic> json) {
    return Expense(
      amount: json['amount'] as double,
      category: json['category'] as String,
      description: json['description'] as String,
      date: (json['date'] as Timestamp).toDate(), // Convert Timestamp to DateTime
    );
  }
}
