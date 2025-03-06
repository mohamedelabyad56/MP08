import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

const FirebaseOptions firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyCV6uor3QEaatKexgDaoKnYU6mibXm-V2g",
  authDomain: "app-flutter-39723.firebaseapp.com",
  projectId: "app-flutter-39723",
  storageBucket: "app-flutter-39723.firebasestorage.app",
  messagingSenderId: "47574810185",
  appId: "1:47574810185:web:7b17a3e0b23c78ff9ac998",
);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Firebase Setup')),
        body: Center(child: Text('Firebase está configurado 🚀')),
      ),
    );
  }
}
