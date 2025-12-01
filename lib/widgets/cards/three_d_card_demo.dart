import 'package:flutter/material.dart';
import 'three_d_card.dart';

/// Demo widget for ThreeDCard showcasing an "Apple Vision Pro" style card
class ThreeDCardDemo extends StatelessWidget {
  const ThreeDCardDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final primaryColor = Theme.of(context).primaryColor;

    return Center(
      child: ThreeDCard(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        hoverDecoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.2),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              ThreeDCardItem(
                translateZ: 40,
                child: const Text(
                  'Apple Vision Pro',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Description
              ThreeDCardItem(
                translateZ: 50,
                child: Text(
                  'Welcome to the era of spatial computing.',
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
              const SizedBox(height: 16),
              // Image
              ThreeDCardItem(
                translateZ: 80,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1713869820987-519844949a8a?q=80&w=3500&auto=format&fit=crop',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ThreeDCardItem(
                    translateZ: 30,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text('Learn more →'),
                    ),
                  ),
                  ThreeDCardItem(
                    translateZ: 40,
                    child: FilledButton.icon(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text(
                        'Buy',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
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
