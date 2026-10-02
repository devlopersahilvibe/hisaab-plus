import 'package:flutter/material.dart';

enum ToastType { success, error, warning, info }

class AppToast {
  static void show(
    BuildContext context, {
    required String title,
    ToastType type = ToastType.info,
    Duration duration = const Duration(milliseconds: 2200),
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();

    // OLED Theme Matching Accent Colors & Icons
    Color badgeColor;
    Color badgeTextColor;
    IconData iconData;

    switch (type) {
      case ToastType.success:
        badgeColor = const Color(0xFF00E676); // Vibrant Green
        badgeTextColor = Colors.black;
        iconData = Icons.check_rounded;
        break;
      case ToastType.error:
        badgeColor = const Color(0xFFFF5252); // Coral Red[cite: 1]
        badgeTextColor = Colors.white;
        iconData = Icons.priority_high_rounded;
        break;
      case ToastType.warning:
        badgeColor = const Color(0xFFFFB300); // Amber Yellow
        badgeTextColor = Colors.black;
        iconData = Icons.warning_rounded;
        break;
      case ToastType.info:
        badgeColor = const Color(0xFF3D82F6); // Electric Blue[cite: 10]
        badgeTextColor = Colors.white;
        iconData = Icons.info_rounded;
        break;
    }

    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      duration: duration,
      // Floating bar ke theek upar float karega[cite: 10]
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 92),
      padding: EdgeInsets.zero,
      content: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF141416), // Dark Surface[cite: 10]
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1.1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black87,
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(iconData, size: 15, color: badgeTextColor),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
