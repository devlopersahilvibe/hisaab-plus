import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/transaction_model.dart';
import 'models/friend_model.dart';
import 'screens/home_screen.dart';
import 'screens/khata_screen.dart';
import 'screens/entry_form_screen.dart';
import 'widgets/bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Adapters registration
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(FriendModelAdapter());

  await Hive.openBox<TransactionModel>('transactions_box');
  await Hive.openBox<FriendModel>('friends_box');

  runApp(const HisaabApp());
}

class HisaabApp extends StatelessWidget {
  const HisaabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HISAAB+ v4.0.0',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF000000), // OLED Pitch Black
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _activeTab = 0; // 0: Home, 1: Khata, 2: Profile

  void _openQuickEntry() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EntryFormView(entryType: 0, onClose: () => Navigator.pop(context)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Screens Switcher (Fixed recursion bug)
          IndexedStack(
            index: _activeTab,
            children: const [
              HomeScreen(),
              DostKhataScreen(), // Yahan sahi screen attach kar di gayi hai
              Center(
                child: Text(
                  "Profile Screen (Coming Soon)",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            ],
          ),

          // OLED Luxury Floating Navigation Bar
          FloatingOledNavBar(
            activeTab: _activeTab,
            onTabSelected: (index) {
              setState(() => _activeTab = index);
            },
            onAddPressed: _openQuickEntry,
          ),
        ],
      ),
    );
  }
}
