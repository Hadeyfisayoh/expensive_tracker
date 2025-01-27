import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../viewmodels/transaction_viewmodel.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedCurrency = "USD";
  Map<String, double> _conversionRates = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchConversionRates();
  }

  Future<void> _fetchConversionRates() async {
    setState(() {
      _isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();

    // Check cached rates
    final cacheTime = prefs.getInt('cache_time') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    if (currentTime - cacheTime < 3600000 && prefs.containsKey('conversion_rates')) {
      final cachedRates = jsonDecode(prefs.getString('conversion_rates')!);
      setState(() {
        _conversionRates = Map<String, double>.from(
          cachedRates.map((key, value) => MapEntry(key, (value as num).toDouble())),
        );
        _isLoading = false;
      });
      return;
    }

    // Fetch new rates from API
    final response = await http.get(Uri.parse('https://v6.exchangerate-api.com/v6/d8b52b099c8cf3fafaaf922b/latest/USD'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['result'] == 'success' && data['conversion_rates'] != null) {
        setState(() {
          _conversionRates = Map<String, double>.from(
            data['conversion_rates'].map((key, value) => MapEntry(key, (value as num).toDouble())),
          );
          _isLoading = false;
        });

        prefs.setString('conversion_rates', jsonEncode(_conversionRates));
        prefs.setInt('cache_time', DateTime.now().millisecondsSinceEpoch);
      } else {
        _showErrorSnackbar('Invalid API response or missing conversion rates');
      }
    } else {
      _showErrorSnackbar('Failed to fetch conversion rates');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    setState(() {
      _isLoading = false;
    });
  }

  double _convertAmount(double amount) {
    final rate = _conversionRates[_selectedCurrency] ?? 1.0;
    return amount * rate;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        automaticallyImplyLeading: false,  // Remove the back arrow
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (user != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Welcome, ${user.displayName ?? 'User'}!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                        DropdownButton<String>(
                          value: _selectedCurrency,
                          items: ["USD", "EUR", "NGN", "GBP", "JPY"].map((currency) {
                            return DropdownMenuItem(
                              value: currency,
                              child: Text(currency),
                            );
                          }).toList(),
                          onChanged: (value) async {
                            setState(() {
                              _selectedCurrency = value!;
                            });
                            await _fetchConversionRates();
                          },
                          underline: Container(),  // Remove underline
                          style: TextStyle(color: Colors.blueGrey[800], fontSize: 16),
                          dropdownColor: Colors.white,
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  Consumer<TransactionViewModel>(builder: (context, viewModel, _) {
                    final totalExpensesConverted = _convertAmount(viewModel.totalExpenses);
                    return Text(
                      "Total Expenses: ${_selectedCurrency} ${totalExpensesConverted.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Consumer<TransactionViewModel>(builder: (context, viewModel, _) {
                      return ListView.builder(
                        itemCount: viewModel.expenses.length,
                        itemBuilder: (context, index) {
                          final expense = viewModel.expenses[index];
                          final convertedAmount = _convertAmount(expense.amount);
                          return Card(
                            elevation: 5,
                            shadowColor: Colors.grey.withOpacity(0.3),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              title: Text(
                                expense.description,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueGrey[900],
                                ),
                              ),
                              subtitle: Text(
                                expense.category,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blueGrey[500],
                                ),
                              ),
                              trailing: Text(
                                "${_selectedCurrency} ${convertedAmount.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[600],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-expense');
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
