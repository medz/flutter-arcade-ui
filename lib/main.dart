import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'pages/home_page.dart';
import 'pages/docs/docs_index_page.dart';
import 'pages/docs/getting_started_page.dart';
import 'pages/docs/widgets_list_page.dart';
import 'pages/docs/widget_detail_page.dart';

void main() {
  // Configure URL strategy for Flutter Web to use path-based URLs
  usePathUrlStrategy();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Arcade UI',
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
    GoRoute(path: '/docs', builder: (context, state) => const DocsIndexPage()),
    GoRoute(
      path: '/docs/getting-started',
      builder: (context, state) => const GettingStartedPage(),
    ),
    GoRoute(
      path: '/docs/widgets',
      builder: (context, state) => const WidgetsListPage(),
    ),
    GoRoute(
      path: '/docs/:group/:name',
      builder: (context, state) {
        final group = state.pathParameters['group']!;
        final name = state.pathParameters['name']!;
        return WidgetDetailPage(group: group, name: name);
      },
    ),
  ],
);
