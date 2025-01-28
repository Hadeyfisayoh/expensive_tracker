import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/splash_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/registration_screen.dart';
import 'views/dashboard/dashboard_screen.dart';
import 'views/expenses/add_expense_screen.dart';
import 'views/expenses/update_expense_screen.dart'; // Import the UpdateExpenseScreen
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/transaction_viewmodel.dart';
import 'models/transaction_model.dart'; // Import the Expense model
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => TransactionViewModel()),
      ],
      child: MaterialApp(
        title: 'Expense Tracker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(
            secondary: Colors.blueAccent,
            onPrimary: Colors.white,
          ),
          textTheme: TextTheme(
            bodyMedium: TextStyle(fontSize: 16, color: Colors.black87), // Replaced bodyText1
            titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // Replaced headline6
          ),
          appBarTheme: AppBarTheme(
            color: Colors.blueAccent,
            elevation: 4,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.blueAccent,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegistrationScreen(),
          '/dashboard': (context) => DashboardScreen(),
          '/add-expense': (context) => AddExpenseScreen(),
        },
        // Use onGenerateRoute for dynamic routes with arguments
        onGenerateRoute: (settings) {
          if (settings.name == '/update-expense') {
            final expense = settings.arguments as Expense; // Cast the argument to Expense
            return MaterialPageRoute(
              builder: (context) => UpdateExpenseScreen(expense: expense),
            );
          }
          return null; // Fallback for undefined routes
        },
      ),
    );
  }
}