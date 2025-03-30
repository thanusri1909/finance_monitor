import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_monitor/presentation/home/transaction_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeViewModel extends ChangeNotifier {
  TextEditingController dateController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  List data = [];
  int selectedValue = 0;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  String categoryValue = '';
  final List<String> incomeCategories = [
    'Salary',
    'Bonus',
    'Allowance',
    'Petty cash',
    'Others'
  ];

  final List<String> expenseCategories = [
    'Food',
    'Grocery',
    'Health',
    'Education',
    'Transport',
    'Others'
  ];

  void updateSelectedValue(int value) {
    selectedValue = value;
    notifyListeners();
  }

  void clearFields() {
    dateController.clear();
    amountController.clear();
    noteController.clear();
    categoryController.clear();
    selectedValue = 0;
    categoryValue = '';
  }

  Future<void> saveData() async {
    var value = {
      'type': selectedValue,
      'date': dateController.text,
      'amount': amountController.text,
      'category': categoryController.text,
      'note': noteController.text,
    };
    data.add(value);
  }

  selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      dateController.text = DateFormat('dd MMM yyyy').format(pickedDate);
      notifyListeners();
    }
  }

  Future<void> addTransaction() async {
    final user = auth.currentUser;
    if (user == null) return;

    try {
      await firestore
          .collection('userTransactions')
          .doc(user.uid)
          .collection('entries')
          .add({
        'date': dateController.text,
        'amount': double.parse(amountController.text),
        'category': categoryController.text,
        'note': noteController.text,
        'type': selectedValue,
        'createdAt': FieldValue.serverTimestamp(),
      });
      clearFields();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      rethrow;
    }
  }

  Future<void> updateTransaction(String transactionId) async {
    final user = auth.currentUser;
    if (user == null) return;

    try {
      await firestore
          .collection('userTransactions')
          .doc(user.uid)
          .collection('entries')
          .doc(transactionId)
          .update({
        'date': dateController.text,
        'amount': double.parse(amountController.text),
        'category': categoryController.text,
        'note': noteController.text,
        'type': selectedValue,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      clearFields();
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      rethrow;
    }
  }

  Future<void> initializeForEdit(FinanceTransaction transaction) async {
    dateController.text = transaction.date;
    amountController.text = transaction.amount.toString();
    categoryController.text = transaction.category;
    noteController.text = transaction.note;
    selectedValue = transaction.type;
    // Ensure categoryValue matches one of the available categories
    final categories =
        transaction.type == 0 ? expenseCategories : incomeCategories;
    categoryValue = categories.contains(transaction.category)
        ? transaction.category
        : categories.first;
    notifyListeners();
  }

  Stream<List<FinanceTransaction>> getUserTransactions() {
    final user = auth.currentUser;
    if (user == null) return Stream.value([]);

    return firestore
        .collection('userTransactions')
        .doc(user.uid)
        .collection('entries')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FinanceTransaction.fromMap({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }
}
