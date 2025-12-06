import 'package:flutter/material.dart';
import 'motion_tabs.dart';

class MotionTabsDemo extends StatefulWidget {
  const MotionTabsDemo({super.key});

  @override
  State<MotionTabsDemo> createState() => _MotionTabsDemoState();
}

class _MotionTabsDemoState extends State<MotionTabsDemo> {
  int _index = 0;

  static const _titles = [
    'Crafting bold landing pages',
    'Polishing motion details',
    'Shipping API handoffs',
    'Preparing beta invites',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B1229), Color(0xFF0E1636)],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Workflow',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white70,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 12),
                MotionTabs(
                  initialIndex: _index,
                  onChanged: (i) => setState(() => _index = i),
                  backgroundColor: const Color(0xFF5A5FFF),
                  overlayColor: const Color(0x33FFFFFF),
                  selectedColor: Colors.white,
                  textColor: Colors.white.withValues(alpha: 0.86),
                  selectedTextColor: const Color(0xFF1C1F3E),
                  height: 58,
                  borderRadius: 18,
                  gap: 10,
                  items: const [
                    MotionTabItem(
                      label: 'Overview',
                      icon: Icon(Icons.blur_on_rounded),
                    ),
                    MotionTabItem(
                      label: 'Design',
                      icon: Icon(Icons.auto_fix_high_rounded),
                    ),
                    MotionTabItem(
                      label: 'Develop',
                      icon: Icon(Icons.code_rounded),
                    ),
                    MotionTabItem(
                      label: 'Launch',
                      icon: Icon(Icons.rocket_launch_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Row(
                    key: ValueKey(_index),
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF8BE1FF),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _titles[_index],
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
