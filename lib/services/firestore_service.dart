import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';

class FirestoreService {
  Future<void> addExpenseToFirestore(Expense expense) async {
    if (expense.amount <= 0 || expense.category.isEmpty || expense.description.isEmpty) {
      throw Exception("Invalid expense data");
    }

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User is not authenticated");
      }

      final expenseCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('expenses');

      await expenseCollection.add(expense.toJson());
    } catch (e) {
      print("Error adding expense to Firestore: $e");
      rethrow;
    }
  }

  Future<List<Expense>> getExpensesFromFirestore() async {
  try {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return [];
    }

    final expenseCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('expenses');

    final snapshot = await expenseCollection.get();
    return snapshot.docs
        .map((doc) => Expense.fromJson(doc.data(), doc.id)) // Pass doc.data() and doc.id
        .toList();
  } catch (e) {
    print("Error fetching expenses from Firestore: $e");
    return [];
  }
}


  Future<void> deleteExpenseFromFirestore(String expenseId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User is not authenticated");
      }

      final expenseDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('expenses')
          .doc(expenseId);

      await expenseDoc.delete();
    } catch (e) {
      print("Error deleting expense: $e");
      rethrow;
    }
  }

  Future<void> updateExpenseInFirestore(String expenseId, Expense updatedExpense) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User is not authenticated");
      }

      final expenseDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('expenses')
          .doc(expenseId);

      await expenseDoc.update(updatedExpense.toJson());
    } catch (e) {
      print("Error updating expense: $e");
      rethrow;
    }
  }

  Stream<List<Expense>> streamExpensesFromFirestore() {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return const Stream.empty();
  }

  final expenseCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('expenses');

  return expenseCollection.snapshots().map((snapshot) {
    return snapshot.docs
        .map((doc) => Expense.fromJson(doc.data(), doc.id)) // Pass doc.data() and doc.id
        .toList();
  });
}

}
