import 'package:flutter/material.dart';

import 'library_shell_scope.dart';

/// Wraps a shell stack route so Android predictive back pops the shell, not the app.
class LibraryRoutePage extends StatelessWidget {
  const LibraryRoutePage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        LibraryNavigation.handleSystemBack(context);
      },
      child: child,
    );
  }
}

/// Pushes library sub-routes on the shell [Navigator] (keeps mini-player + bottom nav).
abstract final class LibraryNavigation {
  static NavigatorState? shellNavigator(BuildContext context) {
    return LibraryShellScope.navigatorOf(context);
  }

  static Future<T?> push<T>(BuildContext context, Widget page) {
    final nav = shellNavigator(context);
    final route = MaterialPageRoute<T>(builder: (_) => page);
    if (nav != null) {
      return nav.push<T>(route);
    }
    return Navigator.of(context).push<T>(route);
  }

  static Future<T?> pushRoute<T>(BuildContext context, Route<T> route) {
    final nav = shellNavigator(context);
    if (nav != null) {
      return nav.push<T>(route);
    }
    return Navigator.of(context).push<T>(route);
  }

  static void pop<T>(BuildContext context, [T? result]) {
    final nav = shellNavigator(context);
    if (nav != null && nav.canPop()) {
      nav.pop<T>(result);
      return;
    }
    final fallback = Navigator.of(context);
    if (fallback.canPop()) {
      fallback.pop<T>(result);
    }
  }

  /// Handles system / predictive back when a route sits on the shell stack.
  static bool handleSystemBack(BuildContext context) {
    final nav = shellNavigator(context);
    if (nav != null && nav.canPop()) {
      nav.pop();
      return true;
    }
    final fallback = Navigator.of(context);
    if (fallback.canPop()) {
      fallback.pop();
      return true;
    }
    return false;
  }
}
