import 'package:flutter/material.dart';

import 'audio_routes.dart';

/// Shows the mini-player except on the full now-playing route.
class MiniPlayerVisibilityObserver extends NavigatorObserver {
  MiniPlayerVisibilityObserver(this.onVisibilityChanged);

  final ValueChanged<bool> onVisibilityChanged;

  void _sync(Route<dynamic>? route) {
    onVisibilityChanged(!AudioRoutes.isNowPlaying(route));
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _sync(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _sync(previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _sync(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _sync(newRoute);
  }
}
