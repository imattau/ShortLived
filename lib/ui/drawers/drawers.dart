import 'package:flutter/material.dart';

/// Types of drawers available in the app.
enum DrawerType { search }

/// Controller for app drawers.
class Drawers extends ChangeNotifier {
  bool _open = false;
  DrawerType? _current;

  bool get isOpen => _open;
  DrawerType? get current => _current;

  /// Open a drawer; idempotent if the same drawer is already open.
  void open(DrawerType type) {
    if (_open && _current == type) return;
    _current = type;
    _open = true;
    notifyListeners();
  }

  /// Close any open drawer; idempotent.
  void close() {
    if (!_open) return;
    _open = false;
    _current = null;
    notifyListeners();
  }
}
