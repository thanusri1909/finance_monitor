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
    notifyListeners();
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
}
