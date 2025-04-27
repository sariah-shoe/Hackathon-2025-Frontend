import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'home.dart';
import 'package:http/http.dart' as http;

Future<http.Response> auth(username, password) async {
  final response = await http.post(
    Uri.parse(
      'https://teaching-neutral-rattler.ngrok-free.app/api/auth/token/',
    ),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: jsonEncode({'email': username, 'password': password}),
  );

  return (response);
}

// Define a custom Form widget.
class Login extends StatefulWidget {

  const Login({super.key});

  @override
  LoginState createState() {
    return LoginState();
  }
}

// Define a corresponding State class.
// This class holds data related to the form.
class LoginState extends State<Login> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<LoginState>.
  final _formKey = GlobalKey<FormState>();

  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Add TextFormFields and ElevatedButton here.
            Text("Username"),
            TextFormField(controller: usernameController),
            Text("Password"),
            TextFormField(controller: passwordController),
            ElevatedButton(
              onPressed: () {
                debugPrint(
                  "Username: ${usernameController.text} Password: ${passwordController.text}",
                );
                http.Response result = auth(
                  usernameController.text,
                  passwordController.text,
                );
                debugPrint('Returned result ${result.statusCode}');
                if (result.statusCode == 200) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Home()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Username or password incorrect')),
                  );
                }
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}

extension on Future<http.Response> {
  get statusCode => null;
}
