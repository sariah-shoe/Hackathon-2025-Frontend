import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(destinations: [
        NavigationDestination(icon: Icon(Icons.home), label: "Homepage"),
        NavigationDestination(icon: Icon(Icons.waving_hand_outlined), label: "Past Connections"),
        NavigationDestination(icon: Icon(Icons.person), label: "My Profile")
      ],
      onDestinationSelected: (int index){
        setState(() {
          currentPage = index;
        });
      },
      selectedIndex: currentPage,),
    );
  }
}