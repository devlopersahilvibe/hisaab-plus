import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/khata_screen.dart';
import 'screens/entry_form_screen.dart';
import 'widgets/bottom_nav_bar.dart';
// import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';       // <-- 1. Naya Hive import
import 'models/transaction_model.dart';                // <-- 2. Transaction model
import 'models/friend_model.dart';                     // <-- 3. Friend model
import 'screens/splash_screen.dart';

void main() async {                                    
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Hive ko phone mein start karein
  await Hive.initFlutter();

  // 2. Adapters register karein taaki Hive classes ko pehchaane
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(FriendModelAdapter());

  // 3. Database memory boxes kholen
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
      title: 'HISAAB+',
      theme: ThemeData(
        fontFamily: 'sans-serif',
        scaffoldBackgroundColor: const Color(0xFFF9F5F0),
      ),
      // Splash screen yahan se shuru hogi:
      home: const SplashScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _activeTab = 0; // 0: Home, 1: Dost Khata, 2: Entry Form View
  int _selectedEntryType = 0; // 0: Kharcha, 1: Diya, 2: Liya
  bool _isExpanded = false;

  void _switchToAddEntry(int entryType) {
    setState(() {
      _selectedEntryType = entryType;
      _activeTab = 2;
      _isExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Screens Stack
          IndexedStack(
            index: _activeTab,
            children: [
              const HomeScreen(),
              const DostKhataScreen(),
              EntryFormView(
                entryType: _selectedEntryType,
                onClose: () => setState(() => _activeTab = 0),
              ),
            ],
          ),

          // Dim background overlay on nav expand
          if (_isExpanded)
            GestureDetector(
              onTap: () => setState(() => _isExpanded = false),
              child: Container(color: Colors.black.withValues(alpha: 0.2)),
            ),

          // Reusable Floating Bottom Bar Widget
          FloatingBottomNavBar(
            activeTab: _activeTab,
            isExpanded: _isExpanded,
            onTabSelected: (index) {
              setState(() {
                _activeTab = index;
                _isExpanded = false;
              });
            },
            onToggleExpand: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            onAddEntry: _switchToAddEntry,
          ),
        ],
      ),
    );
  }
}