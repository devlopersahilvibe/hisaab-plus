import 'package:flutter/material.dart';

class FriendDetailView extends StatefulWidget {
  final Map<String, dynamic> friend;
  final VoidCallback onBack;
  final Function(Map<String, dynamic>) onEdit;
  final Function(Map<String, dynamic>) onDelete;

  const FriendDetailView({
    super.key,
    required this.friend,
    required this.onBack,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<FriendDetailView> createState() => _FriendDetailViewState();
}

class _FriendDetailViewState extends State<FriendDetailView> {
  bool _isProfileExpanded = false;

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF9E3626);
    const textDark = Color(0xFF1E1E1E);
    final isLena = widget.friend["type"] == "lena";
    final List<Map<String, dynamic>> history =
        (widget.friend["history"] as List<Map<String, dynamic>>?) ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textDark, size: 18),
          onPressed: widget.onBack,
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
                  widget.friend["name"][0],
                  style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor, fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.friend["name"],
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textDark),
                    ),
                    Text(
                      widget.friend["phone"] ?? "Khata Contact",
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
          // Expandable Profile Details & Edit/Delete Actions
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
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        widget.friend["desc"] != null && widget.friend["desc"].toString().isNotEmpty
                            ? widget.friend["desc"]
                            : "No description added",
                        style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Total Transactions: ${history.length} records",
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => widget.onEdit(widget.friend),
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
                          onPressed: () => widget.onDelete(widget.friend),
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

          // Net Balance Banner
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
                      isLena ? "NET LENA HAI" : "NET DENA HAI",
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "₹${widget.friend['amount']}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: isLena ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Payment reminder link generated!")),
                    );
                  },
                  icon: const Icon(Icons.send_rounded, size: 13, color: Colors.white),
                  label: const Text("Hisab Settle", style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEFE9E2)),

          // Transaction Statement Flow (Chat Bubbles)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
              itemCount: history.length,
              itemBuilder: (ctx, index) {
                final tx = history[index];
                final isDiya = tx["type"] == "diya";

                return Align(
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
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
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
                                tx["mode"],
                                style: const TextStyle(fontSize: 9, color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          tx["title"],
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textDark),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          tx["date"],
                          style: const TextStyle(fontSize: 9, color: Colors.grey),
                        ),
                      ],
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
}