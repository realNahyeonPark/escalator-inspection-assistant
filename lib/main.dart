import 'package:flutter/material.dart';
import 'screens/inspection_screen.dart';
import 'screens/main_shell.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elevator/Escalator Inspection App',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xfff5f5f5),
        primaryColor: const Color(0xff4c6ef5),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const MainShell(),
        '/inspect': (_) => const InspectionScreen(),
      },
    );
  }
}