import 'package:flutter/material.dart';

/// Shared root navigator for routes that must open without a reliable
/// [BuildContext] (e.g. rewarded callbacks after a fullscreen ad dismisses).
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
