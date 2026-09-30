import 'package:hive/hive.dart';

// Ye file auto-generate hogi agle step me
part 'transaction_model.g.dart';

@HiveType(typeId: 0) // Har model class ki unique typeId hoti hai
class TransactionModel extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String subtitle;

  @HiveField(3)
  final int amount;

  @HiveField(4)
  final int iconCodePoint; // IconData direct save nahi hoti, isliye codePoint store karte hain

  @HiveField(5)
  final String type; // 'kharcha', 'lena', 'dena'

  @HiveField(6)
  final String mode; // 'Online UPI', 'Cash'

  TransactionModel({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.iconCodePoint,
    required this.type,
    this.mode = 'Online UPI',
  });
}