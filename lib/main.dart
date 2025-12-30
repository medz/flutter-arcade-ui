import 'package:flutter/material.dart';
import 'package:unrouter/unrouter.dart';
// ignore: implementation_imports
import 'package:unrouter/src/router/url_strategy.dart';
import 'pages/home_page.dart';
import 'pages/docs/docs_index_page.dart';
import 'pages/docs/getting_started_page.dart';

import 'pages/docs/widget_detail_page.dart';
import 'pages/docs/docs_shell.dart';

import 'services/widget_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize widget loader
  await WidgetLoader.initialize();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fluter Arcade UI',
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
      routerConfig: _router,
    );
  }
}

final _router = Unrouter(
  strategy: UrlStrategy.browser,
  routes: const [
    Inlet(factory: HomePage.new),
    Inlet(
      factory: DocsShell.new,
      children: [
        Inlet(path: 'get-started', factory: GettingStartedPage.new),
        Inlet(path: 'widgets', factory: DocsIndexPage.new),
        Inlet(path: 'widgets/:group/:name', factory: _WidgetDetailRoute.new),
      ],
    ),
  ],
);

class _WidgetDetailRoute extends StatelessWidget {
  const _WidgetDetailRoute({super.key});

  @override
  Widget build(BuildContext context) {
    final group = context.params['group']!;
    final name = context.params['name']!;
    return WidgetDetailPage(group: group, name: name);
  }
}
