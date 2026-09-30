import 'package:hive/hive.dart';

// Ye generator file banayega
part 'friend_model.g.dart';

@HiveType(typeId: 1) // TransactionModel ki typeId: 0 thi, isliye iski typeId: 1 hogi
class FriendModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String phone;

  @HiveField(2)
  String desc;

  @HiveField(3)
  int balance;

  @HiveField(4)
  String type; // 'lena', 'dena', 'settled'

  @HiveField(5)
  String lastMessage;

  @HiveField(6)
  String lastDate;

  @HiveField(7)
  List<Map<dynamic, dynamic>> history;

  FriendModel({
    required this.name,
    required this.phone,
    required this.desc,
    required this.balance,
    required this.type,
    this.lastMessage = '',
    this.lastDate = '',
    List<Map<dynamic, dynamic>>? history,
  }) : history = history ?? [];
}
