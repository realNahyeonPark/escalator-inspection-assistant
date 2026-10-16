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
      // [변경] 시작 화면: 설비 스캔 → 스캔 성공 시 '/inspect' 로 이동
      // (기존: home: const InspectionScreen())
      initialRoute: '/',
      routes: {
        '/': (_) => const MainShell(),
        '/inspect': (_) => const InspectionScreen(),
      },
    );
  }
}