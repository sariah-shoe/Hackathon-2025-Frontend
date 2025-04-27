import 'package:flutter/material.dart';

class PastMatches extends StatefulWidget {
  const PastMatches({super.key});

  @override
  State<PastMatches> createState() => _PastMatchesState();
}

class _PastMatchesState extends State<PastMatches> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("You are on the past matches page"),
      ),
    );
  }
}