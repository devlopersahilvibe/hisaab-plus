import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/friend_model.dart';
import '../widgets/custom_toast.dart';

class EntryFormView extends StatefulWidget {
  final int entryType;
  final VoidCallback onClose;
  const EntryFormView({super.key, required this.entryType, required this.onClose});

  @override
  State<EntryFormView> createState() => _EntryFormViewState();
}

class _EntryFormViewState extends State<EntryFormView> {
  late int _selectedType;
  String _paymentMode = "Online UPI";

  final _amountController = TextEditingController();
  final _friendController = TextEditingController();
  final _descController = TextEditingController();

  late Box<FriendModel> _friendsBox;
  late Box<TransactionModel> _transBox;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.entryType;
    _friendsBox = Hive.box<FriendModel>('friends_box');
    _transBox = Hive.box<TransactionModel>('transactions_box');
  }

  @override
  void didUpdateWidget(covariant EntryFormView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entryType != widget.entryType) {
      setState(() {
        _selectedType = widget.entryType;
      });
    }
  }

  void _addQuickAmount(int val) {
    int current = int.tryParse(_amountController.text) ?? 0;
    setState(() {
      _amountController.text = (current + val).toString();
    });
  }

  // -----------------------------------------------------------
  // 1. NAYA DOST HIVE BOX MEIN SAVE KARNA
  // -----------------------------------------------------------
  void _openCreateFriendSheet() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        const primaryColor = Color(0xFF9E3626);
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "Naya Dost Ka Khata Banayein",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: "Dost Ka Naam *",
                      prefixIcon: const Icon(Icons.person, color: primaryColor),
                      filled: true,
                      fillColor: const Color(0xFFF9F5F0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Mobile Number",
                      prefixIcon: const Icon(Icons.phone_android_rounded, color: primaryColor),
                      filled: true,
                      fillColor: const Color(0xFFF9F5F0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: noteCtrl,
                    decoration: InputDecoration(
                      labelText: "Description (e.g. Roommate, College Dost)",
                      prefixIcon: const Icon(Icons.notes_rounded, color: primaryColor),
                      filled: true,
                      fillColor: const Color(0xFFF9F5F0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        if (name.isEmpty) {
                          AppToast.show(
                            context,
                            title: "Dost ka naam dalna zaroori hai!",
                            type: ToastType.warning,
                          );
                          return;
                        }

                        // Hive 'friends_box' mein permanent store
                        final newFriend = FriendModel(
                          name: name,
                          phone: phoneCtrl.text.trim(),
                          desc: noteCtrl.text.trim().isEmpty ? "Friend" : noteCtrl.text.trim(),
                          balance: 0,
                          type: "settled",
                        );
                        _friendsBox.add(newFriend);

                        setState(() {
                          _friendController.text = name;
                        });
                        Navigator.pop(ctx);
                        AppToast.show(
                          context,
                          title: "$name ka khata create ho gaya!",
                          type: ToastType.success,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text("Save & Select Khata", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // -----------------------------------------------------------
  // 2. ENTRY FORM DATA HIVE MEIN SAVE KARNA + FRIEND BALANCE UPDATE
  // -----------------------------------------------------------
  void _saveHisaab() {
    final int amount = int.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) {
      AppToast.show(
        context,
        title: "Kripya sahi amount daalein!",
        type: ToastType.warning,
      );
      return;
    }

    String finalTitle = "";
    int iconCode = Icons.receipt_long.codePoint;
    String typeStr = "kharcha";

    if (_selectedType == 0) {
      typeStr = "kharcha";
      finalTitle = _descController.text.trim().isEmpty ? "Personal Kharcha" : _descController.text.trim();
      iconCode = Icons.receipt_long.codePoint;
    } else {
      final friendName = _friendController.text.trim();
      if (friendName.isEmpty) {
        AppToast.show(
          context,
          title: "Dost ka naam select ya type karein!",
          type: ToastType.warning,
        );
        return;
      }

      finalTitle = friendName;
      if (_selectedType == 1) {
        typeStr = "lena"; // Diya -> Lena banta hai
        iconCode = Icons.arrow_upward_rounded.codePoint;
      } else {
        typeStr = "dena"; // Liya -> Dena banta hai
        iconCode = Icons.arrow_downward_rounded.codePoint;
      }

      // Friend box update: Dost ka balance calculate karein
      FriendModel? existingFriend;
      try {
        existingFriend = _friendsBox.values.firstWhere(
          (f) => f.name.toLowerCase() == friendName.toLowerCase(),
        );
      } catch (_) {
        existingFriend = null;
      }

      // Agar dost pehle se list me nahi tha, toh auto-create ho jaye
      if (existingFriend == null) {
        existingFriend = FriendModel(
          name: friendName,
          phone: "",
          desc: "Friend",
          balance: amount,
          type: typeStr,
          lastMessage: _descController.text.trim().isEmpty ? "Hisaab Added" : _descController.text.trim(),
          lastDate: "Today",
        );
        existingFriend.history.add({
          "title": _descController.text.trim().isEmpty ? "Hisaab" : _descController.text.trim(),
          "amount": amount,
          "type": _selectedType == 1 ? "diya" : "liya",
          "date": "${DateTime.now().day}/${DateTime.now().month} ${DateTime.now().hour}:${DateTime.now().minute}",
          "mode": _paymentMode,
        });
        _friendsBox.add(existingFriend);
      } else {
        // Purane dost ka running balance adjust karein
        int net = existingFriend.type == 'lena'
            ? existingFriend.balance
            : (existingFriend.type == 'dena' ? -existingFriend.balance : 0);

        if (_selectedType == 1) {
          net += amount; // Diya
        } else {
          net -= amount; // Liya
        }

        if (net > 0) {
          existingFriend.balance = net;
          existingFriend.type = 'lena';
        } else if (net < 0) {
          existingFriend.balance = net.abs();
          existingFriend.type = 'dena';
        } else {
          existingFriend.balance = 0;
          existingFriend.type = 'settled';
        }

        existingFriend.lastMessage = _descController.text.trim().isEmpty ? "Hisaab Updated" : _descController.text.trim();
        existingFriend.lastDate = "Today";
        existingFriend.history.insert(0, {
          "title": _descController.text.trim().isEmpty ? "Hisaab" : _descController.text.trim(),
          "amount": amount,
          "type": _selectedType == 1 ? "diya" : "liya",
          "date": "${DateTime.now().day}/${DateTime.now().month} ${DateTime.now().hour}:${DateTime.now().minute}",
          "mode": _paymentMode,
        });
        existingFriend.save();
      }
    }

    // Transactions box mein add karein
    final tx = TransactionModel(
      date: DateTime.now(),
      title: finalTitle,
      subtitle: _descController.text.trim().isEmpty ? _paymentMode : "${_descController.text.trim()} • $_paymentMode",
      amount: amount,
      iconCodePoint: iconCode,
      type: typeStr,
      mode: _paymentMode,
    );

    _transBox.add(tx);

    // Form reset aur exit
    _amountController.clear();
    _friendController.clear();
    _descController.clear();
    FocusScope.of(context).unfocus();

    AppToast.show(
      context,
      title: "Hisaab offline memory mein save ho gaya!",
      type: ToastType.success,
    );

    widget.onClose();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _friendController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF9E3626);
    const textDark = Color(0xFF1E1E1E);

    String pageTitle = _selectedType == 0
        ? "Personal Kharcha"
        : (_selectedType == 1 ? "Dost ko Udhar Diya (+)" : "Dost se Udhar Liya (-)");

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textDark, size: 18),
          onPressed: widget.onClose,
        ),
        title: Text(pageTitle, style: const TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type Switcher
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      _buildPageTypeTab("Kharcha", 0),
                      _buildPageTypeTab("Diya (+)", 1),
                      _buildPageTypeTab("Liya (-)", 2),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Amount Box
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("₹", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor)),
                      const SizedBox(width: 8),
                      IntrinsicWidth(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: textDark),
                          decoration: const InputDecoration(hintText: "0", border: InputBorder.none, isDense: true),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Quick Increment Chips
                Row(
                  children: [
                    _buildQuickChip("+₹50", () => _addQuickAmount(50)),
                    _buildQuickChip("+₹100", () => _addQuickAmount(100)),
                    _buildQuickChip("+₹200", () => _addQuickAmount(200)),
                    _buildQuickChip("+₹500", () => _addQuickAmount(500)),
                  ],
                ),
                const SizedBox(height: 14),

                // Dost Selection & Real-Time Hive Friends Cards
                if (_selectedType != 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: TextField(
                      controller: _friendController,
                      onChanged: (val) => setState(() {}),
                      decoration: InputDecoration(
                        icon: const Icon(Icons.person_outline, color: primaryColor, size: 20),
                        labelText: "Dost Ka Naam",
                        hintText: "Type karein ya niche tap karein...",
                        border: InputBorder.none,
                        suffixIcon: _friendController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  _friendController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ValueListenableBuilder: Real-Time Live Friends Cards
                  ValueListenableBuilder<Box<FriendModel>>(
                    valueListenable: _friendsBox.listenable(),
                    builder: (context, box, _) {
                      final currentInput = _friendController.text.trim().toLowerCase();
                      List<FriendModel> visibleFriends = box.values.toList();

                      if (currentInput.isNotEmpty) {
                        visibleFriends = visibleFriends.where((f) => f.name.toLowerCase().contains(currentInput)).toList();
                      }

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            // "+ Naya Khata" Button
                            GestureDetector(
                              onTap: _openCreateFriendSheet,
                              child: Container(
                                width: 84,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3EBE1),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: primaryColor.withValues(alpha: 0.3), width: 1.2),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    CircleAvatar(
                                      radius: 17,
                                      backgroundColor: primaryColor,
                                      child: Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 17),
                                    ),
                                    SizedBox(height: 6),
                                    Text("+ Naya", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor)),
                                    Text("Khata", style: TextStyle(fontSize: 9, color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ),

                            // Real Live Cards from Hive
                            ...visibleFriends.map((f) {
                              final name = f.name;
                              final isSelected = _friendController.text.trim().toLowerCase() == name.toLowerCase();
                              final balance = f.balance;
                              final balanceType = f.type;

                              Color balanceColor;
                              String balanceText;
                              if (balance == 0) {
                                balanceColor = Colors.grey;
                                balanceText = "₹0";
                              } else if (balanceType == "lena") {
                                balanceColor = const Color(0xFF2E7D32);
                                balanceText = "+₹$balance";
                              } else {
                                balanceColor = const Color(0xFFC62828);
                                balanceText = "-₹$balance";
                              }

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _friendController.text = name;
                                  });
                                },
                                child: Container(
                                  width: 88,
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFFF3EBE1) : Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: isSelected ? primaryColor : Colors.grey.shade200,
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: isSelected ? primaryColor : const Color(0xFFEFEFEF),
                                        child: Text(
                                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isSelected ? Colors.white : primaryColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                          color: textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        balanceText,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: balanceColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],

                // Reason Field
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: TextField(
                    controller: _descController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.edit_note, color: primaryColor, size: 22),
                      labelText: "Kis Kaam Ke Liye? (Reason)",
                      hintText: "e.g. Dinner bill, Petrol split",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Payment Mode Selection
                const Text(
                  "Kaise Diya / Liya (Mode):",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textDark),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: ["Online UPI", "Cash", "Card / ATM"].map((mode) {
                    final isSelected = _paymentMode == mode;
                    return ChoiceChip(
                      label: Text(mode, style: const TextStyle(fontSize: 11)),
                      selected: isSelected,
                      selectedColor: primaryColor,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : textDark, fontWeight: FontWeight.bold),
                      onSelected: (val) => setState(() => _paymentMode = mode),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Save Button (Calling _saveHisaab)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _saveHisaab,
                    icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                    label: const Text(
                      "Save Hisaab",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageTypeTab(String label, int index) {
    final isSelected = _selectedType == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF9E3626) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickChip(String text, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
            ),
          ),
        ),
      ),
    );
  }
}