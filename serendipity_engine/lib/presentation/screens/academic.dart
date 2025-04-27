import 'package:flutter/material.dart';

class academic extends StatelessWidget {
  const academic({super.key});

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
