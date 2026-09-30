import 'package:flutter/material.dart';

enum ToastType { success, error, warning, info }

class AppToast {
  static void show(
    BuildContext context, {
    required String title,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();

    Color circleColor;
    IconData iconData;

    switch (type) {
      case ToastType.success:
        circleColor = const Color(0xFF4CAF50);
        iconData = Icons.check;
        break;
      case ToastType.error:
        circleColor = const Color(0xFFFF5252);
        iconData = Icons.priority_high_rounded;
        break;
      case ToastType.warning:
        circleColor = const Color(0xFFFFC107);
        iconData = Icons.warning_rounded;
        break;
      case ToastType.info:
        circleColor = const Color(0xFF448AFF);
        iconData = Icons.info_rounded;
        break;
    }

    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      duration: duration,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 96),
      padding: EdgeInsets.zero,
      content: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF191919),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: circleColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  size: 16,
                  color: type == ToastType.warning ? Colors.black : Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
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