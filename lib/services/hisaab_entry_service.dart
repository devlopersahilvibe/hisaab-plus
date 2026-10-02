import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/friend_model.dart';
import '../models/transaction_model.dart';

class HisaabEntryService {
  final Box<FriendModel> friendsBox;
  final Box<TransactionModel> transBox;

  HisaabEntryService({required this.friendsBox, required this.transBox});

  /// Naya friend save karke uska generated key return karega
  dynamic addNewFriend({
    required String name,
    required String phone,
    required String note,
    required String tag,
  }) {
    final newFriend = FriendModel(
      name: name,
      phone: phone,
      desc: note.isNotEmpty ? "$note • $tag" : "Naya Dost • $tag",
      balance: 0,
      type: 'settled',
      lastMessage: "Khata Banaya gaya",
      lastDate: "Aaj",
    );

    return friendsBox.add(newFriend);
  }

  /// Selected friends me amount split karke Friends aur Transactions Box me save karega
  void saveTransaction({
    required Set<dynamic> selectedFriendKeys,
    required int totalAmount,
    required String txType, // 'diya' ya 'liya'
    required String note,
    required String paymentMode,
  }) {
    final splitAmount = (totalAmount / selectedFriendKeys.length).round();
    final noteText = note.isNotEmpty ? note : "Hisaab Entry";
    final now = DateTime.now();
    final dateStr =
        "${now.day}/${now.month} ${now.hour}:${now.minute.toString().padLeft(2, '0')}";

    for (var key in selectedFriendKeys) {
      final FriendModel? friend = friendsBox.get(key);
      if (friend == null) continue;

      if (txType == 'diya') {
        if (friend.type == 'lena') {
          friend.balance += splitAmount;
        } else if (friend.type == 'dena') {
          if (friend.balance >= splitAmount) {
            friend.balance -= splitAmount;
          } else {
            friend.balance = splitAmount - friend.balance;
            friend.type = 'lena';
          }
        } else {
          friend.balance = splitAmount;
          friend.type = 'lena';
        }
      } else {
        if (friend.type == 'dena') {
          friend.balance += splitAmount;
        } else if (friend.type == 'lena') {
          if (friend.balance >= splitAmount) {
            friend.balance -= splitAmount;
          } else {
            friend.balance = splitAmount - friend.balance;
            friend.type = 'dena';
          }
        } else {
          friend.balance = splitAmount;
          friend.type = 'dena';
        }
      }

      friend.lastMessage = "$noteText via $paymentMode";
      friend.lastDate = "Aaj";
      friend.history.add({
        "title": noteText,
        "amount": splitAmount,
        "type": txType,
        "date": dateStr,
        "mode": paymentMode,
      });

      friend.save();

      // Main Ledger Box Record
      transBox.add(
        TransactionModel(
          date: now,
          title: friend.name,
          subtitle: "$noteText • $paymentMode",
          amount: splitAmount,
          iconCodePoint: txType == 'diya'
              ? Icons.arrow_upward_rounded.codePoint
              : Icons.arrow_downward_rounded.codePoint,
          type: txType == 'diya' ? 'lena' : 'dena',
          mode: paymentMode,
        ),
      );
    }
  }
}
