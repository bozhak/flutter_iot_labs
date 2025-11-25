import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proxmox Dashboard',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      initialRoute: '/login',
      routes: {
        '/login': (_) => LoginPage(),
        '/signup': (_) => SignUpPage(),
        '/home': (_) => HomePage(),
        '/profile': (_) => ProfilePage(),
      },
    );
  }
}
