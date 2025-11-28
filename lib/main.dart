import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'widgets/backgrounds/flickering_grid.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

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
      title: r"Flutter Arcade UI",
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const FlickeringGrid(
        color: Colors.green,
        child: Center(
          child: Text(
            'Arcade UI',
            style: TextStyle(fontSize: 36, fontWeight: .w500),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Copy ',
        onPressed: () async {
          final code = await DefaultAssetBundle.of(
            context,
          ).loadString('lib/widgets/backgrounds/flickering_grid.dart');
          await Clipboard.setData(ClipboardData(text: code));
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Copy to clipboard!')));
          }
        },
        child: const Icon(Icons.copy),
      ),
    );
  }
}
