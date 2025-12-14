import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';

class SpaceShooter extends StatefulWidget {
  /// Color of the player's ship
  final Color playerColor;

  /// Color of enemy ships
  final Color enemyColor;

  /// Color of bullets
  final Color bulletColor;

  /// Background color
  final Color backgroundColor;

  /// Text color for score display
  final Color textColor;

  /// Initial score (game over when reaches 0)
  final int initialScore;

  /// How often enemies spawn (milliseconds)
  final int enemySpawnInterval;

  /// How often bullets fire (milliseconds)
  final int bulletFireInterval;

  /// Speed of enemy movement (pixels per frame)
  final double enemySpeed;

  /// Speed of bullet movement (pixels per frame)
  final double bulletSpeed;

  /// Whether to start the game automatically
  final bool autoStart;

  /// Callback when game is over
  final VoidCallback? onGameOver;

  /// Callback when score changes
  final ValueChanged<int>? onScoreChanged;

  const SpaceShooter({
    super.key,
    this.playerColor = const Color(0xFF00FF00),
    this.enemyColor = const Color(0xFFFF0000),
    this.bulletColor = const Color(0xFFFFFF00),
    this.backgroundColor = const Color(0xFF000000),
    this.textColor = const Color(0xFFFFFFFF),
    this.initialScore = 10,
    this.enemySpawnInterval = 1500,
    this.bulletFireInterval = 300,
    this.enemySpeed = 2.0,
    this.bulletSpeed = 5.0,
    this.autoStart = false,
    this.onGameOver,
    this.onScoreChanged,
  });

  @override
  State<SpaceShooter> createState() => _SpaceShooterState();
}

class _RepaintNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

