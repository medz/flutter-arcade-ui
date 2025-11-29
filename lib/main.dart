import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'widgets/backgrounds/black_hole_background.dart';
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
      themeMode: ThemeMode.dark,
      title: 'Flutter Arcade UI',
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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
              'BlackHoleBackground',
              'lib/widgets/backgrounds/black_hole_background.dart',
            ),
            child: const Text('BlackHoleBackground'),
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
      body: PageView(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        children: const [_FlickeringGridPage(), _BlackHolePage()],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Copy Code',
        onPressed: () => _showCopyDialog(context),
        child: const Icon(Icons.copy),
      ),
    );
  }
}

class _FlickeringGridPage extends StatelessWidget {
  const _FlickeringGridPage();

  @override
  Widget build(BuildContext context) {
    return FlickeringGrid(
      color: Colors.green,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Arcade UI',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Create stunning UI with beautifully.',
              style: TextStyle(fontSize: 18, color: Colors.grey[400]),
            ),
            const SizedBox(height: 60),
            FloatingDock(
              items: [
                FloatingDockItem(
                  icon: Icon(Icons.home, color: Colors.grey[700]),
                  title: 'Home',
                  onTap: () {},
                ),
                FloatingDockItem(
                  icon: Icon(Icons.terminal, color: Colors.grey[700]),
                  title: 'Terminal',
                  onTap: () {},
                ),
                FloatingDockItem(
                  icon: Icon(Icons.folder, color: Colors.grey[700]),
                  title: 'Files',
                  onTap: () {},
                ),
                FloatingDockItem(
                  icon: Icon(Icons.settings, color: Colors.grey[700]),
                  title: 'Settings',
                  onTap: () {},
                ),
                FloatingDockItem(
                  icon: Icon(Icons.code, color: Colors.grey[700]),
                  title: 'Code',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 60),
            Icon(Icons.keyboard_arrow_down, size: 32, color: Colors.grey[600]),
            Text(
              'Swipe up to see more',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlackHolePage extends StatelessWidget {
  const _BlackHolePage();

  @override
  Widget build(BuildContext context) {
    return BlackHoleBackground(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Navigations & Back hole',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 60),
            Dock(
              itemScale: 1.5,
              items: [
                DockIcon(
                  child: const Icon(Icons.home, color: Colors.white),
                  onTap: () {},
                ),
                DockIcon(
                  child: const Icon(Icons.search, color: Colors.white),
                  onTap: () {},
                ),
                DockIcon(
                  child: const Icon(Icons.mail, color: Colors.white),
                  onTap: () {},
                ),
                const DockSeparator(),
                DockIcon(
                  child: const Icon(Icons.notifications, color: Colors.white),
                  onTap: () {},
                ),
                DockIcon(
                  child: const Icon(Icons.settings, color: Colors.white),
                  onTap: () {},
                ),
                DockIcon(
                  child: const Icon(Icons.person, color: Colors.white),
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
