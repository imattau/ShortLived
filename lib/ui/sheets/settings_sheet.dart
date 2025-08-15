import 'package:flutter/material.dart';
import 'key_management_sheet.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 36,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: const Text('Settings',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.vpn_key),
              title: const Text('Key management'),
              subtitle: const Text('Import/export, rotate, clear'),
              onTap: () => showModalBottomSheet(
                context: context,
                backgroundColor: Colors.black,
                isScrollControlled: true,
                builder: (_) => const KeyManagementSheet(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

