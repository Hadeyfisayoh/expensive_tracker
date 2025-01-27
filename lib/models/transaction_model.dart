import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String description;
  final double amount;
  final String category;
  final DateTime date;

  Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
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
  static Expense fromJson(Map<String, dynamic> json, String id) {
    return Expense(
      id: id,  // Add the id as well
      amount: json['amount'] as double,
      category: json['category'] as String,
      description: json['description'] as String,
      date: json['date'] is String
          ? DateTime.parse(json['date'])  // Parse if it's a string
          : (json['date'] as Timestamp).toDate(), // Convert Timestamp to DateTime
    );
  }
}
