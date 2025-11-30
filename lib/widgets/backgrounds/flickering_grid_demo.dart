import 'package:flutter/material.dart';
import 'flickering_grid.dart';

/// Simple and elegant demo for FlickeringGrid
class FlickeringGridDemo extends StatelessWidget {
  const FlickeringGridDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return FlickeringGrid(
      color: Colors.deepPurple,
      child: Center(
        child: Text(
          'Flickering Grid',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black.withValues(alpha: 0.8),
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
