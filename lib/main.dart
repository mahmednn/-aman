import 'package:flutter/material.dart';
import 'package:flutter_application_11/logn_screen.dart';
import 'package:flutter_application_11/signup_screen.dart';

void main() {
 WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Tajawal'),
      home: LoginScreen(),
    ),
  );
}
