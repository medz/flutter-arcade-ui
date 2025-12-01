import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'pages/home_page.dart';
import 'pages/docs/docs_index_page.dart';
import 'pages/docs/getting_started_page.dart';

import 'pages/docs/widget_detail_page.dart';
import 'pages/docs/docs_shell.dart';

import 'services/widget_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Configure URL strategy for Flutter Web to use path-based URLs
  usePathUrlStrategy();

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
      themeMode: ThemeMode.light,
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    ShellRoute(
      builder: (context, state, child) {
        return DocsShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/get-started',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const GettingStartedPage(),
          ),
        ),
        GoRoute(
          path: '/widgets',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const DocsIndexPage(),
          ),
        ),
        GoRoute(
          path: '/widgets/:group/:name',
          pageBuilder: (context, state) {
            final group = state.pathParameters['group']!;
            final name = state.pathParameters['name']!;
            return NoTransitionPage(
              key: state.pageKey,
              child: WidgetDetailPage(group: group, name: name),
            );
          },
        ),
      ],
    ),
  ],
);
