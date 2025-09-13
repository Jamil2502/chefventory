// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(Chefventory());
}

class Chefventory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chefventory',
      home: Scaffold(
        appBar: AppBar(title: Text('Chefventory')),
        body: Center(
          child: Text('Firebase Setup Complete!'),
        ),
      ),
    );
  }
}