import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String description;
  final double amount;
  final String category;
  final DateTime date;

  Expense({
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
  });

  // Factory constructor to create an Expense from Firestore document
  factory Expense.fromFirestore(Map<String, dynamic> data) {
    return Expense(
      description: data['description'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      category: data['category'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }
}

class ExpenseViewModel extends ChangeNotifier {
  final List<Expense> _expenses = [];

  List<Expense> get expenses => _expenses;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchExpenses() async {
    try {
      final querySnapshot = await _firestore.collection('expenses').get();
      _expenses.clear();
      for (var doc in querySnapshot.docs) {
        _expenses.add(Expense.fromFirestore(doc.data()));
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching expenses: $e');
      }
    }
  }
}