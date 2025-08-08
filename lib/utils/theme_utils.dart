import 'package:flutter/material.dart';

InputDecorationTheme _inputStyleDecorationTheme() {
  return const InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(),
  );
}

ThemeData getThemeForMood(String mood) {
  switch (mood.toLowerCase()) {
    case 'happy':
      return ThemeData(
        primarySwatch: Colors.yellow,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.yellow.shade50,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.amber),
        inputDecorationTheme: _inputStyleDecorationTheme(),
        useMaterial3: true,
      );

    case 'sad':
      return ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.blueGrey.shade900,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.blue),
        inputDecorationTheme: _inputStyleDecorationTheme(),
        useMaterial3: true,
      );

    case 'angry':
      return ThemeData(
        primarySwatch: Colors.red,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.red.shade900,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.redAccent),
        inputDecorationTheme: _inputStyleDecorationTheme(),
        useMaterial3: true,
      );

    case 'fearful':
    case 'fear':
      return ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.deepPurple.shade900,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.deepPurple),
        inputDecorationTheme: _inputStyleDecorationTheme(),
        useMaterial3: true,
      );

    case 'neutral':
    case 'calm':
      return ThemeData(
        primarySwatch: Colors.grey,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey.shade200,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.grey),
        inputDecorationTheme: _inputStyleDecorationTheme(),
        useMaterial3: true,
      );

    case 'disgust':
      return ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.green.shade900,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.greenAccent),
        inputDecorationTheme: _inputStyleDecorationTheme(),
        useMaterial3: true,
      );

    case 'surprised':
    case 'surprise':
      return ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.orange.shade50,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepOrangeAccent,
        ),
        inputDecorationTheme: _inputStyleDecorationTheme(),
        useMaterial3: true,
      );

    default:
      return ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.teal.shade50,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.teal),
        inputDecorationTheme: _inputStyleDecorationTheme(),
        useMaterial3: true,
      );
  }
}
