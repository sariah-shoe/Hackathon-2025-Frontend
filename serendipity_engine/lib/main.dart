import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:serendipity_engine/presentation/screens/landing_page.dart';
import 'package:serendipity_engine/presentation/screens/home/home.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  // Ensure Flutter is initialized before accessing native code
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serendipity Engine',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthCheck(),
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  _AuthCheckState createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      // Get the stored token
      final accessToken = await _secureStorage.read(key: 'access_token');
      
      // Debug log
      debugPrint('Auth check - Access token: ${accessToken != null ? 'Found' : 'Not found'}');
      
      // Delay a bit to allow the splash screen to show
      await Future.delayed(const Duration(seconds: 1));
      
      // Navigate to the appropriate screen based on authentication status
      if (accessToken != null) {
        // User is logged in, navigate to home
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Home()),
        );
      } else {
        // User is not logged in, navigate to landing page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LandingPage()),
        );
      }
    } catch (e) {
      // If there's an error, default to not logged in
      debugPrint('Error checking authentication: ${e.toString()}');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LandingPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Display a loading screen while checking authentication
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Serendipity Engine',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
            const SizedBox(height: 32),
            const Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}