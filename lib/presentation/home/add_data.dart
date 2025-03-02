import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:finance_monitor/presentation/home/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddDataScreen extends StatefulWidget {
  const AddDataScreen({super.key});

  @override
  State<AddDataScreen> createState() => _AddDataScreenState();
}

class _AddDataScreenState extends State<AddDataScreen> {
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
            homeVM.dateController.text =
                DateFormat('dd MMM yyyy').format(DateTime.now());
            return Form(
              key: homeVM.formKey,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(Icons.arrow_back)),
                        const SizedBox(
                          width: 20,
                        ),
                        Text(
                          homeVM.selectedValue == 0 ? 'Expense' : 'Income',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          _incomeExpenseButtons(homeVM),
                          const SizedBox(
                            height: 20,
                          ),
                          _dateSelect(context, homeVM),
                          const SizedBox(
                            height: 20,
                          ),
                          _amountWidget(homeVM),
                          const SizedBox(
                            height: 20,
                          ),
                          _categoryWidget(homeVM),
                          const SizedBox(
                            height: 20,
                          ),
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
        bottomNavigationBar:
            Consumer<HomeViewModel>(builder: (context, homeVM, child) {
          return Container(
            color: Colors.white,
            height: 80,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: ElevatedButton(
                style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    Colors.blue,
                  ),
                ),
                onPressed: () async {
                  if (homeVM.formKey.currentState!.validate()) {
                    await homeVM.saveData();
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _categoryWidget(HomeViewModel homeVM) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const SizedBox(
          width: 100,
          child: Text(
            'Category',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
        Expanded(
          child: DropdownButtonFormField2<String>(
            isExpanded: true,
            items: homeVM.selectedValue == 0
                ? homeVM.expenseCategories
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                    .toList()
                : homeVM.incomeCategories
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    )
                    .toList(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select category';
              }
              return null;
            },
            onChanged: (value) {
              homeVM.categoryValue = value.toString();
              homeVM.categoryController.text = value.toString();
            },
            onSaved: (value) {
              homeVM.categoryValue = value.toString();
              homeVM.categoryController.text = value.toString();
            },
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.only(right: 8),
            ),
            iconStyleData: const IconStyleData(
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.transparent,
              ),
              iconSize: 24,
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              padding: EdgeInsets.symmetric(horizontal: 16),
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
