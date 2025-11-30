import 'package:flutter/material.dart';
import 'black_hole_background.dart';

/// Simple and elegant demo for BlackHoleBackground
class BlackHoleBackgroundDemo extends StatelessWidget {
  const BlackHoleBackgroundDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const BlackHoleBackground(
      child: Center(
        child: Text(
          'Black Hole',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2.0,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black45,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
