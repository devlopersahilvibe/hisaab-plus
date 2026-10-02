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
  // Tailwind Exact Palette from HTML Template
  static const Color oledBg = Color(0xFF000000);
  static const Color surfaceCard = Color(0xFF141416);
  static const Color surfaceSecondary = Color(0xFF18181B);
  static const Color surfaceHighlight = Color(0xFF202024);
  static const Color borderCustom = Color(0xFF242429);

  // Lena / Dena Colors
  static const Color lenaGreen = Color(0xFF10B981);
  static const Color lenaGreenLight = Color(0xFF34D399);
  static const Color denaRed = Color(0xFFF43F5E);
  static const Color denaRedLight = Color(0xFFFB7185);

  // States
  int _entryType = 0; // 0: Diya, 1: Liya
  String _selectedPaymentMode = "UPI";
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      "dateHeader": "28 September 2024",
      "amount": "50",
      "typeText": "(Diya)",
      "isDiya": true,
      "tag": "UPI",
      "note": "Chai nashta & patties with friends",
      "time": "28/9 17:42",
      "txnId": null,
      "isPrimary": false,
      "footerTag": null,
    },
    {
      "dateHeader": "30 September 2024",
      "amount": "100",
      "typeText": "(Diya)",
      "isDiya": true,
      "tag": "Cash",
      "note": "dan kar diya bas aise hi",
      "time": "30/9 21:21",
      "txnId": "#TXN-8941",
      "isPrimary": true,
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
      "isPrimary": false,
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
      AppToast.show(context, title: "Amount daalein!", type: ToastType.warning);
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
        "isPrimary": false,
        "footerTag": _entryType == 1 ? "Balance adjusted" : null,
      });

      _amountController.clear();
      _noteController.clear();
    });

    FocusScope.of(context).unfocus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
        );
      }
    });

    AppToast.show(
      context,
      title: "Entry save ho gayi!",
      type: ToastType.success,
    );
  }

  // Action: Close Page & Navigate Back
  void _closeChatPage() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cleanAmount = widget.netAmount.replaceAll(".00", "");

    return Scaffold(
      backgroundColor: oledBg,
      body: Stack(
        children: [
          // ----------------------------------------------------
          // WhatsApp Style Subtle Dark Background Image Layer
          // ----------------------------------------------------
          Positioned.fill(
            child: Opacity(
              opacity:
                  0.12, // 12% opacity keeps OLED pitch dark intact & readable
              child: Image.asset(
                'assets/images/chat_bg.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(), // Fallback if image not yet present
              ),
            ),
          ),

          // Main Foreground Chat UI
          SafeArea(
            child: Column(
              children: [
                // Top Navigation & Header
                Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 14,
                    top: 4,
                    bottom: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _closeChatPage,
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Color(0xFFA3A3A3),
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.friendName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.more_vert_rounded,
                          color: Color(0xFFD4D4D4),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),

                // Net Balance Master Card
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceCard.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderCustom),
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
                                color: Color(0xFFA3A3A3),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  "₹$cleanAmount",
                                  style: TextStyle(
                                    color: widget.isLena ? lenaGreen : denaRed,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.isLena ? "(Receive)" : "(Pay)",
                                  style: TextStyle(
                                    color: widget.isLena
                                        ? const Color(0xE634D399)
                                        : const Color(0xE6FB7185),
                                    fontSize: 12,
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
                            color: surfaceSecondary,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderCustom),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                "Details",
                                style: TextStyle(
                                  color: Color(0xFFD4D4D4),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Color(0xFFD4D4D4),
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Scrollable Timeline Chat
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return Column(
                        children: [
                          if (msg["dateHeader"] != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: surfaceSecondary.withOpacity(0.85),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: borderCustom.withOpacity(0.7),
                                  ),
                                ),
                                child: Text(
                                  msg["dateHeader"],
                                  style: const TextStyle(
                                    color: Color(0xFFA3A3A3),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          _buildTransactionCard(msg),
                        ],
                      );
                    },
                  ),
                ),

                // Bottom Action Dock
                _buildBottomDock(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> msg) {
    final bool isDiya = msg["isDiya"] == true;
    final bool isPrimary = msg["isPrimary"] == true;

    if (isPrimary) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.88,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF122419), Color(0xFF0F1D14)],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
              topRight: Radius.circular(4),
            ),
            border: Border.all(color: const Color(0x99064E3B)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33022C22),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Text(
                        "+₹100",
                        style: TextStyle(
                          color: Color(0xFF6EE7B7),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        "(Diya)",
                        style: TextStyle(
                          color: Color(0xE66EE7B7),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xB3022C22),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0x66047857)),
                    ),
                    child: const Text(
                      "Cash",
                      style: TextStyle(
                        color: Color(0xFFA7F3D0),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                msg["note"],
                style: const TextStyle(
                  color: Color(0xFFECFDF5),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0x4D065F46))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      msg["txnId"] ?? "",
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Color(0xB334D399),
                        fontSize: 10,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          msg["time"],
                          style: const TextStyle(
                            color: Color(0xCC6EE7B7),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.done_all_rounded,
                          size: 14,
                          color: Color(0xFF34D399),
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
    }

    return Align(
      alignment: isDiya ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (isDiya ? const Color(0xFF121415) : surfaceCard).withOpacity(
            0.92,
          ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(16),
            topRight: isDiya
                ? const Radius.circular(4)
                : const Radius.circular(16),
          ),
          border: Border.all(color: borderCustom),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 6),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0x0DFFFFFF))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "${isDiya ? '+' : '-'}₹${msg["amount"]}",
                        style: TextStyle(
                          color: isDiya ? lenaGreenLight : denaRed,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        msg["typeText"],
                        style: TextStyle(
                          color: isDiya
                              ? const Color(0xCC6EE7B7)
                              : const Color(0xCCFDA4AF),
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: surfaceHighlight,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: borderCustom),
                    ),
                    child: Text(
                      msg["tag"],
                      style: const TextStyle(
                        color: Color(0xFFD4D4D4),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              msg["note"],
              style: TextStyle(
                color: isDiya
                    ? const Color(0xFFE5E5E5)
                    : const Color(0xFFD4D4D4),
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (msg["footerTag"] != null)
                  Text(
                    msg["footerTag"],
                    style: const TextStyle(color: lenaGreenLight, fontSize: 10),
                  )
                else
                  const SizedBox.shrink(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      msg["time"],
                      style: const TextStyle(
                        color: Color(0xFFD4D4D4),
                        fontSize: 10,
                      ),
                    ),
                    if (isDiya) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.done_all_rounded,
                        size: 12,
                        color: lenaGreenLight,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Bottom Action Dock with Functional ✕ Button
  Widget _buildBottomDock() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: oledBg.withOpacity(0.96),
        border: const Border(top: BorderSide(color: borderCustom)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Note Input Field
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: surfaceSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderCustom),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.edit_note_rounded,
                  color: Color(0xFFA3A3A3),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _noteController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: "Hisaab ka note likhein (e.g. Chai, Udhaar, Saman)...",
                      hintStyle: TextStyle(
                        color: Color(0xFF737373),
                        fontSize: 12,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  color: surfaceHighlight,
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
                      value: "Cash",
                      child: Text(
                        "Cash",
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
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: surfaceHighlight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderCustom),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 14,
                          color: lenaGreenLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _selectedPaymentMode,
                          style: const TextStyle(
                            color: Color(0xFFE5E5E5),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.expand_less_rounded,
                          size: 14,
                          color: Color(0xFFA3A3A3),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Row 2: Diya / Liya Toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: surfaceSecondary.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderCustom),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _entryType = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: _entryType == 0
                            ? const Color(0xB3022C22)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: _entryType == 0
                            ? Border.all(color: const Color(0x66047857))
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_upward_rounded,
                            size: 16,
                            color: _entryType == 0
                                ? const Color(0xFF6EE7B7)
                                : const Color(0xFFA3A3A3),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "Diya",
                            style: TextStyle(
                              color: _entryType == 0
                                  ? const Color(0xFF6EE7B7)
                                  : const Color(0xFFA3A3A3),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
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
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: _entryType == 1
                            ? const Color(0xB34C0519)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: _entryType == 1
                            ? Border.all(color: const Color(0x66BE123C))
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_downward_rounded,
                            size: 16,
                            color: _entryType == 1
                                ? const Color(0xFFFDA4AF)
                                : const Color(0xFFA3A3A3),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "Liya",
                            style: TextStyle(
                              color: _entryType == 1
                                  ? const Color(0xFFFDA4AF)
                                  : const Color(0xFFA3A3A3),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
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

          // Row 3: Amount + Save + Close Button (Closes Page)
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: surfaceSecondary,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderCustom),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        "₹",
                        style: TextStyle(
                          color: lenaGreenLight,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: const InputDecoration(
                            hintText: "Amount",
                            hintStyle: TextStyle(
                              color: Color(0xFF737373),
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

              // Save Button
              GestureDetector(
                onTap: _addNewEntry,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        "Save",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.check_rounded, color: Colors.black, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // ✕ Close Button (Directly Closes Chat Screen)
              GestureDetector(
                onTap: _closeChatPage,
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: surfaceSecondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: borderCustom),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.close_rounded,
                      color: Color(0xFFD4D4D4),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Home Drag Bar
          Container(
            width: 128,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0x6652525B),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
