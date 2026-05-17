import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Add this
import 'screens/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // handshake between flutter framework and andriod
  await Firebase.initializeApp();//initializes firebase sdk, for authentication
  runApp(const MaterialApp( 
    debugShowCheckedModeBanner: false, 
    home: EntryPage(),
  ));
}       