import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/friend_model.dart';
import '../widgets/custom_toast.dart';

class DostKhataScreen extends StatefulWidget {
  const DostKhataScreen({super.key});

  @override
  State<DostKhataScreen> createState() => _DostKhataScreenState();
}

class _DostKhataScreenState extends State<DostKhataScreen> {
  String _searchQuery = "";
  String _activeFilter = "Sabhi";
  FriendModel? _selectedFriend;
  bool _isProfileExpanded = false;
  final ScrollController _chatScrollController = ScrollController();

  late Box<FriendModel> _friendsBox;

  @override
  void initState() {
    super.initState();
    _friendsBox = Hive.box<FriendModel>('friends_box');
  }

  @override
  void dispose() {
    _chatScrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Parse different date formats safely to DateTime
  DateTime _parseTxDate(dynamic rawDate) {
    if (rawDate == null) return DateTime.fromMillisecondsSinceEpoch(0);
    if (rawDate is DateTime) return rawDate;
    final str = rawDate.toString().trim();
    final parsed = DateTime.tryParse(str);
    if (parsed != null) return parsed;

    // Handle "DD/MM HH:mm" or similar patterns fallback
    try {
      final parts = str.split(' ');
      if (parts.isNotEmpty && parts[0].contains('/')) {
        final dParts = parts[0].split('/');
        final day = int.tryParse(dParts[0]) ?? 1;
        final month = int.tryParse(dParts[1]) ?? 1;
        int hour = 0;
        int minute = 0;
        if (parts.length > 1 && parts[1].contains(':')) {
          final tParts = parts[1].split(':');
          hour = int.tryParse(tParts[0]) ?? 0;
          minute = int.tryParse(tParts[1]) ?? 0;
        }
        final now = DateTime.now();
        return DateTime(now.year, month, day, hour, minute);
      }
    } catch (_) {}
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  // 1. Action: Delete a single chat entry
  void _deleteChatTransaction(FriendModel friend, Map<dynamic, dynamic> targetTx) {
    final int amount = (targetTx["amount"] as num?)?.toInt() ?? 0;
    final String type = targetTx["type"] ?? "diya";
    final String txTitle = targetTx["title"] ?? "Entry";

    setState(() {
      friend.history.remove(targetTx);

      if (type == "diya") {
        friend.balance -= amount;
      } else if (type == "liya") {
        friend.balance += amount;
      }

      if (friend.balance > 0) {
        friend.type = "lena";
      } else if (friend.balance < 0) {
        friend.type = "dena";
      } else {
        friend.type = "settled";
      }

      if (friend.history.isNotEmpty) {
        friend.lastMessage = friend.history.last["title"] ?? "";
        friend.lastDate = friend.history.last["date"] ?? "";
      } else {
        friend.lastMessage = "Khata ready";
        friend.lastDate = "";
      }
    });

    friend.save();

    AppToast.show(
      context,
      title: "'$txTitle' delete kar diya gaya!",
      type: ToastType.error,
    );
  }

  // 2. 5-Second Timed Confirmation Dialog for Settle
  void _showTimedSettleConfirmation(FriendModel friend) {
    if (friend.balance == 0 || friend.type == "settled") {
      AppToast.show(
        context,
        title: "Hisaab pehle se chukta hai!",
        type: ToastType.warning,
      );
      return;
    }

    int remainingSeconds = 5;
    Timer? countdownTimer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            countdownTimer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
              if (remainingSeconds > 1) {
                setDialogState(() {
                  remainingSeconds--;
                });
              } else {
                setDialogState(() {
                  remainingSeconds = 0;
                });
                timer.cancel();
              }
            });

            const primaryColor = Color(0xFF9E3626);
            final isLena = friend.type == "lena";

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              title: Row(
                children: const [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFC62828), size: 24),
                  SizedBox(width: 8),
                  Text("Confirm Settle?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Kya aap sach mein ${friend.name} ka pura hisaab chukta (zero) karna chahte hain?",
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F5F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLena ? "Lena Banta Tha:" : "Dena Banta Tha:",
                          style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "₹${friend.balance}",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isLena ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    remainingSeconds > 0
                        ? "Galti se click hone se bachane ke liye $remainingSeconds second wait karein..."
                        : "Ab aap confirm button daba sakte hain.",
                    style: TextStyle(
                      fontSize: 11,
                      color: remainingSeconds > 0 ? primaryColor : Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    countdownTimer?.cancel();
                    Navigator.pop(ctx);
                  },
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: remainingSeconds == 0
                      ? () {
                          countdownTimer?.cancel();
                          Navigator.pop(ctx);
                          _executeAccountSettlement(friend);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    remainingSeconds > 0 ? "Wait (${remainingSeconds}s)" : "Confirm Chukta",
                    style: TextStyle(
                      color: remainingSeconds > 0 ? Colors.grey.shade600 : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 3. Settle Execute
  void _executeAccountSettlement(FriendModel friend) {
    final int settledAmount = friend.balance;
    final String prevType = friend.type;
    final now = DateTime.now();

    setState(() {
      friend.balance = 0;
      friend.type = 'settled';
      friend.lastMessage = "Hisaab pura settle kar diya";
      friend.lastDate = "Today";

      friend.history.add({
        "title": "Full Settlement (Hisaab Chukta)",
        "amount": settledAmount,
        "type": prevType == "lena" ? "liya" : "diya",
        "date": "${now.day}/${now.month} ${now.hour}:${now.minute.toString().padLeft(2, '0')}",
        "rawDate": now.toIso8601String(),
        "mode": "Settled",
      });
      _isProfileExpanded = false;
    });

    friend.save();
    _scrollToBottom();

    AppToast.show(
      context,
      title: "${friend.name} ka hisaab chukta ho gaya!",
      type: ToastType.success,
    );
  }

  // 4. Edit Friend Details
  void _openEditFriendDialog(FriendModel friend) {
    final nameCtrl = TextEditingController(text: friend.name);
    final phoneCtrl = TextEditingController(text: friend.phone);
    final descCtrl = TextEditingController(text: friend.desc);
    const primaryColor = Color(0xFF9E3626);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Khata Edit Karein", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Dost Ka Naam", prefixIcon: Icon(Icons.person, color: primaryColor)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: "Mobile Number", prefixIcon: Icon(Icons.phone, color: primaryColor)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: "Description / Note", prefixIcon: Icon(Icons.notes, color: primaryColor)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              setState(() {
                friend.name = nameCtrl.text.trim();
                friend.phone = phoneCtrl.text.trim();
                friend.desc = descCtrl.text.trim();
              });
              friend.save();
              Navigator.pop(ctx);
              AppToast.show(
                context,
                title: "${friend.name} ki details update ho gayi!",
                type: ToastType.success,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Save Changes", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 5. Delete Entire Friend Account
  void _confirmDeleteFriend(FriendModel friend) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Khata Delete Karein?", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC62828), fontSize: 16)),
        content: Text("Kya aap sach me '${friend.name}' ka pura khata aur statement delete karna chahte hain?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final deletedName = friend.name;
              setState(() {
                _selectedFriend = null;
                _isProfileExpanded = false;
              });
              friend.delete();
              Navigator.pop(ctx);
              AppToast.show(
                context,
                title: "$deletedName ka khata delete ho gaya!",
                type: ToastType.error,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Yes, Delete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF9E3626);
    const textDark = Color(0xFF1E1E1E);
    const cardColor = Colors.white;
    const textMuted = Color(0xFF7A7A7A);
    
    // =========================================================
    // VIEW 1: STATEMENT / CHAT VIEW (CHRONOLOGICAL ORDER)
    // =========================================================
    if (_selectedFriend != null) {
      final isLena = _selectedFriend!.type == "lena";
      final isSettled = _selectedFriend!.balance == 0 || _selectedFriend!.type == "settled";

      // Chronological sort: Sabse purana upar, sabse naya bottom me
      final List<Map<dynamic, dynamic>> sortedHistory = List.from(_selectedFriend!.history);
      sortedHistory.sort((a, b) {
        final dateA = _parseTxDate(a["rawDate"] ?? a["date"]);
        final dateB = _parseTxDate(b["rawDate"] ?? b["date"]);
        return dateA.compareTo(dateB);
      });

      _scrollToBottom();

      return Scaffold(
        backgroundColor: const Color(0xFFF9F5F0),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textDark, size: 18),
            onPressed: () {
              setState(() {
                _selectedFriend = null;
                _isProfileExpanded = false;
              });
            },
          ),
          titleSpacing: 0,
          title: InkWell(
            onTap: () => setState(() => _isProfileExpanded = !_isProfileExpanded),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: const Color(0xFFF3EBE1),
                  child: Text(
                    _selectedFriend!.name.isNotEmpty ? _selectedFriend!.name[0].toUpperCase() : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedFriend!.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textDark),
                      ),
                      Text(
                        _selectedFriend!.phone.isNotEmpty ? _selectedFriend!.phone : "Khata Contact",
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: AnimatedRotation(
                turns: _isProfileExpanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.keyboard_arrow_down_rounded, color: primaryColor, size: 26),
              ),
              onPressed: () => setState(() => _isProfileExpanded = !_isProfileExpanded),
            ),
          ],
        ),
        body: Column(
          children: [
            // Expandable Action Box (Includes Settle, Edit & Delete)
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 220),
              crossFadeState: _isProfileExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _selectedFriend!.desc.isNotEmpty ? _selectedFriend!.desc : "No description added",
                            style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Total Transactions: ${sortedHistory.length} records",
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),

                    // Settle Button inside expand section
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isSettled ? null : () => _showTimedSettleConfirmation(_selectedFriend!),
                        icon: const Icon(Icons.verified_outlined, size: 16, color: Colors.white),
                        label: Text(
                          isSettled ? "Hisaab Already Chukta Hai" : "Hisaab Settle Karein (Chukta)",
                          style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSettled ? Colors.grey : primaryColor,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _openEditFriendDialog(_selectedFriend!),
                            icon: const Icon(Icons.edit_outlined, size: 15, color: primaryColor),
                            label: const Text("Edit Khata", style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: primaryColor.withValues(alpha: 0.4)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _confirmDeleteFriend(_selectedFriend!),
                            icon: const Icon(Icons.delete_outline_rounded, size: 15, color: Color(0xFFC62828)),
                            label: const Text("Delete Khata", style: TextStyle(fontSize: 12, color: Color(0xFFC62828), fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: const Color(0xFFC62828).withValues(alpha: 0.4)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Top Clean Balance Strip
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSettled ? "STATUS" : (isLena ? "NET LENA HAI" : "NET DENA HAI"),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isSettled ? "₹0 (Chukta)" : "₹${_selectedFriend!.balance}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isSettled
                              ? Colors.grey
                              : (isLena ? const Color(0xFF2E7D32) : const Color(0xFFC62828)),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F5F0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isSettled ? "Settled" : (isLena ? "Pending In" : "Pending Out"),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSettled ? Colors.grey : (isLena ? const Color(0xFF2E7D32) : const Color(0xFFC62828)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEFE9E2)),

            // Transactions Statement Flow (Old at Top -> New at Bottom)
            Expanded(
              child: sortedHistory.isEmpty
                  ? const Center(child: Text("Is dost ka koi hisaab nahi hai.", style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      controller: _chatScrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
                      itemCount: sortedHistory.length,
                      itemBuilder: (ctx, index) {
                        final tx = sortedHistory[index];
                        final isDiya = tx["type"] == "diya";

                        return Dismissible(
                          key: ValueKey("chat_tx_${index}_${tx['title']}_${tx['date']}_${tx['amount']}"),
                          direction: isDiya ? DismissDirection.endToStart : DismissDirection.startToEnd,
                          background: Container(
                            alignment: isDiya ? Alignment.centerRight : Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC62828),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.delete_outline, color: Colors.white, size: 20),
                                const SizedBox(width: 4),
                                const Text("Delete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog<bool>(
                              context: context,
                              builder: (dCtx) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                title: const Text("Entry Delete Karein?", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                content: Text("Kya aap sach me '${tx['title']}' (₹${tx['amount']}) ki entry delete karna chahte hain?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dCtx, false),
                                    child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.pop(dCtx, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFC62828),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    child: const Text("Delete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          },
                          onDismissed: (direction) {
                            _deleteChatTransaction(_selectedFriend!, tx);
                          },
                          child: Align(
                            alignment: isDiya ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDiya ? const Color(0xFFE8F5E9) : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isDiya ? 16 : 4),
                                  bottomRight: Radius.circular(isDiya ? 4 : 16),
                                ),
                                border: Border.all(
                                  color: isDiya ? const Color(0xFFC8E6C9) : Colors.grey.shade300,
                                ),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        isDiya ? "+₹${tx['amount']} (Diya)" : "-₹${tx['amount']} (Liya)",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color: isDiya ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                                        ),
                                      ),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.04),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          tx["mode"] ?? "UPI",
                                          style: const TextStyle(fontSize: 9, color: Colors.black54),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    tx["title"] ?? "Hisaab",
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textDark),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    tx["date"] ?? "",
                                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    }
// =========================================================
    // VIEW 2: ALL FRIENDS LIST (LIVE FROM HIVE)
    // =========================================================
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
                  ],
                ),
                child: Row(
                  children: [
                    const Text(
                      "HISAAB+",
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(width: 1, height: 20, color: Colors.grey.shade300),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: const TextStyle(fontSize: 13, color: textDark),
                        decoration: const InputDecoration(
                          hintText: "Dost ka naam ya hisaab search...",
                          hintStyle: TextStyle(fontSize: 12, color: textMuted),
                          icon: Icon(Icons.search_rounded, size: 19, color: Colors.grey),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: ["Sabhi", "Lena Hai", "Dena Hai"].map((filter) {
                    final isSelected = _activeFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: isSelected,
                        selectedColor: const Color(0xFFF3EBE1),
                        labelStyle: TextStyle(
                          fontSize: 11,
                          color: isSelected ? primaryColor : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (val) => setState(() => _activeFilter = filter),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            Expanded(
              child: ValueListenableBuilder<Box<FriendModel>>(
                valueListenable: _friendsBox.listenable(),
                builder: (context, box, _) {
                  final allFriends = box.values.toList();

                  final filteredList = allFriends.where((friend) {
                    final matchesSearch = friend.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        friend.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase());

                    if (!matchesSearch) return false;
                    if (_activeFilter == "Lena Hai") return friend.type == "lena";
                    if (_activeFilter == "Dena Hai") return friend.type == "dena";
                    return true;
                  }).toList();

                  if (filteredList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.people_outline, size: 44, color: Colors.grey),
                          SizedBox(height: 8),
                          Text("Koi khata nahi mila! Nayi entry se add karein.", style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
                    itemCount: filteredList.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      final isLena = item.type == "lena";
                      final isSettled = item.balance == 0 || item.type == "settled";

                      Color balanceColor;
                      String balanceText;
                      if (isSettled) {
                        balanceColor = Colors.grey;
                        balanceText = "₹0 (Chukta)";
                      } else if (isLena) {
                        balanceColor = const Color(0xFF2E7D32);
                        balanceText = "+₹${item.balance}";
                      } else {
                        balanceColor = const Color(0xFFC62828);
                        balanceText = "-₹${item.balance}";
                      }

                      return InkWell(
                        onTap: () => setState(() => _selectedFriend = item),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: const Color(0xFFF3EBE1),
                                child: Text(
                                  item.name.isNotEmpty ? item.name[0].toUpperCase() : '?',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 16),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textDark),
                                        ),
                                        Text(
                                          item.lastDate.isNotEmpty ? item.lastDate : "Recently",
                                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.lastMessage.isNotEmpty ? item.lastMessage : (item.desc.isNotEmpty ? item.desc : "Khata ready"),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 11, color: Colors.black54),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          balanceText,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: balanceColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
    
}