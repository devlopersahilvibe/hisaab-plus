import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../models/friend_model.dart';
import '../services/drive_sync_service.dart';
import '../widgets/custom_toast.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _selectedDate;
  late List<DateTime> _calendarDays;
  String _homeSearchQuery = "";
  final ScrollController _calendarScrollController = ScrollController();

  late Box<TransactionModel> _transBox;
  late Box<FriendModel> _friendsBox;

  bool _isDriveWorking = false;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _selectedDate = today;

    _calendarDays = List.generate(10, (index) {
      return today.subtract(Duration(days: 9 - index));
    });

    _transBox = Hive.box<TransactionModel>('transactions_box');
    _friendsBox = Hive.box<FriendModel>('friends_box');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_calendarScrollController.hasClients) {
        _calendarScrollController.animateTo(
          _calendarScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _calendarScrollController.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getDayName(int weekday) {
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return days[weekday - 1];
  }

  // Naya Floating Toast message use kiya hai
  void _deleteTransaction(TransactionModel tx) {
    final title = tx.title;
    tx.delete();
    AppToast.show(
      context,
      title: "'$title' delete kar diya gaya!",
      type: ToastType.error,
    );
  }

  Future<void> _handleUploadToDrive() async {
    setState(() => _isDriveWorking = true);
    AppToast.show(
      context,
      title: "Google Drive backup process chal raha hai...",
      type: ToastType.info,
    );

    final bool ok = await DriveSyncService.uploadDataToDrive();
    setState(() => _isDriveWorking = false);

    if (!mounted) return;
    AppToast.show(
      context,
      title: ok ? "Backup Drive par save ho gaya!" : "Backup cancel ho gaya ya fail hua.",
      type: ok ? ToastType.success : ToastType.error,
    );
  }

  Future<void> _handleSmartSyncDrive() async {
    setState(() => _isDriveWorking = true);
    AppToast.show(
      context,
      title: "Drive data sync shuru ho gaya...",
      type: ToastType.info,
    );

    final bool ok = await DriveSyncService.syncDataWithDrive();
    setState(() => _isDriveWorking = false);

    if (!mounted) return;
    AppToast.show(
      context,
      title: ok ? "Smart Sync complete! Data merge ho gaya." : "Sync cancel ho gaya ya fail hua.",
      type: ok ? ToastType.success : ToastType.error,
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF9E3626);
    const cardColor = Colors.white;
    const textDark = Color(0xFF1E1E1E);
    const textMuted = Color(0xFF7A7A7A);

    final isAllSelected = _selectedDate == null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Row 1: Logo & Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
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
                        onChanged: (val) => setState(() => _homeSearchQuery = val),
                        style: const TextStyle(fontSize: 13, color: textDark),
                        decoration: const InputDecoration(
                          hintText: "Search kharcha ya dost...",
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

            // Row 2: Calendar Strip
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 10),
              child: SingleChildScrollView(
                controller: _calendarScrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    ..._calendarDays.map((date) {
                      final isSelected = !isAllSelected && _isSameDay(date, _selectedDate!);
                      final isToday = _isSameDay(date, DateTime.now());

                      return GestureDetector(
                        onTap: () => setState(() => _selectedDate = date),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryColor : cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? primaryColor
                                  : (isToday ? primaryColor.withValues(alpha: 0.4) : Colors.grey.shade300),
                              width: 1.1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected ? primaryColor.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isToday ? "Today" : _getDayName(date.weekday),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white70 : textMuted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${date.day}",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    GestureDetector(
                      onTap: () => setState(() => _selectedDate = null),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(right: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isAllSelected ? primaryColor : cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isAllSelected ? primaryColor : Colors.grey.shade300,
                            width: 1.1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isAllSelected ? primaryColor.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "TOTAL",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isAllSelected ? Colors.white70 : textMuted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "ALL",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: isAllSelected ? Colors.white : textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content Body
            Expanded(
              child: ValueListenableBuilder<Box<TransactionModel>>(
                valueListenable: _transBox.listenable(),
                builder: (context, box, _) {
                  final allTx = box.values.toList();

                  final filteredTransactions = allTx.where((item) {
                    if (!isAllSelected) {
                      if (!_isSameDay(item.date, _selectedDate!)) {
                        return false;
                      }
                    }
                    if (_homeSearchQuery.isNotEmpty) {
                      final q = _homeSearchQuery.toLowerCase();
                      final t = item.title.toLowerCase();
                      final s = item.subtitle.toLowerCase();
                      return t.contains(q) || s.contains(q);
                    }
                    return true;
                  }).toList().reversed.toList();

                  int calcLena = 0;
                  int calcDena = 0;
                  for (var tx in allTx) {
                    if (isAllSelected || _isSameDay(tx.date, _selectedDate!)) {
                      if (tx.type == "lena") calcLena += tx.amount;
                      if (tx.type == "dena") calcDena += tx.amount;
                    }
                  }

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAllSelected
                              ? "Total Ledger (All Records Till Today)"
                              : (_isSameDay(_selectedDate!, DateTime.now())
                                  ? "Today's Ledger (${_selectedDate!.day} ${_getDayName(_selectedDate!.weekday)})"
                                  : "Hisaab: ${_selectedDate!.day} (${_getDayName(_selectedDate!.weekday)})"),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textMuted),
                        ),
                        const SizedBox(height: 10),

                        // Lena / Dena
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("LENA HAI", style: TextStyle(fontSize: 10, color: textMuted, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(
                                      calcLena > 0 ? "₹$calcLena" : "₹0",
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(isAllSelected ? "Overall pending lena" : "On this day", style: const TextStyle(fontSize: 10, color: textMuted)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("DENA HAI", style: TextStyle(fontSize: 10, color: textMuted, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text(
                                      calcDena > 0 ? "₹$calcDena" : "₹0",
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFC62828)),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(isAllSelected ? "Overall pending dena" : "On this day", style: const TextStyle(fontSize: 10, color: textMuted)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Google Drive Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFEFE9E2), width: 1.2),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 3)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3EBE1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.add_to_drive_rounded, color: primaryColor, size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          "Google Drive Cloud",
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark),
                                        ),
                                        Text(
                                          "Data surakshit rakhein ya doosre phone se sync karein",
                                          style: TextStyle(fontSize: 10, color: textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_isDriveWorking)
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _isDriveWorking ? null : _handleUploadToDrive,
                                      icon: const Icon(Icons.cloud_upload_outlined, size: 15, color: primaryColor),
                                      label: const Text(
                                        "Upload Backup",
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        side: BorderSide(color: primaryColor.withValues(alpha: 0.4)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _isDriveWorking ? null : _handleSmartSyncDrive,
                                      icon: const Icon(Icons.sync_rounded, size: 15, color: Colors.white),
                                      label: const Text(
                                        "Sync (Merge)",
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF2E7D32),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Active Friends
                        ValueListenableBuilder<Box<FriendModel>>(
                          valueListenable: _friendsBox.listenable(),
                          builder: (context, fBox, _) {
                            final friendsList = fBox.values.where((f) => f.balance > 0).toList();
                            if (friendsList.isEmpty) return const SizedBox.shrink();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text("Active Dost", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark)),
                                    Text("All Khata >", style: TextStyle(fontSize: 11, color: primaryColor, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  child: Row(
                                    children: friendsList.map((f) {
                                      final isLena = f.type == "lena";
                                      return _buildFriendAvatar(
                                        f.name,
                                        "${isLena ? '+₹' : '-₹'}${f.balance}",
                                        isLena,
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(height: 22),
                              ],
                            );
                          },
                        ),

                        // Recent Transactions List
                        Text(
                          isAllSelected ? "Recent Transactions" : "Spends on ${_selectedDate!.day}",
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark),
                        ),
                        const SizedBox(height: 10),

                        if (filteredTransactions.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              children: const [
                                Icon(Icons.event_busy_rounded, size: 36, color: Colors.grey),
                                SizedBox(height: 8),
                                Text("Is tareekh ka koi kharcha nahi mila!", style: TextStyle(color: Colors.grey, fontSize: 13)),
                              ],
                            ),
                          )
                        else
                          ...filteredTransactions.map((tx) {
                            final isLena = tx.type == "lena";
                            final isDena = tx.type == "dena";
                            final sign = isLena ? "+₹" : "-₹";

                            return Dismissible(
                              key: Key(tx.key.toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC62828),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 22),
                                    SizedBox(width: 6),
                                    Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                return await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                    title: const Text("Kharcha Delete Karein?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    content: Text("Kya aap sach me '${tx.title}' (₹${tx.amount}) ko delete karna chahte hain?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(false),
                                        child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.of(ctx).pop(true),
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
                                _deleteTransaction(tx);
                              },
                              child: _buildExpenseTile(
                                tx.title,
                                tx.subtitle,
                                "$sign${tx.amount}",
                                IconData(tx.iconCodePoint, fontFamily: 'MaterialIcons'),
                                isLena
                                    ? const Color(0xFF2E7D32)
                                    : (isDena ? const Color(0xFFC62828) : textDark),
                              ),
                            );
                          }),

                        const SizedBox(height: 18),
                        _buildCompactDeveloperFooter(context),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildCompactDeveloperFooter(BuildContext context) {
    const textDark = Color(0xFF1E1E1E);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "DEVELOPED BY",
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Color(0xFF9E9E9E),
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 3),
            Text(
              "Sahil Sonwanshi",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: textDark,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildFriendAvatar(String name, String amount, bool isLenaHai) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFF3EBE1),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(color: Color(0xFF9E3626), fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(height: 5),
          Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(
            amount,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isLenaHai ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildExpenseTile(String title, String subtitle, String amount, IconData icon, Color amountColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFF9F5F0),
            child: Icon(icon, color: const Color(0xFF9E3626), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: amountColor),
          ),
        ],
      ),
    );
  }
}