import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  TextEditingController controller = TextEditingController();
  List<String> reminders = [];

  @override
  void initState() {
    super.initState();
    loadReminders();
  }

  Future<void> saveReminders() async {
    await dbRef.child("users/$userId/reminders").set(reminders);
  }
  
  Future<void> loadReminders() async {
    final snapshot = await dbRef.child("users/$userId/reminders").get();
    if (snapshot.value != null) {
      setState(() {
        reminders = List<String>.from(snapshot.value as List);
      });
    }
  }

  void addReminder() {
    String text = controller.text;

    if (text.isNotEmpty) {
      setState(() {
        reminders.add(text);
        controller.clear();
      });

      saveReminders();
    }
  }

  void deleteReminder(int index) {
    setState(() {
      reminders.removeAt(index);
    });

    saveReminders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Reminders"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: controller,
              onSubmitted: (String text) {
                addReminder();
              },
              decoration: InputDecoration(
                hintText: 'Enter a reminder...',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: addReminder,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: reminders.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(reminders[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        deleteReminder(index);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    saveReminders();
    super.dispose();
  }
}
