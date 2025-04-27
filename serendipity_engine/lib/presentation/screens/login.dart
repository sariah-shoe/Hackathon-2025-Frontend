import 'package:flutter/material.dart';
import 'package:serendipity_engine/presentation/screens/home/home.dart';

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
    body: Form (
      key: _formKey,
      child: Column(
        children: [
          // Add TextFormFields and ElevatedButton here.
          Text("Username"),
          TextFormField(controller: usernameController),
          Text("Password"),
          TextFormField(controller: passwordController),
          ElevatedButton(onPressed: (){
            debugPrint("Username: ${usernameController.text} Password: ${passwordController.text}");
            // showDialog(
            //   context: context,
            //   builder: (context) {
            //   return AlertDialog(
            //     // Retrieve the text that the user has entered by using the
            //     // TextEditingController.
            //     content: Text("Username: ${usernameController.text} Password: ${passwordController.text}"),
            //   );
            //   },
            // );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Home())
            );
          },
          child: const Text("Submit"))
        ],
      ),
    )
    );
  }
}