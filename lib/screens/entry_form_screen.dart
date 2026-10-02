import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/friend_model.dart';
import '../models/transaction_model.dart';
import '../widgets/custom_toast.dart';

class EntryFormView extends StatefulWidget {
  final int entryType; // 0: Kharcha, 1: Diya, 2: Liya
  final VoidCallback onClose;

  const EntryFormView({
    super.key,
    required this.entryType,
    required this.onClose,
  });

  @override
  State<EntryFormView> createState() => _EntryFormViewState();
}

class _EntryFormViewState extends State<EntryFormView> {
  // Theme Palette (Exact Match to hisab_chat & HTML Mockup)
  static const Color bgOled = Color(0xFF000000);
  static const Color surfaceCard = Color(0xFF121415);
  static const Color surfaceSec = Color(0xFF18181B);
  static const Color surfaceHighlight = Color(0xFF202024);
  static const Color borderCustom = Color(0xFF242429);
  static const Color lenaGreen = Color(0xFF10B981);
  static const Color denaRed = Color(0xFFF43F5E);

  // Neutral Color Shades (Tailwind Neutral Palette Fix)
  static const Color neutral300 = Color(0xFFD4D4D8);
  static const Color neutral400 = Color(0xFFA1A1AA);
  static const Color neutral500 = Color(0xFF71717A);
  static const Color neutral600 = Color(0xFF52525B);

  late Box<FriendModel> _friendsBox;
  late Box<TransactionModel> _transBox;

  // Controllers
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();
  final TextEditingController _amountCtrl = TextEditingController();

  // Add Friend Form Controllers
  final TextEditingController _newFriendNameCtrl = TextEditingController();
  final TextEditingController _newFriendPhoneCtrl = TextEditingController();
  final TextEditingController _newFriendNoteCtrl = TextEditingController();

  // State Management
  String _activeFilter = 'all'; // 'all', 'lena', 'dena'
  String _txType = 'diya'; // 'diya' (Lena banta hai) or 'liya' (Dena banta hai)
  String _selectedPaymentMode = 'UPI';
  bool _isAddAccordionOpen = false;
  String _selectedTag = 'Roommate';

  final List<String> _tags = [
    'College',
    'Roommate',
    'Office',
    'Business',
    'Personal',
  ];
  final List<Map<String, dynamic>> _paymentOptions = [
    {'name': 'UPI', 'icon': Icons.account_balance_wallet_rounded},
    {'name': 'Cash', 'icon': Icons.payments_rounded},
    {'name': 'GPay', 'icon': Icons.contactless_rounded},
    {'name': 'PhonePe', 'icon': Icons.send_to_mobile_rounded},
    {'name': 'Bank Transfer', 'icon': Icons.account_balance_rounded},
  ];

  // Set of Selected Friend Keys in Hive
  final Set<dynamic> _selectedFriendKeys = {};

