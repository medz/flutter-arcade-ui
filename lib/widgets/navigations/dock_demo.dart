import 'package:flutter/material.dart';
import 'dock.dart';

/// Simple and elegant demo for Dock
class DockDemo extends StatelessWidget {
  const DockDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(24),
      child: const Center(
        child: Dock(
          items: [
            DockIcon(child: Icon(Icons.home)),
            DockIcon(child: Icon(Icons.mail)),
            DockIcon(child: Icon(Icons.home)),
            DockIcon(child: Icon(Icons.folder)),
            DockSeparator(),
            DockIcon(child: Icon(Icons.settings)),
          ],
        ),
      ),
    );
  }
}
