import 'package:flutter/material.dart';
import 'screens/inspection_screen.dart';

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
      // 설비 스캔 직후 진입하는 화면을 초기 화면으로 설정 (또는 라우터 사용)
      home: const InspectionScreen(),
    );
  }
}