  @override
  void initState() {
    super.initState();
    _friendsBox = Hive.box<FriendModel>('friends_box');
    _transBox = Hive.box<TransactionModel>('transactions_box');

    if (widget.entryType == 2) {
      _txType = 'liya';
    } else {
      _txType = 'diya';
    }

    if (_friendsBox.isNotEmpty) {
      _selectedFriendKeys.add(_friendsBox.keyAt(0));
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _noteCtrl.dispose();
    _amountCtrl.dispose();
    _newFriendNameCtrl.dispose();
    _newFriendPhoneCtrl.dispose();
    _newFriendNoteCtrl.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  void _addNewFriend() {
    final name = _newFriendNameCtrl.text.trim();
    if (name.isEmpty) {
      AppToast.show(
        context,
        title: "Kripya dost ka naam likhein!",
        type: ToastType.warning,
      );
      return;
    }

    final newFriend = FriendModel(
      name: name,
      phone: _newFriendPhoneCtrl.text.trim(),
      desc: _newFriendNoteCtrl.text.trim().isNotEmpty
          ? "${_newFriendNoteCtrl.text.trim()} • $_selectedTag"
          : "Naya Dost • $_selectedTag",
      balance: 0,
      type: 'settled',
      lastMessage: "Khata Banaya gaya",
      lastDate: "Aaj",
    );

    final key = _friendsBox.add(newFriend);

    setState(() {
      _selectedFriendKeys.clear();
      _selectedFriendKeys.add(key);
      _newFriendNameCtrl.clear();
      _newFriendPhoneCtrl.clear();
      _newFriendNoteCtrl.clear();
      _isAddAccordionOpen = false;
    });

    AppToast.show(
      context,
      title: "$name ko list mein jod diya gaya!",
      type: ToastType.success,
    );
  }

  void _saveHisaabEntry() {
    final int amount = int.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amount <= 0) {
      AppToast.show(
        context,
        title: "Kripya valid amount darj karein!",
        type: ToastType.warning,
      );
      return;
    }

    if (_selectedFriendKeys.isEmpty) {
      AppToast.show(
        context,
        title: "Kripya kam se kam ek dost chunein!",
        type: ToastType.warning,
      );
      return;
    }

    final splitAmount = (amount / _selectedFriendKeys.length).round();
    final noteText = _noteCtrl.text.trim().isNotEmpty
        ? _noteCtrl.text.trim()
        : "Hisaab Entry";
    final now = DateTime.now();
    final dateStr =
        "${now.day}/${now.month} ${now.hour}:${now.minute.toString().padLeft(2, '0')}";

    for (var key in _selectedFriendKeys) {
      final FriendModel? friend = _friendsBox.get(key);
      if (friend == null) continue;

      if (_txType == 'diya') {
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

      friend.lastMessage = "$noteText via $_selectedPaymentMode";
      friend.lastDate = "Aaj";
      friend.history.add({
        "title": noteText,
        "amount": splitAmount,
        "type": _txType,
        "date": dateStr,
        "mode": _selectedPaymentMode,
      });

      friend.save();

      _transBox.add(
        TransactionModel(
          date: now,
          title: friend.name,
          subtitle: "$noteText • $_selectedPaymentMode",
          amount: splitAmount,
          iconCodePoint: _txType == 'diya'
              ? Icons.arrow_upward_rounded.codePoint
              : Icons.arrow_downward_rounded.codePoint,
          type: _txType == 'diya' ? 'lena' : 'dena',
          mode: _selectedPaymentMode,
        ),
      );
    }

    _amountCtrl.clear();
    _noteCtrl.clear();
    FocusScope.of(context).unfocus();

    AppToast.show(
      context,
      title: "₹$amount ka hisaab safalta se jod diya gaya!",
      type: ToastType.success,
    );

    widget.onClose();
  }

  void _showPaymentModeSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141416),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        side: BorderSide(color: borderCustom),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Payment Mode Chunein",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ..._paymentOptions.map((opt) {
                  final isSelected = _selectedPaymentMode == opt['name'];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 0,
                    ),
                    leading: Icon(
                      opt['icon'] as IconData,
                      color: isSelected ? lenaGreen : neutral300,
                      size: 20,
                    ),
                    title: Text(
                      opt['name'] as String,
                      style: TextStyle(
                        color: isSelected ? lenaGreen : Colors.white,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: lenaGreen,
                            size: 18,
                          )
                        : null,
                    onTap: () {
                      setState(
                        () => _selectedPaymentMode = opt['name'] as String,
                      );
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgOled,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ValueListenableBuilder<Box<FriendModel>>(
          valueListenable: _friendsBox.listenable(),
          builder: (context, box, _) {
            final allFriends = box.values.toList();
            final allKeys = box.keys.toList();

            final totalCount = allFriends.length;
            final lenaCount = allFriends
                .where((f) => f.type == 'lena' && f.balance > 0)
                .length;
            final denaCount = allFriends
                .where((f) => f.type == 'dena' && f.balance > 0)
                .length;

            final query = _searchCtrl.text.trim().toLowerCase();

            final List<MapEntry<dynamic, FriendModel>> filteredEntries = [];
            for (int i = 0; i < allFriends.length; i++) {
              final friend = allFriends[i];
              final key = allKeys[i];

              if (_activeFilter == 'lena' &&
                  (friend.type != 'lena' || friend.balance <= 0))
                continue;
              if (_activeFilter == 'dena' &&
                  (friend.type != 'dena' || friend.balance <= 0))
                continue;

              if (query.isNotEmpty) {
                final matchName = friend.name.toLowerCase().contains(query);
                final matchDesc = friend.desc.toLowerCase().contains(query);
                if (!matchName && !matchDesc) continue;
              }

              filteredEntries.add(MapEntry(key, friend));
            }

            final selectedCount = _selectedFriendKeys.length;
            String activeFriendName = "Koi dost select karein";
            String activeFriendBalance = "₹0.00";
            bool isPositiveBalance = true;

            if (selectedCount == 1) {
              final singleKey = _selectedFriendKeys.first;
              final FriendModel? f = _friendsBox.get(singleKey);
              if (f != null) {
                activeFriendName = f.name;
                final isLena = f.type == 'lena';
                isPositiveBalance = isLena;
                activeFriendBalance =
                    "${isLena ? '+₹' : '-₹'}${f.balance} ${isLena ? 'lena' : 'dena'}";
              }
            } else if (selectedCount > 1) {
              activeFriendName = "$selectedCount Dost Chune Hue";
              activeFriendBalance = "Group Entry";
            }

            return Column(
              children: [
                _buildTopNavigationHeader(selectedCount),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121415),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderCustom),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color: neutral500,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                onChanged: (val) => setState(() {}),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                                decoration: const InputDecoration(
                                  hintText: "Dost ka naam search karein...",
                                  hintStyle: TextStyle(
                                    color: neutral500,
                                    fontSize: 13,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                            if (_searchCtrl.text.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _searchCtrl.clear();
                                  setState(() {});
                                },
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: surfaceSec,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: borderCustom),
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 12,
                                    color: neutral400,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _buildFilterPill("all", "Sabhi ($totalCount)"),
                            const SizedBox(width: 8),
                            _buildFilterPill("lena", "Lena Hai ($lenaCount)"),
                            const SizedBox(width: 8),
                            _buildFilterPill("dena", "Dena Hai ($denaCount)"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    children: [
                      _buildAddFriendAccordion(),
                      const SizedBox(height: 10),
                      if (filteredEntries.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 36),
                          child: Center(
                            child: Text(
                              "Koi dost nahi mila",
                              style: TextStyle(color: neutral500, fontSize: 12),
                            ),
                          ),
                        )
                      else
                        ...filteredEntries.map((entry) {
                          final key = entry.key;
                          final friend = entry.value;
                          final isSelected = _selectedFriendKeys.contains(key);
                          return _buildFriendCard(key, friend, isSelected);
                        }),
                    ],
                  ),
                ),
                _buildBottomEntryDock(
                  activeFriendName: activeFriendName,
                  activeBalance: activeFriendBalance,
                  isPositive: isPositiveBalance,
                  selectedCount: selectedCount,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopNavigationHeader(int selectedCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: neutral400,
                  size: 18,
                ),
                onPressed: widget.onClose,
              ),
              const Text(
                "Choose Friends",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: selectedCount > 0 ? const Color(0xFF0F291C) : surfaceSec,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selectedCount > 0
                    ? const Color(0xFF00E676).withOpacity(0.4)
                    : borderCustom,
              ),
            ),
            child: Text(
              selectedCount == 1
                  ? "1 Selected"
                  : (selectedCount > 1
                        ? "$selectedCount Selected"
                        : "0 Selected"),
              style: TextStyle(
                color: selectedCount > 0 ? const Color(0xFF34D399) : neutral400,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String filterType, String label) {
    final isSelected = _activeFilter == filterType;
    Color textColor = neutral400;

    if (isSelected) {
      textColor = Colors.black;
    } else if (filterType == 'lena') {
      textColor = lenaGreen;
    } else if (filterType == 'dena') {
      textColor = const Color(0xFFFB7185);
    }

    return GestureDetector(
      onTap: () => setState(() => _activeFilter = filterType),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : surfaceSec,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.white : borderCustom),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildAddFriendAccordion() {
    return Container(
      decoration: BoxDecoration(
        color: surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: lenaGreen.withOpacity(0.45)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () =>
                setState(() => _isAddAccordionOpen = !_isAddAccordionOpen),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F291C),
                      shape: BoxShape.circle,
                      border: Border.all(color: lenaGreen.withOpacity(0.5)),
                    ),
                    child: const Icon(
                      Icons.person_add_rounded,
                      color: lenaGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Naya Dost Add Karein",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F291C),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: lenaGreen.withOpacity(0.4),
                                ),
                              ),
                              child: const Text(
                                "+ New",
                                style: TextStyle(
                                  color: Color(0xFF34D399),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "Naye dost ka hisaab jodne ke liye",
                          style: TextStyle(color: neutral400, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: surfaceSec,
                      shape: BoxShape.circle,
                      border: Border.all(color: borderCustom),
                    ),
                    child: Icon(
                      _isAddAccordionOpen
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: neutral300,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isAddAccordionOpen) ...[
            const Divider(height: 1, color: borderCustom),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Dost ka Naam *",
                    style: TextStyle(color: neutral400, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  _buildFormInput(
                    controller: _newFriendNameCtrl,
                    hint: "e.g. Amit Sharma",
                    icon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Mobile Number",
                    style: TextStyle(color: neutral400, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  _buildFormInput(
                    controller: _newFriendPhoneCtrl,
                    hint: "+91 98765 43210",
                    icon: Icons.call_outlined,
                    isPhone: true,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Description / Note",
                    style: TextStyle(color: neutral400, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  _buildFormInput(
                    controller: _newFriendNoteCtrl,
                    hint: "Dost ke baare me note (optional)",
                    icon: Icons.notes_rounded,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Tag Chunein",
                    style: TextStyle(color: neutral400, fontSize: 11),
                  ),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _tags.map((tag) {
                        final isSel = _selectedTag == tag;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTag = tag),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isSel
                                    ? const Color(0xFF0F291C)
                                    : surfaceSec,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSel
                                      ? lenaGreen.withOpacity(0.6)
                                      : borderCustom,
                                ),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  color: isSel
                                      ? const Color(0xFF34D399)
                                      : neutral300,
                                  fontSize: 11,
                                  fontWeight: isSel
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 38,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: borderCustom),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: surfaceSec,
                            ),
                            onPressed: () {
                              _newFriendNameCtrl.clear();
                              _newFriendPhoneCtrl.clear();
                              _newFriendNoteCtrl.clear();
                              setState(() => _isAddAccordionOpen = false);
                            },
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: neutral300, fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 38,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: lenaGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _addNewFriend,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Dost Save Karein",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.check_rounded,
                                  color: Colors.black,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPhone = false,
  }) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: surfaceSec,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCustom),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: neutral500,
            size: 17,
          ), // <-- Yahan se 'const' hata diya gaya hai
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: neutral500, fontSize: 12),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendCard(dynamic key, FriendModel friend, bool isSelected) {
    final isLena = friend.type == 'lena';
    final isSettled = friend.balance == 0 || friend.type == 'settled';

    final Color amountColor = isSettled
        ? neutral400
        : (isLena ? lenaGreen : denaRed);

    final String balanceLabel = isSettled
        ? "₹0 chukta"
        : (isLena ? "+₹${friend.balance} lena" : "-₹${friend.balance} dena");

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedFriendKeys.remove(key);
            } else {
              _selectedFriendKeys.add(key);
            }
          });
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0F1E16) : surfaceCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? lenaGreen.withOpacity(0.8) : borderCustom,
              width: isSelected ? 1.2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? const Color(0xFF0F291C) : surfaceSec,
                  border: Border.all(
                    color: isSelected
                        ? lenaGreen.withOpacity(0.5)
                        : borderCustom,
                  ),
                ),
                child: Center(
                  child: Text(
                    _getInitials(friend.name),
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF34D399) : neutral300,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      friend.desc.isNotEmpty
                          ? friend.desc
                          : (friend.lastMessage.isNotEmpty
                                ? friend.lastMessage
                                : "Khata ready"),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: neutral400, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "₹${friend.balance}.00",
                    style: TextStyle(
                      color: amountColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    balanceLabel,
                    style: TextStyle(
                      color: amountColor.withOpacity(0.85),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? lenaGreen : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? lenaGreen : neutral600,
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.black)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomEntryDock({
    required String activeFriendName,
    required String activeBalance,
    required bool isPositive,
    required int selectedCount,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: const BoxDecoration(
        color: bgOled,
        border: Border(top: BorderSide(color: borderCustom, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Status Row: Active Friend & Balance Pill
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 2, right: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Text(
                        "Chuna Hua Dost: ",
                        style: TextStyle(color: neutral400, fontSize: 12),
                      ),
                      Flexible(
                        child: Text(
                          activeFriendName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selectedCount > 0 ? lenaGreen : neutral400,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? const Color(0xFF0F291C)
                        : (selectedCount == 0
                              ? surfaceSec
                              : const Color(0xFF2B1015)),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isPositive
                          ? lenaGreen.withOpacity(0.4)
                          : (selectedCount == 0
                                ? borderCustom
                                : denaRed.withOpacity(0.4)),
                    ),
                  ),
                  child: Text(
                    activeBalance,
                    style: TextStyle(
                      color: isPositive
                          ? const Color(0xFF34D399)
                          : (selectedCount == 0
                                ? neutral400
                                : const Color(0xFFFB7185)),
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Row 1: Note Input & Embedded UPI Dropdown
          Container(
            height: 46,
            padding: const EdgeInsets.only(left: 12, right: 6),
            decoration: BoxDecoration(
              color: surfaceSec,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderCustom),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.edit_note_rounded,
                  color: neutral400,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _noteCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: "Hisaab ka note likhein (e.g. Chai, Udhaar)...",
                      hintStyle: TextStyle(color: neutral500, fontSize: 12.5),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _showPaymentModeSheet,
                  child: Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: surfaceHighlight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderCustom),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: lenaGreen,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _selectedPaymentMode,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: neutral400,
                          size: 15,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Row 2: Diya / Liya Segmented Switcher (Sleek Rounded Capsules)
          Container(
            height: 44,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: surfaceSec,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderCustom),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _txType = 'diya'),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _txType == 'diya'
                            ? const Color(0xFF0F291C)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: _txType == 'diya'
                            ? Border.all(
                                color: lenaGreen.withOpacity(0.6),
                                width: 1.1,
                              )
                            : Border.all(color: Colors.transparent),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_upward_rounded,
                              size: 16,
                              color: _txType == 'diya'
                                  ? const Color(0xFF34D399)
                                  : neutral400,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Diya",
                              style: TextStyle(
                                color: _txType == 'diya'
                                    ? const Color(0xFF34D399)
                                    : neutral400,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _txType = 'liya'),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _txType == 'liya'
                            ? const Color(0xFF2B1015)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: _txType == 'liya'
                            ? Border.all(
                                color: denaRed.withOpacity(0.6),
                                width: 1.1,
                              )
                            : Border.all(color: Colors.transparent),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_downward_rounded,
                              size: 16,
                              color: _txType == 'liya'
                                  ? const Color(0xFFFB7185)
                                  : neutral400,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Liya",
                              style: TextStyle(
                                color: _txType == 'liya'
                                    ? const Color(0xFFFB7185)
                                    : neutral400,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Row 3: Amount Field + Solid White Save Pill + Round Close Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Amount Input Pill
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: surfaceSec,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderCustom),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        "₹",
                        style: TextStyle(
                          color: lenaGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _amountCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          decoration: const InputDecoration(
                            hintText: "Amount",
                            hintStyle: TextStyle(
                              color: neutral500,
                              fontSize: 13.5,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Save Pill Button (Pure White, Bold Black Text)
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    elevation: 0,
                  ),
                  onPressed: _saveHisaabEntry,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.check_rounded, color: Colors.black, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Cancel / Reset Circular Button (Exact 48x48 Circle)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _amountCtrl.clear();
                    _noteCtrl.clear();
                    _selectedFriendKeys.clear();
                  });
                  AppToast.show(
                    context,
                    title: "Entry reset kar di gayi!",
                    type: ToastType.warning,
                  );
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: surfaceSec,
                    shape: BoxShape.circle,
                    border: Border.all(color: borderCustom),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.close_rounded,
                      color: neutral300,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // iOS Home Indicator Bar
          const SizedBox(height: 12),
          Container(
            width: 120,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}
