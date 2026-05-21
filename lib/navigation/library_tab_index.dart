import 'package:flutter/material.dart';

/// Current bottom-nav tab index for the library shell root route.
class LibraryTabIndex extends InheritedWidget {
  const LibraryTabIndex({
    super.key,
    required this.index,
    required super.child,
  });

  final int index;

  static int of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LibraryTabIndex>();
    assert(scope != null, 'LibraryTabIndex not found');
    return scope!.index;
  }

  @override
  bool updateShouldNotify(LibraryTabIndex oldWidget) => oldWidget.index != index;
}
