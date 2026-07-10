import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class SpaceShooter extends StatefulWidget {
  final Color playerColor;
  final Color enemyColor;
  final Color bulletColor;
  final Color backgroundColor;
  final Color textColor;
  final int initialScore;
  final int enemySpawnInterval;
  final int bulletFireInterval;
  final double enemySpeed;
  final double bulletSpeed;
  final bool autoStart;
  final VoidCallback? onGameOver;
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
    this.enemySpeed = 2,
    this.bulletSpeed = 5,
    this.autoStart = false,
    this.onGameOver,
    this.onScoreChanged,
  }) : assert(initialScore > 0, 'initialScore must be greater than 0'),
       assert(
         enemySpawnInterval > 0,
         'enemySpawnInterval must be greater than 0',
       ),
       assert(
         bulletFireInterval > 0,
         'bulletFireInterval must be greater than 0',
       ),
       assert(enemySpeed >= 0, 'enemySpeed must be non-negative'),
       assert(bulletSpeed >= 0, 'bulletSpeed must be non-negative');

  @override
  State<SpaceShooter> createState() => _SpaceShooterState();
}

class _RepaintNotifier extends ChangeNotifier {
  void repaint() => notifyListeners();
}

class _SpaceShooterState extends State<SpaceShooter>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const _playerSize = 20.0;
  static const _bulletWidth = 4.0;
  static const _bulletHeight = 12.0;
  static const _enemySize = 18.0;

  final _scene = _Scene();
  final _repaint = _RepaintNotifier();
  final _random = math.Random();
  late final Ticker _ticker;

  int _score = 0;
  bool _isGameOver = false;
  bool _isPlaying = false;
  bool _pausedByLifecycle = false;
  Size _size = Size.zero;
  Duration? _lastElapsed;
  double _bulletElapsedMs = 0;
  double _enemyElapsedMs = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _score = widget.initialScore;
    _isPlaying = widget.autoStart;
    _ticker = createTicker(_tick);
    if (_isPlaying) unawaited(_ticker.start());
  }

  @override
  void didUpdateWidget(covariant SpaceShooter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isPlaying && oldWidget.initialScore != widget.initialScore) {
      _score = widget.initialScore;
    }
    if (!oldWidget.autoStart && widget.autoStart && !_isPlaying) {
      _resetAndStart();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _pausedByLifecycle = false;
      _startTickerIfNeeded();
      return;
    }
    _pausedByLifecycle = true;
    _ticker.stop();
    _lastElapsed = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _repaint.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    if (_size == Size.zero || _isGameOver || !_isPlaying) return;

    final previous = _lastElapsed;
    _lastElapsed = elapsed;
    final deltaSeconds = previous == null
        ? 1 / 60
        : math.min((elapsed - previous).inMicroseconds / 1000000, 0.05);
    final deltaMilliseconds = deltaSeconds * 1000;

    _bulletElapsedMs += deltaMilliseconds;
    _enemyElapsedMs += deltaMilliseconds;
    _spawnBullets();
    _spawnEnemies();
    _updateEntities(deltaSeconds);

    final scoreDelta = _removeCollisions() - _removeMissedEnemies();
    if (scoreDelta != 0) _updateScore(scoreDelta);
    _repaint.repaint();
  }

  void _spawnBullets() {
    while (_bulletElapsedMs >= widget.bulletFireInterval) {
      final playerX = _scene.playerX * _size.width;
      final playerY = _size.height - _playerSize - 10;
      _scene.bullets
        ..add(_Bullet(x: playerX - 8, y: playerY))
        ..add(_Bullet(x: playerX + 8, y: playerY));
      _bulletElapsedMs -= widget.bulletFireInterval;
    }
  }

  void _spawnEnemies() {
    while (_enemyElapsedMs >= widget.enemySpawnInterval) {
      final usableWidth = _size.width - _enemySize * 2;
      final x = usableWidth <= 0
          ? _size.width / 2
          : _enemySize + _random.nextDouble() * usableWidth;
      _scene.enemies.add(_Enemy(x: x, y: -_enemySize));
      _enemyElapsedMs -= widget.enemySpawnInterval;
    }
  }

  void _updateEntities(double deltaSeconds) {
    final frameScale = deltaSeconds * 60;
    _scene.bullets.removeWhere((bullet) {
      bullet.y -= widget.bulletSpeed * frameScale;
      return bullet.y < -_bulletHeight;
    });
    for (final enemy in _scene.enemies) {
      enemy.y += widget.enemySpeed * frameScale;
    }
  }

  int _removeCollisions() {
    final bulletsToRemove = <_Bullet>{};
    final enemiesToRemove = <_Enemy>{};

    for (final bullet in _scene.bullets) {
      for (final enemy in _scene.enemies) {
        if (enemiesToRemove.contains(enemy) || !_collides(bullet, enemy)) {
          continue;
        }
        bulletsToRemove.add(bullet);
        enemiesToRemove.add(enemy);
        break;
      }
    }

    _scene.bullets.removeWhere(bulletsToRemove.contains);
    _scene.enemies.removeWhere(enemiesToRemove.contains);
    return enemiesToRemove.length;
  }

  int _removeMissedEnemies() {
    final before = _scene.enemies.length;
    _scene.enemies.removeWhere((enemy) => enemy.y > _size.height + _enemySize);
    return before - _scene.enemies.length;
  }

  bool _collides(_Bullet bullet, _Enemy enemy) {
    final bulletRect = Rect.fromLTWH(
      bullet.x - _bulletWidth / 2,
      bullet.y,
      _bulletWidth,
      _bulletHeight,
    );
    final enemyRect = Rect.fromCenter(
      center: Offset(enemy.x, enemy.y),
      width: _enemySize,
      height: _enemySize,
    );
    return bulletRect.overlaps(enemyRect);
  }

  void _updateScore(int delta) {
    final score = math.max(0, _score + delta);
    if (score == _score) return;
    final gameOver = score == 0;
    setState(() {
      _score = score;
      _isGameOver = gameOver;
    });
    widget.onScoreChanged?.call(score);
    if (gameOver) {
      _ticker.stop();
      _lastElapsed = null;
      widget.onGameOver?.call();
    }
  }

  void _resetAndStart() {
    setState(() {
      _score = widget.initialScore;
      _isGameOver = false;
      _isPlaying = true;
    });
    _scene
      ..playerX = 0.5
      ..bullets.clear()
      ..enemies.clear();
    _lastElapsed = null;
    _bulletElapsedMs = 0;
    _enemyElapsedMs = 0;
    _repaint.repaint();
    _startTickerIfNeeded();
  }

  void _startTickerIfNeeded() {
    if (_isPlaying &&
        !_isGameOver &&
        !_pausedByLifecycle &&
        !_ticker.isActive) {
      unawaited(_ticker.start());
    }
  }

  void _movePlayer(Offset position) {
    if (_isGameOver || _size.width <= 0) return;
    final halfPlayer = _playerSize / 2;
    final x = _size.width <= _playerSize
        ? _size.width / 2
        : position.dx.clamp(halfPlayer, _size.width - halfPlayer);
    _scene.playerX = x / _size.width;
    _repaint.repaint();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.hasBoundedWidth && constraints.hasBoundedHeight) {
          _size = constraints.biggest;
        } else {
          _size = Size.zero;
        }

        return MouseRegion(
          onHover: (event) => _movePlayer(event.localPosition),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (details) => _movePlayer(details.localPosition),
            onTapDown: (details) => _movePlayer(details.localPosition),
            child: ColoredBox(
              color: widget.backgroundColor,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  RepaintBoundary(
                    child: CustomPaint(
                      painter: _SpaceShooterPainter(
                        scene: _scene,
                        playerSize: _playerSize,
                        playerColor: widget.playerColor,
                        bulletColor: widget.bulletColor,
                        enemyColor: widget.enemyColor,
                        repaint: _repaint,
                      ),
                    ),
                  ),
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
                  if (!_isPlaying && !_isGameOver)
                    _GameOverlay(
                      backgroundColor: widget.backgroundColor,
                      foregroundColor: widget.playerColor,
                      label: 'PLAY',
                      onTap: _resetAndStart,
                    ),
                  if (_isGameOver)
                    _GameOverOverlay(
                      textColor: widget.textColor,
                      buttonColor: widget.playerColor,
                      onRestart: _resetAndStart,
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

class _GameOverlay extends StatelessWidget {
  final Color backgroundColor;
  final Color foregroundColor;
  final String label;
  final VoidCallback onTap;

  const _GameOverlay({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor.withValues(alpha: 0.82),
      child: Center(
        child: Semantics(
          button: true,
          label: label,
          child: GestureDetector(
            onTap: onTap,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: foregroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 44,
                  vertical: 20,
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: backgroundColor,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GameOverOverlay extends StatelessWidget {
  final Color textColor;
  final Color buttonColor;
  final VoidCallback onRestart;

  const _GameOverOverlay({
    required this.textColor,
    required this.buttonColor,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xD9000000),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'GAME OVER',
              style: TextStyle(
                color: textColor,
                fontSize: 42,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 20),
            _GameOverlayButton(color: buttonColor, onTap: onRestart),
          ],
        ),
      ),
    );
  }
}

class _GameOverlayButton extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _GameOverlayButton({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Restart game',
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
            child: Text(
              'RESTART',
              style: TextStyle(
                color: Color(0xFF000000),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SpaceShooterPainter extends CustomPainter {
  final _Scene scene;
  final double playerSize;
  final Color playerColor;
  final Color bulletColor;
  final Color enemyColor;
  final Paint _playerPaint = Paint()..style = PaintingStyle.fill;
  final Paint _bulletPaint = Paint()..style = PaintingStyle.fill;
  final Paint _enemyPaint = Paint()..style = PaintingStyle.fill;

  _SpaceShooterPainter({
    required this.scene,
    required this.playerSize,
    required this.playerColor,
    required this.bulletColor,
    required this.enemyColor,
    required Listenable repaint,
  }) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    _drawPlayer(canvas, size);
    _drawBullets(canvas);
    _drawEnemies(canvas);
  }

  void _drawPlayer(Canvas canvas, Size size) {
    _playerPaint.color = playerColor;
    final playerX = scene.playerX * size.width;
    final playerY = size.height - playerSize - 10;
    final path = Path()
      ..moveTo(playerX, playerY - playerSize / 2)
      ..lineTo(playerX - playerSize / 2, playerY + playerSize / 2)
      ..lineTo(playerX + playerSize / 2, playerY + playerSize / 2)
      ..close();
    canvas.drawPath(path, _playerPaint);
  }

  void _drawBullets(Canvas canvas) {
    _bulletPaint.color = bulletColor;
    for (final bullet in scene.bullets) {
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
    for (final enemy in scene.enemies) {
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
    return scene != oldDelegate.scene ||
        playerColor != oldDelegate.playerColor ||
        bulletColor != oldDelegate.bulletColor ||
        enemyColor != oldDelegate.enemyColor;
  }
}

class _Scene {
  double playerX = 0.5;
  final bullets = <_Bullet>[];
  final enemies = <_Enemy>[];
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
