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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push
              }
              )
          ],
        ),
      ),
    );
  }
}
