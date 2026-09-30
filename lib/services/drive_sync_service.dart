import 'package:flutter/foundation.dart';

class DriveSyncService {
  // Temporary bypass without file_picker for production build
  static Future<bool> uploadDataToDrive() async {
    debugPrint("Backup / Export feature coming soon!");
    return true;
  }

  static Future<bool> syncDataWithDrive() async {
    debugPrint("Sync / Restore feature coming soon!");
    return true;
  }
}
