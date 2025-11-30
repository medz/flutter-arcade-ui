import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/backgrounds/flickering_grid.dart';
import '../widgets/navigations/floating_dock.dart';

/// Homepage with hero section and action buttons
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlickeringGrid(
        color: Colors.deepPurple,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Project title
              Text(
                'Arcade UI',
                style: GoogleFonts.inter(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // Changed for better visibility
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 24),
              // Description
              Text(
                'Create stunning user interfaces with beautifully\ncrafted Flutter widgets.',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  color: Colors.black54, // Changed for better visibility
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 80),
              // Floating dock with functional navigation
              FloatingDock(
                items: [
                  FloatingDockItem(
                    icon: Icon(Icons.rocket_launch, color: Colors.grey[700]),
                    title: 'Get Started',
                    onTap: () {
                      context.go('/get-started');
                    },
                  ),
                  FloatingDockItem(
                    icon: Icon(Icons.widgets, color: Colors.grey[700]),
                    title: 'Widgets',
                    onTap: () {
                      context.go('/widgets');
                    },
                  ),
                  FloatingDockItem(
                    icon: Icon(Icons.search, color: Colors.grey[700]),
                    title: 'Search',
                    onTap: () {
                      context.go('/widgets');
                      // Open search after navigation
                      Future.delayed(const Duration(milliseconds: 100), () {
                        // This will be handled by DocsShell
                      });
                    },
                  ),
                  FloatingDockItem(
                    icon: Icon(Icons.code, color: Colors.grey[700]),
                    title: 'GitHub',
                    onTap: () {
                      launchUrl(
                        Uri.parse('https://github.com/medz/flutter-arcade-ui'),
                        mode: LaunchMode.externalApplication,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
