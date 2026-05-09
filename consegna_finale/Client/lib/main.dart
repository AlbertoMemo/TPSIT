import 'package:flutter/material.dart';
import 'screens/teams_screen.dart';

void main() => runApp(const CalcioApp());

class CalcioApp extends StatelessWidget {
  const CalcioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calcio DB',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF00D4AA),
          surface: const Color(0xFF161921),
        ),
        scaffoldBackgroundColor: const Color(0xFF0D0F14),
        fontFamily: 'sans-serif',
      ),
      home: const TeamsScreen(),
    );
  }
}
