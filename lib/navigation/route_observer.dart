import 'package:flutter/widgets.dart';

/// Global [RouteObserver] to track navigation for hiding/showing FABs.
///
/// We observe all [ModalRoute] transitions so pages are notified when any
/// sheet or dialog is pushed above them, not just full page routes.
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

