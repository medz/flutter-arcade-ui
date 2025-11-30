import 'package:flutter/material.dart';
import 'floating_dock.dart';

/// Simple and elegant demo for FloatingDock
class FloatingDockDemo extends StatelessWidget {
  const FloatingDockDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FloatingDock(
        items: [
          FloatingDockItem(
            icon: const Icon(Icons.home, size: 24),
            title: 'Home',
            onTap: () {},
          ),
          FloatingDockItem(
            icon: const Icon(Icons.search, size: 24),
            title: 'Search',
            onTap: () {},
          ),
          FloatingDockItem(
            icon: const Icon(Icons.favorite, size: 24),
            title: 'Favorites',
            onTap: () {},
          ),
          FloatingDockItem(
            icon: const Icon(Icons.person, size: 24),
            title: 'Profile',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
