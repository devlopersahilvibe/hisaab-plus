import 'package:flutter/material.dart';

import '../widgets/custom_toast.dart';

class HisabChatScreen extends StatefulWidget {
  final String friendName;
  final String netAmount;
  final bool isLena;

  const HisabChatScreen({
    super.key,
    this.friendName = "Sahil",
    this.netAmount = "100",
    this.isLena = true,
  });

  @override
  State<HisabChatScreen> createState() => _HisabChatScreenState();
}

class _HisabChatScreenState extends State<HisabChatScreen> {
  // OLED Colors from Design
  static const Color oledBg = Color(0xFF000000);
  static const Color cardSurface = Color(0xFF131315);
  static const Color cardSurfaceLight = Color(0xFF1E1E22);
  static const Color greenAccent = Color(0xFF00E676);
  static const Color redAccent = Color(0xFFFF5252);
  static const Color textMuted = Color(0xFF888890);
  static const Color borderSubtle = Color(0x15FFFFFF);

  // Bottom Input States
  int _entryType = 0; // 0: Diya, 1: Liya
  String _selectedPaymentMode = "UPI";
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Initial Sample Transactions from your design
  final List<Map<String, dynamic>> _messages = [
    {
      "dateHeader": "28 SEPTEMBER 2024",
      "amount": "50",
      "typeText": "(Diya)",
      "isDiya": true,
      "tag": "UPI",
      "note": "Chai nashta & patties with friends",
      "time": "28/9 17:42",
      "txnId": null,
      "footerTag": null,
    },
    {
      "dateHeader": "30 SEPTEMBER 2024",
      "amount": "100",
      "typeText": "(Diya)",
      "isDiya": true,
      "tag": "CASH",
      "note": "dan kar diya bas aise hi",
      "time": "30/9 21:21",
      "txnId": "#TXN-8941",
      "footerTag": null,
    },
    {
      "dateHeader": null,
      "amount": "50",
      "typeText": "(Sahil ne diya)",
      "isDiya": false,
      "tag": "GPay",
      "note": "Sahil settled partial amount for previous food",
      "time": "Today, 10:15 AM",
      "txnId": null,
      "footerTag": "Balance adjusted",
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addNewEntry() {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      AppToast.show(context, title: "Amount likhein!", type: ToastType.warning);
      return;
    }

    final noteText = _noteController.text.trim().isEmpty
        ? (_entryType == 0 ? "Udhar Diya" : "Paisa Liya")
        : _noteController.text.trim();

    setState(() {
      _messages.add({
        "dateHeader": null,
        "amount": amountText,
        "typeText": _entryType == 0
            ? "(Diya)"
            : "(${widget.friendName} ne diya)",
        "isDiya": _entryType == 0,
        "tag": _selectedPaymentMode,
        "note": noteText,
        "time": "Today, ${TimeOfDay.now().format(context)}",
        "txnId": "#TXN-${DateTime.now().millisecondsSinceEpoch % 10000}",
        "footerTag": _entryType == 1 ? "Balance adjusted" : null,
      });

      _amountController.clear();
      _noteController.clear();
    });

    FocusScope.of(context).unfocus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    AppToast.show(
      context,
      title: "Hisaab save ho gaya!",
      type: ToastType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: oledBg,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Bar (Back Arrow, Friend Name, More Menu)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.friendName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: textMuted,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Net Lena/Dena Floating Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: cardSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: borderSubtle),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isLena ? "NET LENA HAI" : "NET DENA HAI",
                          style: const TextStyle(
                            color: textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              "₹${widget.netAmount}",
                              style: TextStyle(
                                color: widget.isLena ? greenAccent : redAccent,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.isLena ? "(Receive)" : "(Pay)",
                              style: TextStyle(
                                color: widget.isLena ? greenAccent : redAccent,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: cardSurfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderSubtle),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            "Details",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.white70,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Chat Ledger Statement History
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return Column(
                    children: [
                      // Date Header Capsule (if present)
                      if (msg["dateHeader"] != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF19191D),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              msg["dateHeader"],
                              style: const TextStyle(
                                color: textMuted,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),

                      // Chat Card Bubble
                      _buildChatBubble(msg),
                    ],
                  );
                },
              ),
            ),

            // 4. Exact Custom Quick-Entry Bottom Navigation Bar
            _buildCustomChatBottomBar(),
          ],
        ),
      ),
    );
  }

  // Individual Statement Card Bubble
  Widget _buildChatBubble(Map<String, dynamic> msg) {
    final bool isDiya = msg["isDiya"] == true;
    final Color accent = isDiya ? greenAccent : redAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDiya
              ? greenAccent.withOpacity(0.18)
              : Colors.white.withOpacity(0.04),
          width: 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Amount + Type & Payment Mode Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "${isDiya ? '+' : '-'}₹${msg["amount"]}",
                    style: TextStyle(
                      color: accent,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    msg["typeText"],
                    style: TextStyle(
                      color: accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: isDiya
                      ? const Color(0xFF0F2619)
                      : const Color(0xFF222228),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDiya
                        ? greenAccent.withOpacity(0.2)
                        : Colors.white10,
                  ),
                ),
                child: Text(
                  msg["tag"],
                  style: TextStyle(
                    color: isDiya ? greenAccent : Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Row 2: Note Description
          Text(
            msg["note"],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 10),

          // Row 3: Meta details (Txn ID / Adjusted tag + Time & Checkmark)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (msg["txnId"] != null)
                Text(
                  msg["txnId"],
                  style: const TextStyle(
                    color: textMuted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                )
              else if (msg["footerTag"] != null)
                Text(
                  msg["footerTag"],
                  style: const TextStyle(
                    color: greenAccent,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                const SizedBox.shrink(),

              Row(
                children: [
                  Text(
                    msg["time"],
                    style: const TextStyle(color: textMuted, fontSize: 10.5),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.done_all_rounded,
                    size: 14,
                    color: greenAccent,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Exact Bottom Bar Layout matching design
  Widget _buildCustomChatBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(color: oledBg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Line 1: Note input field & Payment Dropdown Pill
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: cardSurface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: borderSubtle),
            ),
            child: Row(
              children: [
                const Icon(Icons.notes_rounded, color: textMuted, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    style: const TextStyle(color: Colors.white, fontSize: 12.5),
                    decoration: const InputDecoration(
                      hintText: "Hisaab ka note likhein (e.g. Chai, Udhaar)",
                      hintStyle: TextStyle(color: textMuted, fontSize: 12),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  color: cardSurfaceLight,
                  onSelected: (val) =>
                      setState(() => _selectedPaymentMode = val),
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: "UPI",
                      child: Text("UPI", style: TextStyle(color: Colors.white)),
                    ),
                    const PopupMenuItem(
                      value: "GPay",
                      child: Text(
                        "GPay",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const PopupMenuItem(
                      value: "CASH",
                      child: Text(
                        "CASH",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const PopupMenuItem(
                      value: "Card",
                      child: Text(
                        "Card",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2125),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 13,
                          color: greenAccent,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _selectedPaymentMode,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.keyboard_arrow_up_rounded,
                          size: 14,
                          color: textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Line 2: Diya / Liya Toggle Pills
          Container(
            height: 48,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: cardSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderSubtle),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _entryType = 0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: _entryType == 0
                            ? const Color(0xFF0F2B1D)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: _entryType == 0
                            ? Border.all(color: greenAccent.withOpacity(0.3))
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_upward_rounded,
                            size: 16,
                            color: _entryType == 0 ? greenAccent : textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Diya",
                            style: TextStyle(
                              color: _entryType == 0 ? greenAccent : textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _entryType = 1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: _entryType == 1
                            ? const Color(0xFF2E1316)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: _entryType == 1
                            ? Border.all(color: redAccent.withOpacity(0.3))
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_downward_rounded,
                            size: 16,
                            color: _entryType == 1 ? redAccent : textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Liya",
                            style: TextStyle(
                              color: _entryType == 1 ? redAccent : textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Line 3: Amount Field, White Save Pill, and Dark Close Button
          Row(
            children: [
              // Amount Input Pill
              Expanded(
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: cardSurface,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: borderSubtle),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        "₹",
                        style: TextStyle(
                          color: greenAccent,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: const InputDecoration(
                            hintText: "Amount",
                            hintStyle: TextStyle(
                              color: textMuted,
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Save Button (Pure White Pill)
              GestureDetector(
                onTap: _addNewEntry,
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(Icons.check_rounded, color: Colors.black, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Close Button (Circular Dark)
              GestureDetector(
                onTap: () {
                  _amountController.clear();
                  _noteController.clear();
                  FocusScope.of(context).unfocus();
                },
                child: Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: cardSurface,
                    shape: BoxShape.circle,
                    border: Border.all(color: borderSubtle),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
