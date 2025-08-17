import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'drawers.dart';
import 'search_drawer.dart';

class DrawerHost extends StatelessWidget {
  final Drawers controller;
  const DrawerHost({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (!controller.isOpen) return const SizedBox.shrink();

        final Widget panel = switch (controller.current) {
          DrawerType.search => SearchDrawer(onClose: controller.close),
          _ => const SizedBox(),
        };

        return Shortcuts(
          shortcuts: const <LogicalKeySet, Intent>{
            LogicalKeySet(LogicalKeyboardKey.escape): DismissIntent(),
          },
          child: Actions(
            actions: <Type, Action<Intent>>{
              DismissIntent: CallbackAction<DismissIntent>(
                onInvoke: (_) {
                  controller.close();
                  return null;
                },
              ),
            },
            child: Stack(
              children: [
                // Scrim that also closes on tap.
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: controller.isOpen ? 0.45 : 0.0,
                    duration: const Duration(milliseconds: 150),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: controller.close,
                      child: const ColoredBox(color: Colors.black),
                    ),
                  ),
                ),
                Align(alignment: Alignment.centerRight, child: panel),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DismissIntent extends Intent {
  const DismissIntent();
}
