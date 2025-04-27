import 'package:flutter/material.dart';
import 'academic.dart'; // import the next page

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //nice way to keep track of registration status
      appBar: AppBar(title: const Text('Step 1 of 3'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Account',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const TextField(decoration: InputDecoration(labelText: 'Email')),
            const TextField(
              decoration: InputDecoration(labelText: 'Password'),
              //hides password, can add in a view password icon?
              obscureText: true,
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Preferred Name'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Interests'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Social Media Links'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              // allows user to go back to the previous page
              onPressed: () {
                Navigator.pop(context); // If you came here from another page
              },
              child: const Text('Back'),
            ),
            ElevatedButton(
              // sends the user to the next page of registration
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Academic()),
                );
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
