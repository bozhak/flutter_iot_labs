import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';
import 'home_page.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              Text('Sign Up to continue', style: TextStyle(fontSize: 18)),
              SizedBox(height: 26),
              CustomTextField(controller: _usernameController, labelText: 'Username'),
              SizedBox(height: 16),
              CustomTextField(controller: _emailController, labelText: 'Email'),
              SizedBox(height: 16),
              CustomTextField(controller: _passwordController, labelText: 'Password', obscureText: true),
              SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                height: 49,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomePage(
                          username: _usernameController.text,
                          email: _emailController.text,
                        ),
                      ),
                    );
                  },
                  child: Text('Sign Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text("Already have an account? Login", style: TextStyle(color: Colors.grey[700])),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
