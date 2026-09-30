import 'package:flutter/material.dart';


class FloatingBottomNavBar extends StatelessWidget {
  final int activeTab;
  final bool isExpanded;
  final Function(int) onTabSelected;
  final VoidCallback onToggleExpand;
  final Function(int) onAddEntry;

  const FloatingBottomNavBar({
    super.key,
    required this.activeTab,
    required this.isExpanded,
    required this.onTabSelected,
    required this.onToggleExpand,
    required this.onAddEntry,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF9E3626);
    const textDark = Color(0xFF1E1E1E);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isExpanded ? 24 : 35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Expanded Action Pills (Kharcha, Diya, Liya)
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildPillButton(
                        icon: Icons.receipt_long_rounded,
                        label: "Kharcha",
                        color: const Color(0xFF37474F),
                        onTap: () => onAddEntry(0),
                      ),
                      const SizedBox(width: 6),
                      _buildPillButton(
                        icon: Icons.arrow_upward_rounded,
                        label: "Diya (+)",
                        color: const Color(0xFF2E7D32),
                        onTap: () => onAddEntry(1),
                      ),
                      const SizedBox(width: 6),
                      _buildPillButton(
                        icon: Icons.arrow_downward_rounded,
                        label: "Liya (-)",
                        color: const Color(0xFFC62828),
                        onTap: () => onAddEntry(2),
                      ),
                    ],
                  ),
                ),
              ),

              // Base Navigation Icons (Home & Khata)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildNavIcon(
                    icon: activeTab == 0 ? Icons.home_rounded : Icons.home_outlined,
                    label: "Home",
                    isActive: activeTab == 0,
                    onTap: () => onTabSelected(0),
                  ),
                  const SizedBox(width: 14),
                  GestureDetector(
                    onTap: onToggleExpand,
                    child: AnimatedRotation(
                      turns: isExpanded ? 0.125 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: isExpanded ? textDark : primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isExpanded ? textDark : primaryColor).withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  _buildNavIcon(
                    icon: activeTab == 1 ? Icons.people_alt_rounded : Icons.people_outline_rounded,
                    label: "Khata",
                    isActive: activeTab == 1,
                    onTap: () => onTabSelected(1),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    const primaryColor = Color(0xFF9E3626);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? primaryColor : Colors.grey, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? primaryColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}