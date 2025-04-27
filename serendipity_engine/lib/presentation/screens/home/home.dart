import 'package:flutter/material.dart';
//import 'current_matches.dart';
//import 'past_matches.dart';
//import 'my_profile.dart';


class Home extends StatefulWidget {
  Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentPage = 0;
  List<Widget> pages = [
    Center(child: Text('Home')),
    Center(child: Text('History')),
    Center(child: Text('Profile')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentPage],
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