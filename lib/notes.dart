import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  TextEditingController controller = TextEditingController();
  String noteText = '';

  @override
  void initState() {
    super.initState();
    loadNote();
  }

  Future<void> saveNote() async {
    await dbRef.child("users/$userId/notes").set(noteText);
  }

  Future<void> loadNote() async {
    final snapshot = await dbRef.child("users/$userId/notes").get();
    if (snapshot.value != null) {
      noteText = snapshot.value.toString();
      controller.text = noteText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Notes"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              onChanged: (String text) {
                noteText = text;
              },
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Type your note here...',
                border: InputBorder.none,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    saveNote();
    super.dispose();
  }
}
