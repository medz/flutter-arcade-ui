import 'package:flutter/material.dart';

import 'widgets/backgrounds/flickering_grid.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: .from(
        useMaterial3: true,
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      darkTheme: .from(
        useMaterial3: true,
        colorScheme: .fromSeed(seedColor: Colors.deepPurple, brightness: .dark),
      ),
      themeMode: .system,
      title: r"Sevent's Flutter Arcade",
      home: Scaffold(body: const FlickeringGrid(color: Colors.green)),
    );
  }
}
