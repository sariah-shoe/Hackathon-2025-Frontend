import 'package:flutter/material.dart';
import 'ptest.dart';

class Academic extends StatelessWidget {
  const Academic({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Step 2 of 3 - Academics'),
        centerTitle: true,
      ),
      body: const Center(child: Text('This is the Academic Page')),
    );
  }
}
