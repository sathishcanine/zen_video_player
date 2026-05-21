import 'package:flutter/material.dart';

/// Provides the in-shell [Navigator] so audio routes keep the mini-player visible.
class LibraryShellScope extends InheritedWidget {
  const LibraryShellScope({
    super.key,
    required this.stackNavigatorKey,
    required super.child,
  });

  final GlobalKey<NavigatorState> stackNavigatorKey;

  static LibraryShellScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<LibraryShellScope>();
  }

  static NavigatorState? navigatorOf(BuildContext context) {
    return maybeOf(context)?.stackNavigatorKey.currentState;
  }

  @override
  bool updateShouldNotify(LibraryShellScope oldWidget) {
    return oldWidget.stackNavigatorKey != stackNavigatorKey;
  }
}
