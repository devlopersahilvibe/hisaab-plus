import 'dart:async';
import 'package:flutter/material.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // HISAAB+ Smooth Spring & Expansion Curves
  late Animation<double> _titleFade;
  late Animation<double> _titleScale;
  late Animation<double> _titleTracking;
  late Animation<double> _screenFadeOut;

  // Bottom Quick Typewriter & Loading Dots
  final String _authorText = "BY SAHIL SONWANSHI";
  String _typedAuthor = "";
  int _charIndex = 0;
  int _dotCount = 0;
  Timer? _typeTimer;
  Timer? _dotTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800), // Fast, responsive total time
    );

    // 1. HISAAB+ Buttery Smooth Entrance (0ms - 550ms)
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.32, curve: Curves.easeOutCubic),
      ),
    );

    _titleScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.40, curve: Curves.easeOutBack),
      ),
    );

    _titleTracking = Tween<double>(begin: 2.0, end: 4.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutQuart),
      ),
    );

    // 2. Smooth Exit to Dashboard (1400ms - 1750ms)
    _screenFadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.78, 0.98, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    // 3. Bottom Text Fast Typewriter (Runs instantly without lag)
    _typeTimer = Timer.periodic(const Duration(milliseconds: 24), (timer) {
      if (_charIndex < _authorText.length) {
        if (mounted) {
          setState(() {
            _charIndex++;
            _typedAuthor = _authorText.substring(0, _charIndex);
          });
        }
      } else {
        timer.cancel();
        _startQuickDots();
      }
    });

    // 4. Smooth Push to Main Dashboard
    Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 320),
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MainNavigationScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  // Chhota crisp 3-dot loading cycle
  void _startQuickDots() {
    _dotTimer = Timer.periodic(const Duration(milliseconds: 140), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_dotCount < 3) {
        setState(() => _dotCount++);
      } else {
        timer.cancel(); // 3 dots ke baad loop nahi karega, seedha app khulega
      }
    });
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _dotTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const darkBg = Color(0xFF0C0C0E);
    const terracotta = Color(0xFF9E3626); // Brand terracotta accent

    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final currentOpacity = (_titleFade.value * _screenFadeOut.value).clamp(0.0, 1.0);

            return Opacity(
              opacity: currentOpacity,
              child: Stack(
                children: [
                  // Center: Buttery Smooth HISAAB+
                  Center(
                    child: Transform.scale(
                      scale: _titleScale.value,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            "HISAAB",
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: _titleTracking.value,
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Text(
                            "+",
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: terracotta,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom: Fast Typed Name + Quick Dot Sequence
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 34,
                    child: Center(
                      child: Text(
                        "$_typedAuthor${'.' * _dotCount}",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.55),
                          letterSpacing: 2.2,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}