import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chefventory/services/order_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chefventory',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        brightness: Brightness.light,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6F4E37),
          foregroundColor: Colors.white,
        ),
      ),
      home: const OrderScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
