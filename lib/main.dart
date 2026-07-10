import 'package:flutter/material.dart';
import 'package:unrouter/flutter.dart';

import 'pages/home_page.dart';
import 'pages/docs/docs_index_page.dart';
import 'pages/docs/getting_started_page.dart';
import 'pages/docs/widget_detail_page.dart';
import 'pages/docs/docs_shell.dart';
import 'services/docs_loader.dart';
import 'services/browser_history.dart';
import 'services/widget_loader.dart';
import 'theme/arcade_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await WidgetLoader.initialize();
  await DocsLoader.preload([
    'getting-started',
    ...WidgetLoader.widgets.map((widget) => widget.docPath).nonNulls,
  ]);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Arcade UI',
      debugShowCheckedModeBanner: false,
      theme: createArcadeTheme(),
      routerConfig: createRouterConfig(_router),
    );
  }
}

final _router = createRouter(
  history: BrowserHistory(),
  routes: [
    Inlet(path: '/', view: HomePage.new),
    Inlet(path: '/get-started', view: _GettingStartedRoute.new),
    Inlet(
      path: '/widgets',
      view: DocsShell.new,
      children: [
        Inlet(path: '/', view: DocsIndexPage.new),
        Inlet(path: ':group/:name', view: _WidgetDetailRoute.new),
      ],
    ),
  ],
);

class _GettingStartedRoute extends StatelessWidget {
  const _GettingStartedRoute();

  @override
  Widget build(BuildContext context) {
    return const DocsShell(child: GettingStartedPage());
  }
}

class _WidgetDetailRoute extends StatelessWidget {
  const _WidgetDetailRoute({super.key});

  @override
  Widget build(BuildContext context) {
    final params = useRouteParams(context);
    final group = params.required('group');
    final name = params.required('name');
    return WidgetDetailPage(group: group, name: name);
  }
}
