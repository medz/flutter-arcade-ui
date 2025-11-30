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
      child: Center(
        child: Dock(
          items: [
            _buildDockIcon(Icons.home, Colors.blue),
            _buildDockIcon(Icons.mail, Colors.red),
            _buildDockIcon(Icons.folder, Colors.orange),
            const DockSeparator(),
            _buildDockIcon(Icons.settings, Colors.grey),
          ],
        ),
      ),
    );
  }

  DockIcon _buildDockIcon(IconData icon, Color color) {
    return DockIcon(
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
      onTap: () {},
    );
  }
}
