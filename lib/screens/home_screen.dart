import 'package:flutter/material.dart';

import '../widgets/custom_toast.dart';
import 'hisab_chat.dart';
import 'khata_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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

  // Sample History Data
  final List<Map<String, dynamic>> _historyItems = [
    {
      "initials": "SK",
      "name": "Sahil Khan",
      "timeOrDesc": "2 ghante pehle",
      "amount": "100.00",
      "status": "+₹100 lena",
      "isLena": true,
    },
    {
      "initials": "MS",
      "name": "Mahaveer Shinha",
      "timeOrDesc": "Kal (Yesterday)",
      "amount": "150.00",
      "status": "+₹150 lena",
      "isLena": true,
    },
    {
      "initials": "RV",
      "name": "Rahul Verma",
      "timeOrDesc": "28 Oct • Chai & Nashta",
      "amount": "350.00",
      "status": "-₹350 dena",
      "isLena": false,
    },
  ];

  void _openChat(Map<String, dynamic> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HisabChatScreen(
          friendName: item["name"],
          netAmount: item["amount"],
          isLena: item["isLena"],
        ),
      ),
    );
  }

  void _openKhata() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DostKhataScreen()),
    );
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
              // 1. Top Bar: Brand Title & Search Pill
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 14, left: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
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
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.search_rounded,
                              size: 18,
                              color: textMuted,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Search dost, kharcha...",
                                style: TextStyle(
                                  color: textMuted,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w400,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                "|",
                                style: TextStyle(
                                  color: textMutedDark,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.more_vert_rounded,
                              size: 18,
                              color: textMuted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 2. Main Ledger Summary Card
              Container(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                decoration: BoxDecoration(
                  color: cardSurface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withOpacity(0.04)),
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
                            const Text(
                              "₹1,250",
                              style: TextStyle(
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
                              child: const Text(
                                "+₹250 aaj",
                                style: TextStyle(
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
                            const Text(
                              "₹450",
                              style: TextStyle(
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
                              child: const Text(
                                "-₹150 aaj",
                                style: TextStyle(
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
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
                            onTap: () {
                              AppToast.show(
                                context,
                                title: "Naya Kharcha jod rahe hain...",
                                type: ToastType.info,
                              );
                            },
                            borderRadius: BorderRadius.circular(26),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(26),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
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
              ),

              const SizedBox(height: 14),

              // 3. Google Drive Sync Banner Card
              Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 16, 20),
                decoration: BoxDecoration(
                  color: cardSurface,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: Colors.white.withOpacity(0.04)),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: textMutedDark,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Data Surakshit Rakhein",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "Google Drive cloud sync se hisaab hamesha surakshit rahega.",
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
                                    title: "Cloud sync complete!",
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
                                  "Sync Data",
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: Row(
                        children: const [
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

              // 5. History Tiles
              ..._historyItems.map((item) {
                return _buildHistoryTile(
                  initials: item["initials"],
                  name: item["name"],
                  timeOrDesc: item["timeOrDesc"],
                  amount: "₹${item["amount"]}",
                  status: item["status"],
                  isLena: item["isLena"],
                  onTap: () => _openChat(item),
                );
              }),
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
              color: Colors.white.withOpacity(0.02),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            child: Icon(
              Icons.arrow_drop_up_rounded,
              color: Colors.white.withOpacity(0.18),
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
                color: Colors.white.withOpacity(0.08),
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
                color: Colors.white.withOpacity(0.12),
                width: 1.2,
              ),
            ),
            child: const Center(
              child: Icon(Icons.cloud_outlined, color: Colors.white, size: 21),
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
    required bool isLena,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        timeOrDesc,
                        style: const TextStyle(color: textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
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
                        color: isLena ? greenAccent : redAccent,
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
