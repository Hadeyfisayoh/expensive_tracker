import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction_model.dart';

class TransactionViewModel extends ChangeNotifier {
  List<Expense> _expenses = [];
  Map<String, double> _exchangeRates = {};
  String _selectedCurrency = 'USD'; // Default currency
  double _conversionRate = 1.0; // Conversion rate for selected currency

  List<Expense> get expenses => _expenses;

  String get selectedCurrency => _selectedCurrency;

  double get totalExpenses {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount * _conversionRate);
  }

  // Fetch expenses from Firestore based on userId
  // Updated version of your fetchExpensesByUser method
Future<void> fetchExpensesByUser(String userId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('expenses')
          .where('userId', isEqualTo: userId)
          .get();

      _expenses = querySnapshot.docs.map((doc) {
        return Expense.fromJson(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      notifyListeners();
    } catch (error) {
      print('Error fetching expenses for user: $error');
    }
  }


  // Add expense to Firestore
  Future<void> addExpenseToFirestore(String userId, Expense expense) async {
    try {
      await FirebaseFirestore.instance.collection('expenses').add({
        'userId': userId,
        'description': expense.description,
        'amount': expense.amount,
        'category': expense.category,
        'date': expense.date.toIso8601String(),
      });

      _expenses.add(expense);
      notifyListeners();
    } catch (e) {
      print('Error adding expense to Firestore: $e');
    }
  }

  // Delete an expense from Firestore
Future<void> deleteExpense(String expenseId) async {
  try {
    // Delete from Firestore
    await FirebaseFirestore.instance.collection('expenses').doc(expenseId).delete();

    // Remove from the local list
    _expenses.removeWhere((expense) => expense.id == expenseId);
    notifyListeners();
  } catch (e) {
    print('Error deleting expense: $e');
  }
}


  // Fetch exchange rates from the API and update the rates map
  Future<void> fetchExchangeRates() async {
    try {
      final response = await http.get(Uri.parse('https://v6.exchangerate-api.com/v6/d8b52b099c8cf3fafaaf922b/latest/USD'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] == 'success') {
          final Map<String, double> rates = {};
          (data['conversion_rates'] as Map<String, dynamic>).forEach((key, value) {
            rates[key] = value.toDouble();
          });
          _exchangeRates = rates;
          notifyListeners();
        }
      } else {
        print('Failed to load exchange rates');
      }
    } catch (e) {
      print('Error fetching exchange rates: $e');
    }
  }

  // Set selected currency and update the conversion rate
  void setSelectedCurrency(String currency) {
    _selectedCurrency = currency;
    _conversionRate = _exchangeRates[_selectedCurrency] ?? 1.0;
    notifyListeners();
  }

  // Get the converted amount for displaying in the selected currency
  double getConvertedAmount(double amount) {
    return amount * _conversionRate;
  }
}
