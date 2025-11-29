import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'widgets/backgrounds/flickering_grid.dart';
import 'widgets/dock.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.from(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      darkTheme: ThemeData.from(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
      ),
      themeMode: ThemeMode.system,
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
      body: FlickeringGrid(
        color: Colors.green,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Arcade UI',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 80),
              Dock(
                itemScale: 1.5,
                items: [
                  DockIcon(
                    child: Icon(Icons.home, color: Colors.white),
                    onTap: () {},
                  ),
                  DockIcon(
                    child: Icon(Icons.search, color: Colors.white),
                    onTap: () {},
                  ),
                  DockIcon(
                    child: Icon(Icons.mail, color: Colors.white),
                    onTap: () {},
                  ),
                  const DockSeparator(),
                  DockIcon(
                    child: Icon(Icons.notifications, color: Colors.white),
                    onTap: () {},
                  ),
                  DockIcon(
                    child: Icon(Icons.settings, color: Colors.white),
                    onTap: () {},
                  ),
                  DockIcon(
                    child: Icon(Icons.person, color: Colors.white),
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Copy Code',
        onPressed: () async {
          final code = await DefaultAssetBundle.of(
            context,
          ).loadString('lib/widgets/dock.dart');
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
