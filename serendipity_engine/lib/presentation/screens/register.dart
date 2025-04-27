import 'package:flutter/material.dart';
import 'academic.dart';
import 'create_account.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create an account',
          style: const TextStyle(color: Colors.amber),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Personal Info'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Academics'),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Personality Test',
          ),
        ],
      ),
    );
  }
}
