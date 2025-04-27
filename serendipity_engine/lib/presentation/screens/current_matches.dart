import 'package:flutter/material.dart';

class CurrentMatches extends StatefulWidget {
  const CurrentMatches({super.key});

  @override
  State<CurrentMatches> createState() => _CurrentMatchesState();
}

class _CurrentMatchesState extends State<CurrentMatches> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("You are on the current matches page"),
      ),
    );
  }
}