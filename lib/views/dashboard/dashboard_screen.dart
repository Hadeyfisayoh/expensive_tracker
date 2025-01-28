import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // To format the date
import 'package:fl_chart/fl_chart.dart'; // For the chart

import '../../models/transaction_model.dart'; // Import the Expense class
import '../../viewmodels/transaction_viewmodel.dart'; // Import the TransactionViewModel

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedCurrency = "USD";
  Map<String, double> _conversionRates = {};
  bool _isLoading = true;
  int _currentIndex = 0; // For bottom navigation bar
  bool _isSearching = false; // To toggle search bar visibility
  final TextEditingController _searchController = TextEditingController(); // For search functionality
  List<Expense> _filteredExpenses = []; // To store filtered expenses

  @override
  void initState() {
    super.initState();
    _fetchConversionRates();
    _fetchDatabaseData(); // Fetch the database data here
  }

  Future<void> _fetchConversionRates() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final cacheTime = prefs.getInt('cache_time') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // Check cached rates
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

    // Fetch new rates from API if cache is expired or unavailable
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

        // Cache the conversion rates and update cache time
        prefs.setString('conversion_rates', jsonEncode(_conversionRates));
        prefs.setInt('cache_time', DateTime.now().millisecondsSinceEpoch);
      } else {
        _showErrorSnackbar('Invalid API response or missing conversion rates');
      }
    } else {
      _showErrorSnackbar('Failed to fetch conversion rates');
    }
  }

  // Fetch the data for expenses from the database
  Future<void> _fetchDatabaseData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final viewModel = Provider.of<TransactionViewModel>(context, listen: false);
      await viewModel.fetchExpensesByUser(user.uid); // Use fetchExpensesByUser here
      setState(() {
        _filteredExpenses = viewModel.expenses; // Initialize filtered expenses with all expenses
      });
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

  String _formatDate(DateTime date) {
    return DateFormat('MM/dd/yyyy').format(date); // Format date as MM/DD/YYYY
  }

  // Show logout confirmation dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel", style: TextStyle(color: Colors.blueGrey)),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              child: Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Filter expenses based on search query
  void _filterExpenses(String query) {
    final viewModel = Provider.of<TransactionViewModel>(context, listen: false);
    setState(() {
      _filteredExpenses = viewModel.expenses.where((expense) {
        final descriptionMatch = expense.description.toLowerCase().contains(query.toLowerCase());
        final dateMatch = _formatDate(expense.date).toLowerCase().contains(query.toLowerCase());
        return descriptionMatch || dateMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Custom Top Bar with Gradient
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, left: 16, right: 16, bottom: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.purpleAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Expense Tracker',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.search, size: 30, color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _isSearching = !_isSearching; // Toggle search bar visibility
                                if (!_isSearching) {
                                  _searchController.clear(); // Clear search query
                                  _filterExpenses(''); // Reset filtered expenses
                                }
                              });
                            },
                          ),
                        ],
                      ),
                      // Animated Search Bar
                      if (_isSearching)
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: "Search by description or date...",
                              hintStyle: TextStyle(color: Colors.white70),
                              prefixIcon: Icon(Icons.search, color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.2),
                            ),
                            style: TextStyle(color: Colors.white),
                            onChanged: (value) {
                              _filterExpenses(value); // Filter expenses based on search query
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Welcome, ${user?.displayName ?? 'User'}!',
                              style: TextStyle(
                                fontSize: 20,
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
                              underline: Container(), // Remove underline
                              style: TextStyle(color: Colors.blueGrey[800], fontSize: 16),
                              dropdownColor: Colors.white,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Consumer<TransactionViewModel>(builder: (context, viewModel, _) {
                          final totalExpensesConverted = _convertAmount(viewModel.totalExpenses);
                          return Text(
                            "Total Expenses: $_selectedCurrency ${totalExpensesConverted.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                            ),
                          );
                        }),
                        const SizedBox(height: 20),
                        
                        ExpenseChart(expenses: _filteredExpenses),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Consumer<TransactionViewModel>(
                            builder: (context, viewModel, _) {
                              return ListView.builder(
                                itemCount: _filteredExpenses.length,
                                itemBuilder: (context, index) {
                                  final expense = _filteredExpenses[index];
                                  final convertedAmount = _convertAmount(expense.amount);
                                  return Card(
                                    elevation: 5,
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.white, Colors.grey[100]!],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
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
                                          '${expense.category} | ${_formatDate(expense.date)}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.blueGrey[500],
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "$_selectedCurrency ${convertedAmount.toStringAsFixed(2)}",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green[600],
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.edit, color: Colors.blue),
                                              onPressed: () async {
                                                // Handle update expense logic here
                                                final updatedExpense = await Navigator.pushNamed(
                                                  context,
                                                  '/update-expense',
                                                  arguments: expense,
                                                ) as Expense?;

                                                if (updatedExpense != null) {
                                                  await viewModel.updateExpense(updatedExpense);
                                                  setState(() {
                                                    _filteredExpenses = viewModel.expenses;
                                                  });
                                                }
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete, color: Colors.red),
                                              onPressed: () {
                                                // Handle delete expense logic here
                                                viewModel.deleteExpense(expense.id);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      // Floating Bottom Navigation Bar
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-expense');
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.home, size: 30, color: _currentIndex == 0 ? Colors.blueAccent : Colors.grey),
                onPressed: () {
                  setState(() {
                    _currentIndex = 0;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.person, size: 30, color: _currentIndex == 1 ? Colors.blueAccent : Colors.grey),
                onPressed: _showLogoutDialog, // Show logout dialog
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExpenseChart extends StatelessWidget {
  final List<Expense> expenses;

  const ExpenseChart({super.key, required this.expenses});

  Map<String, double> _getCategoryTotals() {
    Map<String, double> categoryTotals = {};

    for (var expense in expenses) {
      if (categoryTotals.containsKey(expense.category)) {
        categoryTotals[expense.category] = categoryTotals[expense.category]! + expense.amount;
      } else {
        categoryTotals[expense.category] = expense.amount;
      }
    }

    return categoryTotals;
  }

  @override
  Widget build(BuildContext context) {
    final categoryTotals = _getCategoryTotals();
    final categories = categoryTotals.keys.toList();
    final amounts = categoryTotals.values.toList();

    // Handle empty state
    if (amounts.isEmpty) {
      return Center(
        child: Text(
          "No expenses to display",
          style: TextStyle(
            fontSize: 16,
            color: Colors.blueGrey[800],
          ),
        ),
      );
    }

    final totalAmount = amounts.reduce((a, b) => a + b);

    // Define a list of colors for the pie chart segments
    final List<Color> segmentColors = [
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.redAccent,
      Colors.tealAccent,
    ];

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: List.generate(
                  categories.length,
                  (index) {
                    final percentage = (amounts[index] / totalAmount) * 100;
                    return PieChartSectionData(
                      color: segmentColors[index % segmentColors.length],
                      value: amounts[index],
                      title: '${percentage.toStringAsFixed(1)}%',
                      radius: 80,
                      titleStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              categories.length,
              (index) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    color: segmentColors[index % segmentColors.length],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    categories[index],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}