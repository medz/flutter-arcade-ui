import 'package:flutter/material.dart';
import 'space_shooter.dart';

/// Demo widget showcasing the SpaceShooter game with difficulty controls
class SpaceShooterDemo extends StatefulWidget {
  const SpaceShooterDemo({super.key});

  @override
  State<SpaceShooterDemo> createState() => _SpaceShooterDemoState();
}

class _SpaceShooterDemoState extends State<SpaceShooterDemo> {
  // Difficulty settings
  int _initialScore = 10;
  int _enemySpawnInterval = 1500;
  double _enemySpeed = 2.0;
  double _bulletSpeed = 5.0;

  // Presets
  static const Map<String, Map<String, dynamic>> _presets = {
    'Easy': {
      'score': 20,
      'spawnInterval': 2000,
      'enemySpeed': 1.5,
      'bulletSpeed': 6.0,
    },
    'Normal': {
      'score': 10,
      'spawnInterval': 1500,
      'enemySpeed': 2.0,
      'bulletSpeed': 5.0,
    },
    'Hard': {
      'score': 10,
      'spawnInterval': 1000,
      'enemySpeed': 3.0,
      'bulletSpeed': 4.5,
    },
    'Nightmare': {
      'score': 5,
      'spawnInterval': 600,
      'enemySpeed': 4.0,
      'bulletSpeed': 4.0,
    },
  };

  String _selectedPreset = 'Normal';
  bool _showSettings = true;

  void _applyPreset(String preset) {
    final settings = _presets[preset]!;
    setState(() {
      _selectedPreset = preset;
      _initialScore = settings['score'] as int;
      _enemySpawnInterval = settings['spawnInterval'] as int;
      _enemySpeed = settings['enemySpeed'] as double;
      _bulletSpeed = settings['bulletSpeed'] as double;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Game (full size)
          SpaceShooter(
            key: ValueKey(
              '$_selectedPreset-$_initialScore-$_enemySpawnInterval-$_enemySpeed-$_bulletSpeed',
            ),
            initialScore: _initialScore,
            enemySpawnInterval: _enemySpawnInterval,
            enemySpeed: _enemySpeed,
            bulletSpeed: _bulletSpeed,
          ),

          // Settings overlay (top-right)
          Positioned(
            top: 8,
            right: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Toggle settings button
                IconButton(
                  icon: Icon(
                    _showSettings ? Icons.close : Icons.settings,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  onPressed: () {
                    setState(() {
                      _showSettings = !_showSettings;
                    });
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                  ),
                ),

                // Settings panel
                if (_showSettings) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Difficulty',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Preset buttons
                        ..._presets.keys.map((preset) {
                          final isSelected = _selectedPreset == preset;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: SizedBox(
                              width: 120,
                              child: ElevatedButton(
                                onPressed: () => _applyPreset(preset),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSelected
                                      ? const Color(0xFF00FF00)
                                      : Colors.grey.shade800,
                                  foregroundColor: isSelected
                                      ? Colors.black
                                      : Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                                child: Text(
                                  preset,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),

                        const Divider(color: Colors.white24, height: 24),

                        // Custom settings
                        _buildSlider(
                          'Lives',
                          _initialScore.toDouble(),
                          5,
                          30,
                          (value) {
                            setState(() {
                              _initialScore = value.round();
                              _selectedPreset = 'Custom';
                            });
                          },
                          _initialScore.toString(),
                        ),

                        _buildSlider(
                          'Spawn Rate',
                          _enemySpawnInterval.toDouble(),
                          500,
                          3000,
                          (value) {
                            setState(() {
                              _enemySpawnInterval = value.round();
                              _selectedPreset = 'Custom';
                            });
                          },
                          '${_enemySpawnInterval}ms',
                        ),

                        _buildSlider(
                          'Enemy Speed',
                          _enemySpeed,
                          1.0,
                          5.0,
                          (value) {
                            setState(() {
                              _enemySpeed = value;
                              _selectedPreset = 'Custom';
                            });
                          },
                          _enemySpeed.toStringAsFixed(1),
                        ),

                        _buildSlider(
                          'Bullet Speed',
                          _bulletSpeed,
                          3.0,
                          8.0,
                          (value) {
                            setState(() {
                              _bulletSpeed = value;
                              _selectedPreset = 'Custom';
                            });
                          },
                          _bulletSpeed.toStringAsFixed(1),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
    String displayValue,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
              Text(
                displayValue,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 120,
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                activeColor: const Color(0xFF00FF00),
                inactiveColor: Colors.grey.shade700,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
