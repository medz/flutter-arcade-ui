import 'dart:js_interop';

import 'package:unrouter/flutter.dart';
import 'package:web/web.dart' as web;

/// Browser history with number-safe state decoding for Dart WebAssembly.
class BrowserHistory extends History {
  BrowserHistory({String base = '/'}) : base = _normalizeBase(base) {
    final state = _readState();
    index = state?.index ?? 0;
    if (state == null) _writeState(replace: true, userData: null);
    web.window.addEventListener('popstate', _popStateListener);
  }

  static const _indexKey = '__arcadeHistoryIndex';
  static const _dataKey = '__arcadeHistoryData';

  @override
  final String base;

  @override
  HistoryAction action = HistoryAction.pop;

  @override
  int? index;

  final _listeners = <HistoryListener>[];
  bool _ignoreNextPop = false;
  late final JSFunction _popStateListener = _didPop.toJS;

  @override
  HistoryLocation get location {
    final browserLocation = web.window.location;
    final search = browserLocation.search;
    final hash = browserLocation.hash;
    return HistoryLocation(
      Uri(
        path: _stripBase(browserLocation.pathname, base),
        query: search.startsWith('?') ? search.substring(1) : search,
        fragment: hash.startsWith('#') ? hash.substring(1) : hash,
      ),
      _readState()?.userData,
    );
  }

  @override
  String createHref(Uri uri) {
    final path = uri.path.isEmpty
        ? '/'
        : (uri.path.startsWith('/') ? uri.path : '/${uri.path}');
    final externalPath = base == '/'
        ? path
        : (path == '/' ? base : '$base$path');
    return uri.replace(path: externalPath).toString();
  }

  @override
  void push(Uri uri, {Object? state}) {
    action = HistoryAction.push;
    index = (index ?? 0) + 1;
    _writeState(userData: state, href: createHref(uri));
  }

  @override
  void replace(Uri uri, {Object? state}) {
    action = HistoryAction.replace;
    _writeState(replace: true, userData: state, href: createHref(uri));
  }

  @override
  void go(int delta, {bool triggerListeners = true}) {
    if (!triggerListeners) _ignoreNextPop = true;
    web.window.history.go(delta);
  }

  @override
  void Function() listen(HistoryListener listener) {
    _listeners.add(listener);
    return () => _listeners.remove(listener);
  }

  @override
  void dispose() {
    web.window.removeEventListener('popstate', _popStateListener);
    _listeners.clear();
  }

  void _writeState({
    required Object? userData,
    bool replace = false,
    String? href,
  }) {
    final state = <String, Object?>{
      _indexKey: index ?? 0,
      _dataKey: userData,
    }.jsify();
    if (replace) {
      web.window.history.replaceState(state, '', href);
    } else {
      web.window.history.pushState(state, '', href);
    }
  }

  _BrowserHistoryState? _readState() {
    final value = web.window.history.state.dartify();
    if (value is! Map) return null;
    final rawIndex = value[_indexKey];
    if (rawIndex is! num) return null;
    return _BrowserHistoryState(
      index: rawIndex.toInt(),
      userData: value[_dataKey],
    );
  }

  void _didPop(web.PopStateEvent _) {
    if (_ignoreNextPop) {
      _ignoreNextPop = false;
      return;
    }
    final previousIndex = index ?? 0;
    final nextIndex = _readState()?.index ?? 0;
    index = nextIndex;
    action = HistoryAction.pop;
    final event = HistoryEvent(
      action: action,
      location: location,
      delta: nextIndex - previousIndex,
    );
    for (final listener in List.of(_listeners)) {
      listener(event);
    }
  }
}

class _BrowserHistoryState {
  final int index;
  final Object? userData;

  const _BrowserHistoryState({required this.index, required this.userData});
}

String _normalizeBase(String base) {
  final trimmed = base.trim();
  if (trimmed.isEmpty || trimmed == '/') return '/';
  final leading = trimmed.startsWith('/') ? trimmed : '/$trimmed';
  return leading.endsWith('/')
      ? leading.substring(0, leading.length - 1)
      : leading;
}

String _stripBase(String path, String base) {
  final normalized = path.startsWith('/') ? path : '/$path';
  if (base == '/') return normalized;
  if (normalized == base) return '/';
  return normalized.startsWith('$base/')
      ? normalized.substring(base.length)
      : normalized;
}
