import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login.dart';
import 'register.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Theme.of(context).colorScheme.primary, Colors.black],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth;
                  final contentWidth = maxWidth * 0.85;
                  return Center(
                    child: Container(
                      width: contentWidth,
                      padding: EdgeInsets.symmetric(
                        horizontal: maxWidth * 0.05,
                        vertical: constraints.maxHeight * 0.02,
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TweenAnimationBuilder(
                                  tween: Tween<double>(begin: 0, end: 1),
                                  duration: const Duration(seconds: 2),
                                  builder: (context, double value, child) {
                                    return Transform.translate(
                                      offset: Offset(
                                        0,
                                        sin(value * 2 * 3.14159) * 4,
                                      ),
                                      child: child,
                                    );
                                  },
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    height: constraints.maxHeight * 0.15,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(height: constraints.maxHeight * 0.04),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Serendipity',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: min(
                                          constraints.maxWidth * 0.08,
                                          constraints.maxHeight * 0.05,
                                        ),
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                    Text(
                                      'Engine',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: min(
                                          constraints.maxWidth * 0.08,
                                          constraints.maxHeight * 0.05,
                                        ),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: constraints.maxHeight * 0.02),
                                Text(
                                  'Branch Out, Make Connections, Meet People',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: min(
                                      constraints.maxWidth * 0.04,
                                      constraints.maxHeight * 0.022,
                                    ),
                                    color: Colors.white.withOpacity(0.8),
                                    height: 1.3,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: constraints.maxHeight * 0.04,
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: maxWidth * 0.9,
                                  height: constraints.maxHeight * 0.06,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => const Register(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        vertical: constraints.maxHeight * 0.015,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 4,
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'Register',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: min(
                                            constraints.maxWidth * 0.04,
                                            constraints.maxHeight * 0.02,
                                          ),
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: constraints.maxHeight * 0.015),
                                SizedBox(
                                  width: maxWidth * 0.9,
                                  height: constraints.maxHeight * 0.06,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const Login(),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                      side: BorderSide(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                        width: 1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: constraints.maxHeight * 0.015,
                                      ),
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'Sign in',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: min(
                                            constraints.maxWidth * 0.035,
                                            constraints.maxHeight * 0.018,
                                          ),
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
