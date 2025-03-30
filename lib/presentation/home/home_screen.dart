import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_monitor/presentation/home/home_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:finance_monitor/core/shared_preference.dart';
import 'package:finance_monitor/presentation/auth/auth_service.dart';
import 'package:finance_monitor/presentation/auth/login_screen.dart';
import 'package:finance_monitor/presentation/home/add_data.dart';
import 'package:finance_monitor/presentation/home/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  final ScrollController _scrollController = ScrollController();
  DateTime _selectedMonth = DateTime.now();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + delta, 1);
    });
  }

  Future<void> _selectMonth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null && picked != _selectedMonth) {
      setState(() {
        _selectedMonth = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Finance Monitor'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _selectMonth,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          _buildMonthSelector(),
          _buildMonthlySummary(),
          const Divider(height: 1),
          Expanded(child: _buildTransactionList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final homeVM = Provider.of<HomeViewModel>(context, listen: false);
          homeVM.clearFields();
          _navigateToAddData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => _changeMonth(-1),
          ),
          Text(
            DateFormat('MMMM yyyy').format(_selectedMonth),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummary() {
    return StreamBuilder<List<FinanceTransaction>>(
      stream: Provider.of<HomeViewModel>(context).getUserTransactions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox();
        }

        final transactions = snapshot.data!;
        double income = 0;
        double expense = 0;

        for (var transaction in transactions) {
          final date = DateFormat('dd MMM yyyy').parse(transaction.date);
          if (date.month == _selectedMonth.month &&
              date.year == _selectedMonth.year) {
            if (transaction.type == 1) {
              income += transaction.amount;
            } else {
              expense += transaction.amount;
            }
          }
        }

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Income Card
              Expanded(
                child: Card(
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        const Text(
                          'Income',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${income.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Expense Card
              Expanded(
                child: Card(
                  color: Colors.red[50],
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        const Text(
                          'Expense',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${expense.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionList() {
    return StreamBuilder<List<FinanceTransaction>>(
      stream: Provider.of<HomeViewModel>(context).getUserTransactions(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No transactions for ${DateFormat('MMMM yyyy').format(_selectedMonth)}',
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _navigateToAddData,
                  child: const Text('Add New Transaction'),
                ),
              ],
            ),
          );
        }

        // Filter transactions by selected month
        final allTransactions = snapshot.data!;
        final filteredTransactions = allTransactions.where((transaction) {
          final date = DateFormat('dd MMM yyyy').parse(transaction.date);
          return date.month == _selectedMonth.month &&
              date.year == _selectedMonth.year;
        }).toList();

        if (filteredTransactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No transactions for ${DateFormat('MMMM yyyy').format(_selectedMonth)}',
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _navigateToAddData,
                  child: const Text('Add New Transaction'),
                ),
              ],
            ),
          );
        }

        // Sort transactions by date (newest first)
        filteredTransactions.sort((a, b) {
          final dateA = DateFormat('dd MMM yyyy').parse(a.date);
          final dateB = DateFormat('dd MMM yyyy').parse(b.date);
          return dateB.compareTo(dateA);
        });

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: filteredTransactions.length,
            itemBuilder: (context, index) {
              final transaction = filteredTransactions[index];
              return _buildTransactionCard(transaction);
            },
          ),
        );
      },
    );
  }

  Widget _buildTransactionCard(FinanceTransaction transaction) {
    final isExpense = transaction.type == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    transaction.date,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '₹ ${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: isExpense ? Colors.red : Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Divider(thickness: 0.5),
              const SizedBox(height: 4),
              Row(
                children: [
                  Chip(
                    label: Text(transaction.category),
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      transaction.note,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _navigateToEditData(transaction),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteTransaction(transaction.id),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToEditData(FinanceTransaction transaction) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddDataScreen(transactionToEdit: transaction),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  Future<void> _deleteTransaction(String transactionId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content:
            const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await _firestore
            .collection('userTransactions')
            .doc(user.uid)
            .collection('entries')
            .doc(transactionId)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e')),
          );
        }
      }
    }
  }

  void _navigateToAddData() {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AddDataScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      await SharedPrefHelper.setLoginStatus(false);
      await _authService.signout();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }
}
