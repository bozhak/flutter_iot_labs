import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';
import 'signup_page.dart';
import 'profile_page.dart';
import '../database.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void login() {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (usersDatabase.containsKey(email)) {
      if (usersDatabase[email]!['password'] == password) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(),
            settings: RouteSettings(arguments: {
              'username': usersDatabase[email]!['username'],
              'email': email,
            }),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Incorrect password')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile does not exist. Please sign up first.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Welcome', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              SizedBox(height: 6),
              Text('Login to continue', style: TextStyle(fontSize: 18)),
              SizedBox(height: 26),
              CustomTextField(controller: _emailController, labelText: 'Email'),
              SizedBox(height: 16),
              CustomTextField(controller: _passwordController, labelText: 'Password', obscureText: true),
              SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                height: 49,
                child: ElevatedButton(
                  onPressed: login,
                  child: Text('Login'),
                ),
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SignUpPage()),
                ),
                child: Text("Don't have an account? Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
