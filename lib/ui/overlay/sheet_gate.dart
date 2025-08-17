import 'package:flutter/material.dart';

/// Simple singleton gate so we never stack multiple sheets.
class SheetGate {
  static Future<void>? _accountMenuFuture;

  static bool get isAccountMenuOpen => _accountMenuFuture != null;

  /// Open the account menu only if not already open.
  static Future<void> openAccountMenu(
    BuildContext context,
    WidgetBuilder builder,
  ) {
    if (_accountMenuFuture != null) return _accountMenuFuture!;
    _accountMenuFuture = showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0E0E11),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: builder,
    ).whenComplete(() {
      _accountMenuFuture = null; // release lock on close
    });
    return _accountMenuFuture!;
  }

  /// Toggle: if open, close; if closed, open.
  static Future<void> toggleAccountMenu(
    BuildContext context,
    WidgetBuilder builder,
  ) async {
    if (_accountMenuFuture != null) {
      Navigator.of(context, rootNavigator: true).maybePop();
      return;
    }
    await openAccountMenu(context, builder);
  }
}
