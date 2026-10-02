import 'dart:math';

import 'package:flutter/material.dart';

import 'hisab_chat.dart';

class DostKhataScreen extends StatefulWidget {
  const DostKhataScreen({super.key});

  @override
  State<DostKhataScreen> createState() => _DostKhataScreenState();
}

class _DostKhataScreenState extends State<DostKhataScreen> {
  String _activeFilter = "Sabhi"; // Sabhi, Lena Hai, Dena Hai
  String _searchQuery = "";

  // OLED Luxury Dark Palette
  static const Color oledBg = Color(0xFF000000);
  static const Color cardSurface = Color(0xFF131315);
  static const Color cardSurfaceLight = Color(0xFF1C1C1F);
  static const Color greenAccent = Color(0xFF00E676);
  static const Color greenPillBg = Color(0xFF0B291A);
  static const Color redAccent = Color(0xFFFF5252);
  static const Color redPillBg = Color(0xFF2E1215);
  static const Color textMuted = Color(0xFF888890);
  static const Color textMutedDark = Color(0xFF55555C);

  // Sample data according to design reference
  final List<Map<String, dynamic>> _dostList = [
    {
      "initials": "SK",
      "name": "Sahil",
      "desc": "dan kar diya bas aise hi",
      "time": "Aaj",
      "amount": "100.00",
      "status": "+₹100 lena",
      "isLena": true,
    },
    {
      "initials": "MS",
      "name": "Mahaveer Shinha",
      "desc": "selun bal katai",
      "time": "Aaj",
      "amount": "150.00",
      "status": "+₹150 lena",
      "isLena": true,
    },
    {
      "initials": "RN",
      "name": "Ranu",
      "desc": "patni davai ilaj",
      "time": "Kal",
      "amount": "50.00",
      "status": "+₹50 lena",
      "isLena": true,
    },
    {
      "initials": "JN",
      "name": "Janu",
      "desc": "dhandhe ka hisaab",
      "time": "28 Oct",
      "amount": "150.00",
      "status": "-₹150 dena",
      "isLena": false,
    },
  ];

  void _openChat(Map<String, dynamic> dost) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HisabChatScreen(
          friendName: dost["name"],
          netAmount: dost["amount"],
          isLena: dost["isLena"],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _dostList.where((dost) {
      final nameMatches =
          dost["name"].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          dost["desc"].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      if (!nameMatches) return false;

      if (_activeFilter == "Lena Hai") return dost["isLena"] == true;
      if (_activeFilter == "Dena Hai") return dost["isLena"] == false;
      return true;
    }).toList();

    final int lenaCount = _dostList.where((d) => d["isLena"] == true).length;
    final int denaCount = _dostList.where((d) => d["isLena"] == false).length;

    return Scaffold(
      backgroundColor: oledBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Signature Top Bar
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
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              size: 18,
                              color: textMuted,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                onChanged: (val) =>
                                    setState(() => _searchQuery = val),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                ),
                                decoration: const InputDecoration(
                                  hintText: "Search dost, kharcha...",
                                  hintStyle: TextStyle(
                                    color: textMuted,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
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
                            const SizedBox(width: 4),
                            const Icon(
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

              // 2. Net Ledger Ring Card
              Container(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
                decoration: BoxDecoration(
                  color: cardSurface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withOpacity(0.04)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Ultra HD Circular Net Arc
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF151518),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.04),
                              width: 1,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size(96, 96),
                                painter: _NetRadialChartPainter(
                                  greenFraction: 0.65,
                                  redFraction: 0.35,
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    "NET",
                                    style: TextStyle(
                                      color: Color(0xFF888890),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "+₹150",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 18),

                        // Lena / Dena Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Lena Hai Row
                              Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: greenAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    "Lena Hai",
                                    style: TextStyle(
                                      color: textMuted,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: greenPillBg,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      "+₹150 aaj",
                                      style: TextStyle(
                                        color: greenAccent,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                "₹300.00",
                                style: TextStyle(
                                  color: greenAccent,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Dena Hai Row
                              Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    "Dena Hai",
                                    style: TextStyle(
                                      color: textMuted,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: redPillBg,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      "-₹150 aaj",
                                      style: TextStyle(
                                        color: redAccent,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                "₹150.00",
                                style: TextStyle(
                                  color: redAccent,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // Count Pill & + Naya Khata Row
                    Row(
                      children: [
                        Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: cardSurfaceLight,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.credit_card_outlined,
                                color: textMuted,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "${_dostList.length} Dost",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.person_add_alt_1_rounded,
                                  size: 16,
                                  color: Colors.black,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "+ Naya Khata",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // 3. Category Filter Chips
              Row(
                children: [
                  _buildFilterChip("Sabhi", _dostList.length, null),
                  const SizedBox(width: 8),
                  _buildFilterChip("Lena Hai", lenaCount, greenAccent),
                  const SizedBox(width: 8),
                  _buildFilterChip("Dena Hai", denaCount, redAccent),
                ],
              ),

              const SizedBox(height: 24),

              // 4. Section Title
              const Text(
                "Active Dost",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              // 5. Active Dost Ledger List
              if (filteredList.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      "Koi dost nahi mila",
                      style: TextStyle(color: textMuted, fontSize: 13),
                    ),
                  ),
                )
              else
                ...filteredList.map((dost) {
                  return _buildDostTile(
                    initials: dost["initials"],
                    name: dost["name"],
                    desc: dost["desc"],
                    time: dost["time"],
                    amount: dost["amount"],
                    status: dost["status"],
                    isLena: dost["isLena"],
                    onTap: () => _openChat(dost),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count, Color? dotColor) {
    final bool isSelected = _activeFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF222228) : cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white24 : Colors.white.withOpacity(0.04),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ] else if (isSelected) ...[
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: greenAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : textMuted,
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              "$count",
              style: TextStyle(
                color: isSelected ? Colors.white70 : textMutedDark,
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDostTile({
    required String initials,
    required String name,
    required String desc,
    required String time,
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
                  width: 44,
                  height: 44,
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
                        fontSize: 13,
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
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "$desc • $time",
                        style: const TextStyle(color: textMuted, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₹$amount",
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
                        fontSize: 10.5,
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

// HD Retina Dual-Arc Painter
class _NetRadialChartPainter extends CustomPainter {
  final double greenFraction;
  final double redFraction;

  _NetRadialChartPainter({
    required this.greenFraction,
    required this.redFraction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 6;
    const strokeWidth = 8.0;

    final trackPaint = Paint()
      ..color = const Color(0xFF1B1B20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    canvas.drawCircle(center, radius, trackPaint);

    final rect = Rect.fromCircle(center: center, radius: radius);

    final greenPaint = Paint()
      ..color = const Color(0xFF00E676)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    final redPaint = Paint()
      ..color = const Color(0xFFFF5252)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    const startAngle = -pi / 2;
    const gap = 0.28;

    final greenSweep = (2 * pi * greenFraction) - gap;
    final redSweep = (2 * pi * redFraction) - gap;

    if (greenFraction > 0) {
      canvas.drawArc(rect, startAngle, greenSweep, false, greenPaint);
    }

    if (redFraction > 0) {
      canvas.drawArc(
        rect,
        startAngle + greenSweep + gap,
        redSweep,
        false,
        redPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NetRadialChartPainter oldDelegate) =>
      oldDelegate.greenFraction != greenFraction ||
      oldDelegate.redFraction != redFraction;
}
