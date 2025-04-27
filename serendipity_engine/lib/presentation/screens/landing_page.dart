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
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Random number generator for pin positions
  final Random _random = Random();

  // Animation controllers for repeating pin animations
  final List<AnimationController> _pinAnimControllers = [];

  // Modify the initState method to initialize pin positions early
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

    // Pre-calculate fixed pin positions
    _calculatePinPositions();

    // Create animation controllers for the pins
    for (int i = 0; i < 4; i++) {
      final controller = AnimationController(
        duration: Duration(seconds: 4 + i),
        vsync: this,
      );
      controller.repeat(reverse: false);
      _pinAnimControllers.add(controller);
    }

    _controller.forward();
  }

  // List to store fixed pin positions
  final List<Offset> _pinPositions = [];

  // Calculate fixed positions for pins in a way that ensures proper spacing
  void _calculatePinPositions() {
    // Define fixed positions that ensure pins are well-spaced
    // These are relative positions within the normalized -1 to 1 range
    _pinPositions.add(Offset(1.0, -0.4));
    _pinPositions.add(Offset(-0.3, -0.7));
    _pinPositions.add(Offset(-0.9, 0.0)); 
    _pinPositions.add(Offset(0.4, -0.1)); 
  }

  // Modified pin building method that uses fixed positions
  Widget _buildAnimatedPin(
    String imagePath,
    Size ellipseSize,
    double pinSize,
    int index,
  ) {
    // Get the pre-calculated position for this pin
    final normalizedPosition = _pinPositions[index];

    // Scale the normalized position to the actual ellipse size, accounting for pin size
    final position = Offset(
      normalizedPosition.dx * (ellipseSize.width - pinSize) / 2.5,
      normalizedPosition.dy * (ellipseSize.height - pinSize) / 2.5,
    );

    // Calculate center position offset
    final centerOffset = Offset(
      ellipseSize.width / 2 - pinSize / 2,
      ellipseSize.height / 2 - pinSize / 2,
    );

    return Positioned(
      left: centerOffset.dx + position.dx,
      top: centerOffset.dy + position.dy,
      child: AnimatedBuilder(
        animation: _pinAnimControllers[index],
        builder: (context, child) {
          // Use a complete sine wave for both horizontal and vertical movement
          final value = _pinAnimControllers[index].value;

          // Create movements with different frequencies to make it look more natural
          // Ensure the sine waves complete full cycles
          final wiggleY = sin(value * 2 * pi) * 3.0;

          // Use a different frequency for horizontal movement
          final wiggleX = sin(value * 2 * pi + (index * pi / 2)) * 2.0;

          return Transform.translate(
            offset: Offset(wiggleX, wiggleY),
            child: child,
          );
        },
        child: Image.asset(
          imagePath,
          width: pinSize,
          height: pinSize,
          fit: BoxFit.contain,
        ),
      ),
    );
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
                  final contentWidth = maxWidth * 1; // full width for now

                  // Size for the circle and pins
                  final circleSize = Size(contentWidth * 1, contentWidth * 0.8);
                  final pinSize = circleSize.width * 0.3;

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
                                // Circular area with pins
                                SizedBox(
                                  width: circleSize.width,
                                  height: circleSize.height,
                                  child: Stack(
                                    children: [
                                      // Circle/ellipse background
                                      Center(
                                        child: Image.asset(
                                          'assets/images/landing_circle_small.png',
                                          width: circleSize.width,
                                          height: circleSize.height,
                                          fit: BoxFit.contain,
                                        ),
                                      ),

                                      // Animated pins with repeating animations
                                      _buildAnimatedPin(
                                        'assets/images/landing_man1_small.png',
                                        circleSize,
                                        pinSize,
                                        0,
                                      ),
                                      _buildAnimatedPin(
                                        'assets/images/landing_woman1_small.png',
                                        circleSize,
                                        pinSize,
                                        1,
                                      ),
                                      _buildAnimatedPin(
                                        'assets/images/landing_man2_small.png',
                                        circleSize,
                                        pinSize,
                                        2,
                                      ),
                                      _buildAnimatedPin(
                                        'assets/images/landing_woman2_small.png',
                                        circleSize,
                                        pinSize,
                                        3,
                                      ),
                                    ],
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
