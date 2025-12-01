import 'package:flutter/material.dart';
import '../database.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = '';
  String email = '';
  String phone = '';
  String address = '';
  String birthdate = '';
  String avatarUrl = 'https://i.pravatar.cc/150?img=3';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};

    username = args['username'] ?? '';
    email = args['email'] ?? '';

    _loadUserData();
  }

  void _loadUserData() {
    if (usersDatabase.containsKey(email)) {
      phone = usersDatabase[email]!['phone'] ?? '';
      address = usersDatabase[email]!['address'] ?? '';
      birthdate = usersDatabase[email]!['birthdate'] ?? '';
      username = usersDatabase[email]!['username'] ?? '';
    } else {
      phone = '';
      address = '';
      birthdate = '';
    }
  }


  Future<void> editField(String title, String currentValue) async {
    final newValue = await showDialog<String>(
      context: context,
      builder: (_) {
        final controller = TextEditingController(text: currentValue);
        return AlertDialog(
          title: Text('Edit $title'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), child: Text('Save')),
          ],
        );
      },
    );

    if (newValue != null && newValue.isNotEmpty && newValue != currentValue) {

      setState(() {

        if (title == 'Email') {
          final userData = usersDatabase[email]!;
          usersDatabase[newValue] = userData;
          usersDatabase.remove(email);
          email = newValue;

        } else if (usersDatabase.containsKey(email)) {
          switch (title) {
            case 'Username':
              usersDatabase[email]!['username'] = newValue;
              break;
            case 'Phone':
              usersDatabase[email]!['phone'] = newValue;
              break;
            case 'Address':
              usersDatabase[email]!['address'] = newValue;
              break;
            case 'Birthdate':
              usersDatabase[email]!['birthdate'] = newValue;
              break;
          }
        }

        _loadUserData();
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title updated successfully!')));
    }
  }


  Widget buildField(String label, String value) {
    return ListTile(
      title: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value.isEmpty ? 'Not set' : value),
      trailing: IconButton(
        icon: Icon(Icons.edit, color: Colors.blueGrey),
        onPressed: () => editField(label, value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(radius: 60, backgroundImage: NetworkImage(avatarUrl)),
            SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(username, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => editField('Username', username),
                          child: Icon(Icons.edit, color: Colors.blueGrey),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => editField('Email', email),
                      child: Text(email, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: Column(
                children: [
                  buildField('Phone', phone),
                  Divider(height: 1),
                  buildField('Address', address),
                  Divider(height: 1),
                  buildField('Birthdate', birthdate),
                ],
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
              icon: Icon(Icons.logout),
              label: Text('Logout'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}