class _SpaceShooterState extends State<SpaceShooter>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final _repaintNotifier = _RepaintNotifier();
  final math.Random _random = math.Random();

  // Game state
  double _playerX = 0.5; // Normalized position (0-1)
  int _score = 10;
  bool _isGameOver = false;
  bool _isPlaying = false;
  Size _size = Size.zero;

  // Game entities
  final List<_Bullet> _bullets = [];
  final List<_Enemy> _enemies = [];

  // Timing
  int _tickCount = 0;
  int _lastBulletFrame = 0;
  int _lastEnemyFrame = 0;

  // Constants
  static const double _playerSize = 20.0;
  static const double _bulletWidth = 4.0;
  static const double _bulletHeight = 12.0;
  static const double _enemySize = 18.0;

  @override
  void initState() {
    super.initState();
    _score = widget.initialScore;
    _isPlaying = widget.autoStart;
    _ticker = createTicker(_tick);
    if (widget.autoStart) {
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _repaintNotifier.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    if (_size == Size.zero || _isGameOver || !_isPlaying) return;

    _tickCount++;

    _spawnBullets();
    _spawnEnemies();
    _updateBullets();
    _updateEnemies();
    _checkCollisions();
    _checkMissedEnemies();

    _repaintNotifier.notify();
  }

  void _spawnBullets() {
    final framesSinceBullet = _tickCount - _lastBulletFrame;
    final framesPerBullet = (widget.bulletFireInterval / 16.67).round();

    if (framesSinceBullet >= framesPerBullet) {
      final playerPx = _playerX * _size.width;
      final playerY = _size.height - _playerSize - 10;

      // Spawn dual bullets
      _bullets.add(_Bullet(x: playerPx - 8, y: playerY));
      _bullets.add(_Bullet(x: playerPx + 8, y: playerY));

      _lastBulletFrame = _tickCount;
    }
  }

  void _spawnEnemies() {
    final framesSinceEnemy = _tickCount - _lastEnemyFrame;
    final framesPerEnemy = (widget.enemySpawnInterval / 16.67).round();

    if (framesSinceEnemy >= framesPerEnemy) {
      final x =
          _enemySize + _random.nextDouble() * (_size.width - _enemySize * 2);
      _enemies.add(_Enemy(x: x, y: -_enemySize));
      _lastEnemyFrame = _tickCount;
    }
  }

  void _updateBullets() {
    _bullets.removeWhere((bullet) {
      bullet.y -= widget.bulletSpeed;
      return bullet.y < -_bulletHeight;
    });
  }

  void _updateEnemies() {
    for (var enemy in _enemies) {
      enemy.y += widget.enemySpeed;
    }
  }

  void _checkCollisions() {
    final bulletsToRemove = <_Bullet>[];
    final enemiesToRemove = <_Enemy>[];

    for (var bullet in _bullets) {
      for (var enemy in _enemies) {
        if (_collides(bullet, enemy)) {
          if (!bulletsToRemove.contains(bullet)) {
            bulletsToRemove.add(bullet);
          }
          if (!enemiesToRemove.contains(enemy)) {
            enemiesToRemove.add(enemy);
            _addScore(1);
          }
        }
      }
    }

    _bullets.removeWhere((b) => bulletsToRemove.contains(b));
    _enemies.removeWhere((e) => enemiesToRemove.contains(e));
  }

  bool _collides(_Bullet bullet, _Enemy enemy) {
    final dx = (bullet.x - enemy.x).abs();
    final dy = (bullet.y - enemy.y).abs();
    return dx < _enemySize / 2 && dy < _enemySize / 2;
  }

  void _checkMissedEnemies() {
    final missed = _enemies.where((e) => e.y > _size.height).toList();
    for (var _ in missed) {
      _addScore(-1);
    }
    _enemies.removeWhere((e) => e.y > _size.height);
  }

  void _addScore(int delta) {
    setState(() {
      _score += delta;
      widget.onScoreChanged?.call(_score);

      if (_score <= 0) {
        _score = 0;
        _isGameOver = true;
        _ticker.stop();
        widget.onGameOver?.call();
      }
    });
  }

  void _restart() {
    setState(() {
      _score = widget.initialScore;
      _isGameOver = false;
      _isPlaying = true;
      _bullets.clear();
      _enemies.clear();
      _tickCount = 0;
      _lastBulletFrame = 0;
      _lastEnemyFrame = 0;
      _ticker.start();
    });
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _score = widget.initialScore;
      _bullets.clear();
      _enemies.clear();
      _tickCount = 0;
      _lastBulletFrame = 0;
      _lastEnemyFrame = 0;
      _ticker.start();
    });
  }

  void _handlePointerMove(Offset position) {
    if (_isGameOver || _size == Size.zero) return;
    setState(() {
      _playerX = (position.dx / _size.width).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _size = Size(constraints.maxWidth, constraints.maxHeight);

        return MouseRegion(
          onHover: (event) => _handlePointerMove(event.localPosition),
          child: GestureDetector(
            onPanUpdate: (details) => _handlePointerMove(details.localPosition),
            onTapDown: (details) => _handlePointerMove(details.localPosition),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: widget.backgroundColor,
              child: Stack(
                children: [
                  // Game canvas
                  CustomPaint(
                    painter: _SpaceShooterPainter(
                      playerX: _playerX,
                      playerSize: _playerSize,
                      bullets: _bullets,
                      enemies: _enemies,
                      playerColor: widget.playerColor,
                      bulletColor: widget.bulletColor,
                      enemyColor: widget.enemyColor,
                      repaint: _repaintNotifier,
                    ),
                    size: Size.infinite,
                  ),

                  // Score display
                  if (_isPlaying)
                    Positioned(
                      top: 20,
                      left: 20,
                      child: Text(
                        'Score: $_score',
                        style: TextStyle(
                          color: widget.textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),

                  // Start screen overlay
                  if (!_isPlaying && !_isGameOver)
                    Container(
                      color: widget.backgroundColor.withValues(alpha: 0.8),
                      child: Center(
                        child: GestureDetector(
                          onTap: _startGame,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 24,
                            ),
                            decoration: BoxDecoration(
                              color: widget.playerColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'PLAY',
                              style: TextStyle(
                                color: widget.backgroundColor,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Game over overlay
                  if (_isGameOver)
                    Container(
                      color: const Color(0x99000000),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'GAME OVER',
                              style: TextStyle(
                                color: widget.textColor,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: _restart,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.playerColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'RESTART',
                                  style: TextStyle(
                                    color: Color(0xFF000000),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SpaceShooterPainter extends CustomPainter {
  final double playerX;
  final double playerSize;
  final List<_Bullet> bullets;
  final List<_Enemy> enemies;
  final Color playerColor;
  final Color bulletColor;
  final Color enemyColor;

  late final Paint _playerPaint = Paint()..style = PaintingStyle.fill;
  late final Paint _bulletPaint = Paint()..style = PaintingStyle.fill;
  late final Paint _enemyPaint = Paint()..style = PaintingStyle.fill;

  _SpaceShooterPainter({
    required this.playerX,
    required this.playerSize,
    required this.bullets,
    required this.enemies,
    required this.playerColor,
    required this.bulletColor,
    required this.enemyColor,
    super.repaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawPlayer(canvas, size);
    _drawBullets(canvas);
    _drawEnemies(canvas);
  }

  void _drawPlayer(Canvas canvas, Size size) {
    _playerPaint.color = playerColor;

    final playerPx = playerX * size.width;
    final playerY = size.height - playerSize - 10;

    // Draw player as upward-pointing triangle
    final path = Path()
      ..moveTo(playerPx, playerY - playerSize / 2)
      ..lineTo(playerPx - playerSize / 2, playerY + playerSize / 2)
      ..lineTo(playerPx + playerSize / 2, playerY + playerSize / 2)
      ..close();

    canvas.drawPath(path, _playerPaint);
  }

  void _drawBullets(Canvas canvas) {
    _bulletPaint.color = bulletColor;

    for (var bullet in bullets) {
      canvas.drawRect(
        Rect.fromLTWH(
          bullet.x - _SpaceShooterState._bulletWidth / 2,
          bullet.y,
          _SpaceShooterState._bulletWidth,
          _SpaceShooterState._bulletHeight,
        ),
        _bulletPaint,
      );
    }
  }

  void _drawEnemies(Canvas canvas) {
    _enemyPaint.color = enemyColor;

    for (var enemy in enemies) {
      // Draw enemy as downward-pointing triangle
      final path = Path()
        ..moveTo(enemy.x, enemy.y + _SpaceShooterState._enemySize / 2)
        ..lineTo(
          enemy.x - _SpaceShooterState._enemySize / 2,
          enemy.y - _SpaceShooterState._enemySize / 2,
        )
        ..lineTo(
          enemy.x + _SpaceShooterState._enemySize / 2,
          enemy.y - _SpaceShooterState._enemySize / 2,
        )
        ..close();

      canvas.drawPath(path, _enemyPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpaceShooterPainter oldDelegate) {
    return playerColor != oldDelegate.playerColor ||
        bulletColor != oldDelegate.bulletColor ||
        enemyColor != oldDelegate.enemyColor;
  }
}

class _Bullet {
  double x;
  double y;

  _Bullet({required this.x, required this.y});
}

class _Enemy {
  double x;
  double y;

  _Enemy({required this.x, required this.y});
}
