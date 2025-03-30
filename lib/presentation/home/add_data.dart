import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:finance_monitor/presentation/home/home_view_model.dart';
import 'package:finance_monitor/presentation/home/transaction_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddDataScreen extends StatefulWidget {
  final FinanceTransaction? transactionToEdit;

  const AddDataScreen({super.key, this.transactionToEdit});

  @override
  State<AddDataScreen> createState() => _AddDataScreenState();
}

class _AddDataScreenState extends State<AddDataScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.transactionToEdit != null) {
        final homeVM = Provider.of<HomeViewModel>(context, listen: false);
        homeVM.initializeForEdit(widget.transactionToEdit!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<HomeViewModel>(
          builder: (context, homeVM, child) {
            if (widget.transactionToEdit == null &&
                homeVM.dateController.text.isEmpty) {
              homeVM.dateController.text =
                  DateFormat('dd MMM yyyy').format(DateTime.now());
            }

            return Form(
              key: homeVM.formKey,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(Icons.arrow_back),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          homeVM.selectedValue == 0 ? 'Expense' : 'Income',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: Column(
                        children: [
                          _incomeExpenseButtons(homeVM),
                          const SizedBox(height: 20),
                          _dateSelect(context, homeVM),
                          const SizedBox(height: 20),
                          _amountWidget(homeVM),
                          const SizedBox(height: 20),
                          _categoryWidget(homeVM),
                          const SizedBox(height: 20),
                          _noteWidget(homeVM),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: Consumer<HomeViewModel>(
          builder: (context, homeVM, child) {
            return Container(
              color: Colors.white,
              height: 80,
              width: double.infinity,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: ElevatedButton(
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.blue),
                  ),
                  onPressed: () async {
                    if (homeVM.formKey.currentState!.validate()) {
                      if (widget.transactionToEdit != null) {
                        await homeVM
                            .updateTransaction(widget.transactionToEdit!.id);
                      } else {
                        await homeVM.saveData();
                        await homeVM.addTransaction();
                      }
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  child: Text(
                    widget.transactionToEdit != null ? 'Update' : 'Save',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _categoryWidget(HomeViewModel homeVM) {
    // Determine which categories to show based on income/expense selection
    final categories = homeVM.selectedValue == 0
        ? homeVM.expenseCategories
        : homeVM.incomeCategories;

    // Ensure the current value exists in the available categories
    // If not, default to null (shows the hint text)
    String? dropdownValue;
    if (homeVM.categoryValue.isNotEmpty &&
        categories.contains(homeVM.categoryValue)) {
      dropdownValue = homeVM.categoryValue;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const SizedBox(
          width: 100,
          child: Text(
            'Category',
            style: TextStyle(fontSize: 18),
          ),
        ),
        Expanded(
          child: DropdownButtonFormField2<String>(
            // This is what's displayed in the dropdown
            value: dropdownValue,
            hint: const Text(
              'Select Category',
              style: TextStyle(fontSize: 14),
            ),
            isExpanded: true,
            items: categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(
                  category,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select category';
              }
              return null;
            },
            onChanged: (String? newValue) {
              if (newValue != null) {
                homeVM.categoryValue = newValue;
                homeVM.categoryController.text = newValue;
                homeVM.notifyListeners();
              }
            },
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.only(right: 8),
              height: 40,
            ),
            iconStyleData: const IconStyleData(
              icon: Icon(Icons.arrow_drop_down),
              iconSize: 24,
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              padding: EdgeInsets.symmetric(horizontal: 16),
              height: 40,
            ),
          ),
        ),
      ],
    );
  }

  Row _noteWidget(HomeViewModel homeVM) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const SizedBox(
          width: 100,
          child: Text(
            'Note',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
        Expanded(
          child: TextFormField(
            controller: homeVM.noteController,
            keyboardType: TextInputType.multiline,
          ),
        ),
      ],
    );
  }

  Widget _amountWidget(HomeViewModel homeVM) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const SizedBox(
          width: 100,
          child: Text(
            'Amount',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
        Expanded(
          child: TextFormField(
            controller: homeVM.amountController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter amount';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _dateSelect(BuildContext context, HomeViewModel homeVM) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const SizedBox(
          width: 100,
          child: Text(
            'Date',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
        Expanded(
          child: TextFormField(
            controller: homeVM.dateController,
            readOnly: true,
            onTap: () => homeVM.selectDate(context),
          ),
        ),
      ],
    );
  }

  Widget _incomeExpenseButtons(HomeViewModel homeVM) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: () {
            homeVM.updateSelectedValue(0);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: homeVM.selectedValue == 0 ? Colors.blue : Colors.black38,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
              child: Text(
                'Expense',
                style: TextStyle(
                  fontSize: 16,
                  color:
                      homeVM.selectedValue == 0 ? Colors.blue : Colors.black38,
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            homeVM.updateSelectedValue(1);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: homeVM.selectedValue == 1 ? Colors.blue : Colors.black38,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
              child: Text(
                'Income',
                style: TextStyle(
                  fontSize: 16,
                  color:
                      homeVM.selectedValue == 1 ? Colors.blue : Colors.black38,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
