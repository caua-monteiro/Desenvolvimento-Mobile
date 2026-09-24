import 'package:flutter/material.dart';
import 'view/home_page.dart';

void main() => runApp(const InverTextoApp());

class InverTextoApp extends StatelessWidget {
  const InverTextoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'InverTexto',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6544B9)),
      scaffoldBackgroundColor: const Color(0xFFF8F7FC),
      useMaterial3: true,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    ),
    home: const HomePage(),
  );
}
