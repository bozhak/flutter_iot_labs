import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MagicCounter(),
    );
  }
}

class MagicCounter extends StatefulWidget {
  const MagicCounter({super.key});

  @override
  State<MagicCounter> createState() => _MagicCounterState();
}

class _MagicCounterState extends State<MagicCounter> {
  int counter = 0;
  final TextEditingController controller = TextEditingController();
  String info = "";

  void processInput() {
    final text = controller.text.trim();

    if (text == "Avada Kedavra") {
      setState(() {
        counter = 0;
        info = "💥 Закляття спрацювало! Лічильник скинуто.";
      });
    } else {
      final number = int.tryParse(text);
      if (number != null) {
        setState(() {
          counter += number;
          info = "✅ Додано $number до лічильника";
        });
      } else {
        setState(() {
          info = "⚠ Введи число або 'Avada Kedavra'";
        });
      }
    }

    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Magic Counter"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Лічильник: $counter",
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Введи число або Avada Kedavra",
              ),
              onSubmitted: (_) => processInput(),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: processInput,
              child: const Text("Підтвердити"),
            ),

            const SizedBox(height: 20),

            Text(
              info,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
