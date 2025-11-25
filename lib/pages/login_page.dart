import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';
import 'signup_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
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
              Text('Sign In to continue', style: TextStyle(fontSize: 18)),
              SizedBox(height: 26),
              CustomTextField(controller: _usernameController, labelText: 'Username'),
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
                          email: 'no-email@example.com',
                        ),
                      ),
                    );
                  },
                  child: Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SignUpPage()));
                },
                child: Text("Don't have an account? Sign Up", style: TextStyle(color: Colors.grey[700])),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
