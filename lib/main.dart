import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'widgets/backgrounds/flickering_grid.dart';
import 'widgets/navigations/dock.dart';
import 'widgets/navigations/floating_dock.dart';

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      title: r"Flutter Arcade UI",
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  Future<void> _copyWidgetCode(
    BuildContext context,
    String name,
    String path,
  ) async {
    final code = await DefaultAssetBundle.of(context).loadString(path);
    await Clipboard.setData(ClipboardData(text: code));
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name code copied to clipboard!')),
      );
    }
  }

  void _showCopyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Widget to Copy'),
        children: [
          SimpleDialogOption(
            onPressed: () => _copyWidgetCode(
              context,
              'FlickeringGrid',
              'lib/widgets/backgrounds/flickering_grid.dart',
            ),
            child: const Text('FlickeringGrid'),
          ),
          SimpleDialogOption(
            onPressed: () => _copyWidgetCode(
              context,
              'Dock',
              'lib/widgets/navigations/dock.dart',
            ),
            child: const Text('Dock'),
          ),
          SimpleDialogOption(
            onPressed: () => _copyWidgetCode(
              context,
              'FloatingDock',
              'lib/widgets/navigations/floating_dock.dart',
            ),
            child: const Text('FloatingDock'),
          ),
        ],
      ),
    );
  }

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
              const SizedBox(height: 40),
              FloatingDock(
                items: [
                  FloatingDockItem(
                    icon: Icon(Icons.home, color: Colors.grey[700]),
                    onTap: () {},
                  ),
                  FloatingDockItem(
                    icon: Icon(Icons.terminal, color: Colors.grey[700]),
                    onTap: () {},
                  ),
                  FloatingDockItem(
                    icon: Icon(Icons.select_all, color: Colors.grey[700]),
                    onTap: () {},
                  ),
                  FloatingDockItem(
                    icon: Icon(Icons.change_history, color: Colors.grey[700]),
                    onTap: () {},
                  ),
                  FloatingDockItem(
                    icon: Icon(Icons.build, color: Colors.grey[700]),
                    onTap: () {},
                  ),
                  FloatingDockItem(
                    icon: Icon(Icons.close, color: Colors.grey[700]),
                    onTap: () {},
                  ),
                  FloatingDockItem(
                    icon: Icon(Icons.code, color: Colors.grey[700]),
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
        onPressed: () => _showCopyDialog(context),
        child: const Icon(Icons.copy),
      ),
    );
  }
}
