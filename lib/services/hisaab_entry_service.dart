import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/friend_model.dart';
import '../models/transaction_model.dart';

class HisaabEntryService {
  final Box<FriendModel> friendsBox;
  final Box<TransactionModel> transBox;

  HisaabEntryService({required this.friendsBox, required this.transBox});

  /// Naya friend save karke uska generated key return karega (Tag optional hai)
  dynamic addNewFriend({
    required String name,
    required String phone,
    required String note,
    required String tag,
  }) {
    final cleanNote = note.trim();
    final cleanTag = tag.trim();

    String finalDesc;
    if (cleanTag.isNotEmpty && cleanNote.isNotEmpty) {
      finalDesc = "$cleanNote • $cleanTag";
    } else if (cleanTag.isNotEmpty) {
      finalDesc = cleanTag;
    } else if (cleanNote.isNotEmpty) {
      finalDesc = cleanNote;
    } else {
      finalDesc = "Dost";
    }

    final newFriend = FriendModel(
      name: name.trim(),
      phone: phone.trim(),
      desc: finalDesc,
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
    if (selectedFriendKeys.isEmpty || totalAmount <= 0) return;

    final splitAmount = (totalAmount / selectedFriendKeys.length).round();
    final noteText = note.trim().isNotEmpty ? note.trim() : "Hisaab Entry";
    final now = DateTime.now();
    final dateStr =
        "${now.day}/${now.month} ${now.hour}:${now.minute.toString().padLeft(2, '0')}";

    for (var key in selectedFriendKeys) {
      final FriendModel? friend = friendsBox.get(key);
      if (friend == null) continue;

      if (txType == 'diya') {
        // Diya: Humne paise diye -> Humara lena banta hai (+ balance)
        if (friend.type == 'lena') {
          friend.balance += splitAmount;
        } else if (friend.type == 'dena') {
          if (friend.balance > splitAmount) {
            friend.balance -= splitAmount;
          } else if (friend.balance == splitAmount) {
            friend.balance = 0;
            friend.type = 'settled';
          } else {
            friend.balance = splitAmount - friend.balance;
            friend.type = 'lena';
          }
        } else {
          // settled or 0 balance
          friend.balance = splitAmount;
          friend.type = 'lena';
        }
      } else {
        // Liya: Humne paise liye -> Humara dena banta hai (- balance)
        if (friend.type == 'dena') {
          friend.balance += splitAmount;
        } else if (friend.type == 'lena') {
          if (friend.balance > splitAmount) {
            friend.balance -= splitAmount;
          } else if (friend.balance == splitAmount) {
            friend.balance = 0;
            friend.type = 'settled';
          } else {
            friend.balance = splitAmount - friend.balance;
            friend.type = 'dena';
          }
        } else {
          // settled or 0 balance
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

      // Main Ledger Transactions Box Record
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

  /// Self / Personal Kharcha save karne ke liye (Bina kisi dost ke direct ledger entry)
  void saveSelfKharcha({
    required String title,
    required int amount,
    required String category,
    required String paymentMode,
  }) {
    if (amount <= 0) return;
    final now = DateTime.now();

    transBox.add(
      TransactionModel(
        date: now,
        title: title.trim().isNotEmpty ? title.trim() : "Kharcha",
        subtitle: "$category • $paymentMode",
        amount: amount,
        iconCodePoint: Icons.receipt_long_rounded.codePoint,
        type: 'kharcha',
        mode: paymentMode,
      ),
    );
  }
}
