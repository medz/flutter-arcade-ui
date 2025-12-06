import 'package:flutter/material.dart';
import 'gliding_glow_box.dart';

/// Simple and elegant demo for GlidingGlowBox
class GlidingGlowBoxDemo extends StatelessWidget {
  const GlidingGlowBoxDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: GlidingGlowBox(
          color: Colors.cyan,
          borderWidth: 4,
          borderRadius: 16,
          glowPadding: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Gliding Glow Box',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
