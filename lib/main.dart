import 'package:flutter/material.dart';

import 'widgets/flickering_grid.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: r"Seven's Arcade",
      home: const FlickeringGrid(color: Colors.red),
    );
  }
}
