import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FinanceTransaction {
  final String id;
  final String date;
  final double amount;
  final String category;
  final String note;
  final int type;
  final Timestamp createdAt;

  FinanceTransaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.category,
    required this.note,
    required this.type,
    required this.createdAt,
  });

  factory FinanceTransaction.fromMap(Map<String, dynamic> map) {
    return FinanceTransaction(
      id: map['id'] ?? '',
      date: map['date'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      category: map['category'] ?? '',
      note: map['note'] ?? '',
      type: map['type'] ?? 0,
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  DateTime get parsedDate {
    try {
      return DateFormat('dd MMM yyyy').parse(date);
    } catch (e) {
      return DateTime.now();
    }
  }
}
