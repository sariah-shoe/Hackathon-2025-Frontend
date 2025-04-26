import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome!', style: const TextStyle(color: Colors.red)),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
    );
  }
}
