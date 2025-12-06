import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const MessageSearchApp());
}

class MessageSearchApp extends StatefulWidget {
  const MessageSearchApp({super.key});

  @override
  State<MessageSearchApp> createState() => _MessageSearchAppState();
}

class _MessageSearchAppState extends State<MessageSearchApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Message Search',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: WelcomeScreen(
        onThemeChanged: _toggleTheme,
        currentThemeIsDark: _themeMode == ThemeMode.dark,
      ),
    );
  }
}
