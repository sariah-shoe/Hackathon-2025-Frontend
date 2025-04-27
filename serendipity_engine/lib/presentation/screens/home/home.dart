import 'package:flutter/material.dart';
import 'package:serendipity_engine/presentation/screens/current_matches.dart';
import 'package:serendipity_engine/presentation/screens/past_matches.dart';
import 'package:serendipity_engine/presentation/screens/my_profile.dart';
import 'package:serendipity_engine/services/location.dart'; // Import the location service
import 'package:flutter/foundation.dart'; // For debugPrint

class Home extends StatefulWidget {
  Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentPage = 0;
  
  // Use the actual page widgets instead of placeholders
  late List<Widget> pages;
  
  @override
  void initState() {
    super.initState();
    _initializeLocationService(); // Call the location service initialization
    pages = [
      const CurrentMatches(), // "Find People" tab - pending connections
      const PastMatches(),    // "Connections" tab - existing connections
      const MyProfile(),      // "My Profile" tab - profile with logout button
    ];
  }

  // Method to initialize the location service
  void _initializeLocationService() async {
    try {
      await startLocationService();
      debugPrint("Location service started from Home screen.");
    } catch (e) {
      debugPrint("Failed to start location service from Home screen: $e");
      // Optionally, show a dialog or snackbar to the user
      // For example:
      // if (mounted) { // Check if the widget is still in the tree
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Failed to start location services: ${e.toString()}')),
      //   );
      // }
    }
  }

  @override
  void dispose() {
    stopLocationService(); // Stop the location service when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentPage],
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.people_alt_outlined), 
            selectedIcon: Icon(Icons.people_alt),
            label: "Find People"
          ),
          NavigationDestination(
            icon: Icon(Icons.handshake_outlined), 
            selectedIcon: Icon(Icons.handshake),
            label: "Connections"
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline), 
            selectedIcon: Icon(Icons.person),
            label: "My Profile"
          )
        ],
        onDestinationSelected: (int index){
          setState(() {
            currentPage = index;
          });
        },
        selectedIndex: currentPage,
      ),
    );
  }
}