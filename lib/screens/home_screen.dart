import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/friend_model.dart';
import '../models/transaction_model.dart';
import '../widgets/custom_toast.dart';
import 'entry_form_screen.dart';
import 'hisab_chat.dart';
import 'khata_screen.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<int>? onTabChange;
  final VoidCallback? onOpenEntry;

  const HomeScreen({super.key, this.onTabChange, this.onOpenEntry});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // OLED Luxury Palette
  static const Color oledBg = Color(0xFF000000);
  static const Color cardSurface = Color(0xFF131315);
  static const Color cardSurfaceElevated = Color(0xFF1E1E22);
  static const Color greenAccent = Color(0xFF00E676);
  static const Color greenPillBg = Color(0xFF0B291A);
  static const Color redAccent = Color(0xFFFF5252);
  static const Color redPillBg = Color(0xFF2E1215);
  static const Color textMuted = Color(0xFF888890);
  static const Color textMutedDark = Color(0xFF55555C);

  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = "";

  late Box<TransactionModel> _transBox;
  late Box<FriendModel> _friendsBox;

  @override
  void initState() {
    super.initState();
    _transBox = Hive.box<TransactionModel>('transactions_box');
    _friendsBox = Hive.box<FriendModel>('friends_box');
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openChat(String name, int amount, bool isLena) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HisabChatScreen(
          friendName: name,
          netAmount: amount.toString(),
          isLena: isLena,
        ),
      ),
    );
  }

  void _openKhata() {
    if (widget.onTabChange != null) {
      widget.onTabChange!(1);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const DostKhataScreen()),
      );
    }
  }

  void _openNayaKharcha() {
    if (widget.onOpenEntry != null) {
      widget.onOpenEntry!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EntryFormView(
            entryType: 0,
            onClose: () => Navigator.pop(context),
          ),
        ),
      );
    }
  }

  void _deleteTransaction(TransactionModel tx) {
    final title = tx.title;
    tx.delete();
    AppToast.show(
      context,
      title: "'$title' record delete kar diya gaya!",
      type: ToastType.error,
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return "Aaj • ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    }
    return "${dt.day}/${dt.month}/${dt.year}";
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: oledBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Bar: Brand Title & Clickable Search Pill + 3-Dot Menu
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 14, left: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "HISAAB",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.1,
                            ),
                          ),
                          SizedBox(width: 3),
                          Text(
                            "+",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: greenAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: cardSurface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              size: 18,
                              color: textMuted,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchCtrl,
                                onChanged: (val) {
                                  setState(() {
                                    _searchQuery = val.trim();
                                  });
                                },
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                ),
                                decoration: InputDecoration(
                                  hintText: "Search dost, kharcha...",
                                  hintStyle: const TextStyle(
                                    color: textMuted,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  suffixIcon: _searchCtrl.text.isNotEmpty
                                      ? GestureDetector(
                                          onTap: () {
                                            _searchCtrl.clear();
                                            setState(() => _searchQuery = "");
                                          },
                                          child: const Icon(
                                            Icons.close_rounded,
                                            size: 16,
                                            color: textMuted,
                                          ),
                                        )
                                      : null,
                                  suffixIconConstraints: const BoxConstraints(
                                    minHeight: 18,
                                    minWidth: 18,
                                  ),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                "|",
                                style: TextStyle(
                                  color: textMutedDark,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Theme(
                              data: Theme.of(context)
                                  .copyWith(cardColor: const Color(0xFF1E1E22)),
                              child: PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert_rounded,
                                  size: 18,
                                  color: textMuted,
                                ),
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                onSelected: (value) {
                                  if (value == "settings") {
                                    AppToast.show(
                                      context,
                                      title: "Settings jald aa raha hai!",
                                      type: ToastType.info,
                                    );
                                  } else if (value == "sync") {
                                    AppToast.show(
                                      context,
                                      title: "Data phone storage me safe hai!",
                                      type: ToastType.success,
                                    );
                                  }
                                },
                                itemBuilder: (BuildContext context) => [
                                  const PopupMenuItem(
                                    value: "sync",
                                    height: 38,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.sync_rounded,
                                          size: 16,
                                          color: greenAccent,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "Sync State",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: "settings",
                                    height: 38,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.settings_outlined,
                                          size: 16,
                                          color: textMuted,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "Settings",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 2. Main Ledger Summary Card (Connected to Friends & Transactions Hive Box)
              ValueListenableBuilder(
                valueListenable: _friendsBox.listenable(),
                builder: (context, Box<FriendModel> fBox, _) {
                  int totalLena = 0;
                  int totalDena = 0;

                  for (var friend in fBox.values) {
                    if (friend.type == 'lena') {
                      totalLena += friend.balance;
                    } else if (friend.type == 'dena') {
                      totalDena += friend.balance;
                    }
                  }

                  // Aaj ka net calculation
                  final today = DateTime.now();
                  int todayLena = 0;
                  int todayDena = 0;

                  for (var tx in _transBox.values) {
                    if (tx.date.year == today.year &&
                        tx.date.month == today.month &&
                        tx.date.day == today.day) {
                      if (tx.type == 'lena') {
                        todayLena += tx.amount;
                      } else if (tx.type == 'dena') {
                        todayDena += tx.amount;
                      }
                    }
                  }

                  return Container(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                    decoration: BoxDecoration(
                      color: cardSurface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.04),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Lena Hai Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Lena Hai (Receivable)",
                              style: TextStyle(
                                color: textMuted,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "₹$totalLena",
                                  style: const TextStyle(
                                    color: greenAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: greenPillBg,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "+₹$todayLena aaj",
                                    style: const TextStyle(
                                      color: greenAccent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // Dena Hai Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Dena Hai (Payable)",
                              style: TextStyle(
                                color: textMuted,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  "₹$totalDena",
                                  style: const TextStyle(
                                    color: redAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: redPillBg,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "-₹$todayDena aaj",
                                    style: const TextStyle(
                                      color: redAccent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // Action Buttons (Khata & Naya Kharcha)
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: _openKhata,
                                borderRadius: BorderRadius.circular(26),
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: cardSurfaceElevated,
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Khata",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Icon(
                                        Icons.arrow_outward_rounded,
                                        size: 14,
                                        color: Colors.white70,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: _openNayaKharcha,
                                borderRadius: BorderRadius.circular(26),
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(26),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Naya Kharcha",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.add_rounded,
                                        size: 18,
                                        color: Colors.black,
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
                  );
                },
              ),

              const SizedBox(height: 14),

              // 3. Local Data Security Banner Card
              Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 16, 20),
                decoration: BoxDecoration(
                  color: cardSurface,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Offline Storage Surakshit",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Aapka sara hisaab aapke device me Hive database me surakshit hai.",
                            style: TextStyle(
                              color: textMuted,
                              fontSize: 11,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed: () {
                              AppToast.show(
                                context,
                                title: "Data phone storage me sync hai!",
                                type: ToastType.success,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 9,
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Backup Status",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    _buildCreativeSyncIcon(),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 4. Hisaab History Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Hisaab History",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  InkWell(
                    onTap: _openKhata,
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        children: [
                          Text(
                            "All Khata",
                            style: TextStyle(
                              color: textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 5. Reactive History Tiles Connected to transactions_box
              ValueListenableBuilder<Box<TransactionModel>>(
                valueListenable: _transBox.listenable(),
                builder: (context, box, _) {
                  final allTx = box.values.toList().reversed.toList();

                  final filtered = allTx.where((tx) {
                    if (_searchQuery.isEmpty) return true;
                    final q = _searchQuery.toLowerCase();
                    return tx.title.toLowerCase().contains(q) ||
                        tx.subtitle.toLowerCase().contains(q);
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 36),
                      child: Center(
                        child: Text(
                          "Abhi koi hisaab ya kharcha nahi hai",
                          style: TextStyle(color: textMuted, fontSize: 13),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final tx = filtered[index];
                      final isLena = tx.type == 'lena';
                      final isKharcha = tx.type == 'kharcha';

                      String status;
                      Color statusColor;

                      if (isKharcha) {
                        status = "Kharcha";
                        statusColor = textMuted;
                      } else if (isLena) {
                        status = "+₹${tx.amount} lena";
                        statusColor = greenAccent;
                      } else {
                        status = "-₹${tx.amount} dena";
                        statusColor = redAccent;
                      }

                      return Dismissible(
                        key: Key("${tx.date.millisecondsSinceEpoch}_$index"),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: redAccent,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.delete_sweep_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "Delete",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        confirmDismiss: (direction) async {
                          return await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: cardSurface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: const Text(
                                "Kharcha Delete Karein?",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              content: Text(
                                "Kya aap sach me '${tx.title}' (₹${tx.amount}) ko delete karna chahte hain?",
                                style: const TextStyle(color: textMuted),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(color: textMuted),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: redAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    "Delete",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) => _deleteTransaction(tx),
                        child: _buildHistoryTile(
                          initials: _getInitials(tx.title),
                          name: tx.title,
                          timeOrDesc:
                              "${_formatDate(tx.date)} • ${tx.subtitle}",
                          amount: "₹${tx.amount}",
                          status: status,
                          statusColor: statusColor,
                          onTap: () {
                            if (!isKharcha) {
                              _openChat(tx.title, tx.amount, isLena);
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreativeSyncIcon() {
    return Container(
      width: 76,
      height: 76,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.02),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            child: Icon(
              Icons.arrow_drop_up_rounded,
              color: Colors.white.withValues(alpha: 0.18),
              size: 16,
            ),
          ),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF18181C),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF222228),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1.2,
              ),
            ),
            child: const Center(
              child: Icon(Icons.shield_outlined, color: Colors.white, size: 21),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile({
    required String initials,
    required String name,
    required String timeOrDesc,
    required String amount,
    required String status,
    required Color statusColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1E1E22),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        timeOrDesc,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      amount,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
