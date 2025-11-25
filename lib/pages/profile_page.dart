import 'package:flutter/material.dart';
import '../database.dart'; // Переконайтеся, що цей шлях правильний

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

    // Ініціалізація email та username з аргументів
    username = args['username'] ?? '';
    email = args['email'] ?? '';

    // Перше завантаження даних
    _loadUserData();
  }

  // 📥 Функція для перезавантаження всіх залежних даних користувача з бази
  void _loadUserData() {
    // Якщо користувач існує, витягуємо всі його поля
    if (usersDatabase.containsKey(email)) {
      // Оновлюємо змінні стану з даних бази
      phone = usersDatabase[email]!['phone'] ?? '';
      address = usersDatabase[email]!['address'] ?? '';
      birthdate = usersDatabase[email]!['birthdate'] ?? '';
      // Також оновлюємо username, якщо він був змінений іншим чином
      username = usersDatabase[email]!['username'] ?? '';
    } else {
      // Якщо користувача немає (наприклад, після зміни email або помилки)
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

    // Перевірка на успішне збереження та зміну значення
    if (newValue != null && newValue.isNotEmpty && newValue != currentValue) {

      // 🚀 Блок setState гарантує оновлення UI
      setState(() {

        // 1. Оновлення бази даних
        if (title == 'Email') {
          // Логіка оновлення email (ключа)
          final userData = usersDatabase[email]!;
          usersDatabase[newValue] = userData;
          usersDatabase.remove(email);
          email = newValue; // Оновлюємо змінну стану email

        } else if (usersDatabase.containsKey(email)) {
          // Логіка оновлення інших полів
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

        // 2. 🔥 ПОВНЕ ПЕРЕЗАВАНТАЖЕННЯ ДАНИХ З БАЗИ після оновлення
        // Цей виклик синхронізує всі локальні змінні з оновленою мапою.
        _loadUserData();
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title updated successfully!')));
    }
  }


  // buildField тепер не потребує колбеків, оскільки логіка в editField
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
                        // Відображає username зі змінної стану
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
                  // Відображає phone/address/birthdate зі змінних стану
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