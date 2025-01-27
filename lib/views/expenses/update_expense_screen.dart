import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting the date
import '../../models/transaction_model.dart';

class UpdateExpenseScreen extends StatefulWidget {
  final Expense expense;

  const UpdateExpenseScreen({Key? key, required this.expense}) : super(key: key);

  @override
  State<UpdateExpenseScreen> createState() => _UpdateExpenseScreenState();
}

class _UpdateExpenseScreenState extends State<UpdateExpenseScreen> {
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;

  final List<String> _categories = ['Food', 'Transport', 'Health', 'Entertainment', 'Other'];

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.expense.description);
    _amountController = TextEditingController(text: widget.expense.amount.toString());
    _selectedDate = widget.expense.date; // Assuming `Expense` has a `date` property
    _selectedCategory = _categories.contains(widget.expense.category)
        ? widget.expense.category
        : _categories.first; // Ensure the initial value is valid
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Expense',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent, // Changed to blue
        elevation: 0, // Remove shadow
        iconTheme: IconThemeData(color: Colors.white), // White back icon
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Expense Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent, // Changed to blue
                ),
              ),
              SizedBox(height: 24),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.blueAccent), // Changed to blue
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent), // Changed to blue
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2), // Changed to blue
                  ),
                  prefixIcon: Icon(Icons.description, color: Colors.blueAccent), // Changed to blue
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  labelStyle: TextStyle(color: Colors.blueAccent), // Changed to blue
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent), // Changed to blue
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2), // Changed to blue
                  ),
                  prefixIcon: Icon(Icons.attach_money, color: Colors.blueAccent), // Changed to blue
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blueAccent), // Changed to blue
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Date: ${DateFormat.yMMMd().format(_selectedDate)}',
                        style: TextStyle(fontSize: 16, color: Colors.blueAccent), // Changed to blue
                      ),
                      Icon(Icons.calendar_today, color: Colors.blueAccent), // Changed to blue
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(
                      category,
                      style: TextStyle(color: Colors.blueAccent), // Changed to blue
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(color: Colors.blueAccent), // Changed to blue
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent), // Changed to blue
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2), // Changed to blue
                  ),
                  prefixIcon: Icon(Icons.category, color: Colors.blueAccent), // Changed to blue
                ),
              ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Save the updated expense logic here
                    final updatedExpense = Expense(
                      id: widget.expense.id, // Retain the original ID
                      description: _descriptionController.text,
                      amount: double.parse(_amountController.text),
                      date: _selectedDate,
                      category: _selectedCategory ?? widget.expense.category,
                    );

                    // Pass back the updated expense (or update it in your ViewModel)
                    Navigator.pop(context, updatedExpense);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, // Changed to blue
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}