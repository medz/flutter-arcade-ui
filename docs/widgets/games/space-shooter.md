A minimalist space shooter game inspired by 1KB game challenges and classic arcade shooters. Control your ship and destroy enemies before they escape!

## Preview

@{WidgetPreview:games/space_shooter}

## Features

- 🎮 **Simple Controls**: Move your ship with mouse or touch
- 🚀 **Dual Bullets**: Automatically fires two bullets upward
- 👾 **Enemy Waves**: Enemies spawn from the top at random positions
- 📊 **Score System**: +1 for destroying enemies, -1 for missing them
- 💀 **Game Over**: Score starts at configurable value, game ends when it reaches 0
- 🔄 **Restart**: Click restart button to play again
- ⚙️ **Customizable**: Adjust difficulty with spawn rates and speeds

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `playerColor` | `Color` | `Color(0xFF00FF00)` | Color of the player's ship |
| `enemyColor` | `Color` | `Color(0xFFFF0000)` | Color of enemy ships |
| `bulletColor` | `Color` | `Color(0xFFFFFF00)` | Color of bullets |
| `backgroundColor` | `Color` | `Color(0xFF000000)` | Background color |
| `textColor` | `Color` | `Color(0xFFFFFFFF)` | Text color for score display |
| `initialScore` | `int` | `10` | Starting score (game over when reaches 0) |
| `enemySpawnInterval` | `int` | `1500` | How often enemies spawn (milliseconds) |
| `bulletFireInterval` | `int` | `300` | How often bullets fire (milliseconds) |
| `enemySpeed` | `double` | `2.0` | Speed of enemy movement (pixels per frame) |
| `bulletSpeed` | `double` | `5.0` | Speed of bullet movement (pixels per frame) |
| `autoStart` | `bool` | `false` | Whether to start game automatically |
| `onGameOver` | `VoidCallback?` | `null` | Callback when game is over |
| `onScoreChanged` | `ValueChanged<int>?` | `null` | Callback when score changes |

## Usage

### Basic Example

```dart
import 'package:arcade/widgets/games/space_shooter.dart';

SpaceShooter(
  autoStart: true,
)
```

### Full-Screen Game

```dart
Scaffold(
  body: SpaceShooter(
    autoStart: true,
  ),
)
```

### With Custom Colors

```dart
SpaceShooter(
  playerColor: Colors.cyan,
  enemyColor: Colors.purple,
  bulletColor: Colors.orange,
  backgroundColor: Color(0xFF0A0E27),
)
```

### Hard Mode Configuration

```dart
SpaceShooter(
  initialScore: 15,
  enemySpawnInterval: 800,  // Faster spawning
  enemySpeed: 3.5,          // Faster enemies
  bulletSpeed: 4.0,         // Slower bullets
  onScoreChanged: (score) {
    print('Score: $score');
  },
  onGameOver: () {
    print('Game Over!');
  },
)
```

## Game Rules

1. **Movement**: Your ship follows your mouse cursor or touch position
2. **Shooting**: Bullets are fired automatically in dual streams
3. **Enemies**: Spawn at random positions from the top and move downward
4. **Scoring**:
   - Hit an enemy: +1 point
   - Enemy escapes (reaches bottom): -1 point
5. **Game Over**: When score reaches 0
6. **Controls**: Click "PLAY" to start, click "RESTART" after game over

## Examples

### Easy Mode

Perfect for beginners - slower enemies, more starting lives:

```dart
SpaceShooter(
  initialScore: 20,
  enemySpawnInterval: 2000,
  enemySpeed: 1.5,
  bulletSpeed: 6.0,
)
```

### Nightmare Mode

For experienced players - fast enemies, quick spawning:

```dart
SpaceShooter(
  initialScore: 10,
  enemySpawnInterval: 600,
  enemySpeed: 4.0,
  bulletSpeed: 4.5,
)
```

### Retro Arcade Style

Classic arcade game appearance:

```dart
SpaceShooter(
  playerColor: Color(0xFF00FFFF),
  enemyColor: Color(0xFFFF00FF),
  bulletColor: Color(0xFFFFFF00),
  backgroundColor: Color(0xFF000033),
  initialScore: 15,
)
```

## Performance

The game runs at 60 FPS using Flutter's Ticker API and CustomPainter for efficient rendering. All game logic and rendering is contained in a single file (~400 lines) for easy copying and customization.

## Tips

- Start with default settings and adjust difficulty as needed
- Lower `enemySpawnInterval` for more challenge
- Increase `enemySpeed` for faster-paced gameplay
- Higher `initialScore` gives more margin for error
- Balance `bulletSpeed` and `enemySpeed` for fair gameplay

## Source Code

@{WidgetCode:games/space_shooter}
