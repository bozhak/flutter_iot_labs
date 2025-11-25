import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';
import 'home_page.dart';
import '../database.dart';

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

  void signUp() {
    String email = _emailController.text;
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (email.contains('@') && username.isNotEmpty && password.length >= 6) {
      usersDatabase[email] = {'username': username, 'password': password};

      // !!! ВИПРАВЛЕНО: Перехід на HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(), // <--- Тепер веде на Home
          settings: RouteSettings(arguments: {
            'username': username,
            'email': email,
          }),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid information')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... (решта коду build залишається незмінною) ...
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Welcome', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text('Sign up to continue', style: TextStyle(fontSize: 18)),
                SizedBox(height: 26),
                CustomTextField(controller: _usernameController, labelText: 'Full Name'),
                SizedBox(height: 16),
                CustomTextField(controller: _emailController, labelText: 'Email'),
                SizedBox(height: 16),
                CustomTextField(controller: _passwordController, labelText: 'Password', obscureText: true),
                SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  height: 49,
                  child: ElevatedButton(
                    onPressed: signUp,
                    child: Text('Sign Up'),
                  ),
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text("Already have an account? Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}