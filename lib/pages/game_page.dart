import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_skiing/components/game_over_dialog.dart';
import 'package:go_skiing/components/top_right_bar.dart';
import 'package:go_skiing/components/trees.dart';
import 'package:go_skiing/models/ranking.dart';
import 'package:go_skiing/pages/homepage.dart';
import 'package:go_skiing/providers/score_provider.dart';
import 'package:go_skiing/providers/user_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sensors_plus/sensors_plus.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  bool isGameOver = false;
  double speed = 5;
  final double maxSpeed = 14;
  final double boostMultiplier = 3;
  final double flatSlopeThreshold = 0.12;
  final double flatFriction = 1.8;
  final double slopeAcceleration = 3.0;
  final double minSlopeAngle = 0;
  final double maxSlopeAngle = 0.85;
  final double slopeSensitivity = 0.02;
  final Duration boostDuration = 2.seconds;
  final Duration boostCooldown = 1.seconds;
  final ScoreProvider scoreProvider = Get.find<ScoreProvider>();
  final userProvider = Get.find<UserProvider>();
  Duration pauseDur = Duration.zero;
  Rect playerRect = Rect.fromLTWH(Get.width * .3, Get.height - 180, 100, 100);
  double angle = 0.2;
  bool isPaused = false;
  int coins = 10;
  Duration duration = Duration.zero;
  bool isInvincable = true;
  Duration lastInvincableCoinUsed = Duration.zero;
  AudioPlayer backgroundPlayer = AudioPlayer();
  AudioPlayer jumpPlayer = AudioPlayer();
  AudioPlayer gameOverPlayer = AudioPlayer();
  AudioPlayer coinPlayer = AudioPlayer();
  late Ticker _ticker;
  late final StreamSubscription gyroStream;
  bool isObstacle = true;
  final List<Rect> coinsRect = List.generate(
    3,
    (_) => Rect.fromLTWH(Get.width, Get.height - 180, 32, 32),
  );
  List<bool> showCoins = List.generate(3, (_) => true);
  Rect obstacleRect = Rect.fromLTWH(Get.width * 2, Get.height, 32, 32);
  Duration lastSpawn = Duration.zero;
  Duration boostUntil = Duration.zero;
  Duration lastBoostAt = Duration.zero;
  Duration? lastTick;
  final math.Random random = math.Random();
  final List<double> coinSlopeOffsets = List.generate(3, (_) => 0.0);
  double obstacleSlopeOffset = 0;

  bool get isBoosting => duration < boostUntil;

  double get slopeStrength => angle.abs().clamp(0.0, 1.0);

  double get slopeBaseY => Get.height - 88;

  Alignment get slopeRotationAlignment {
    final playerCenterX = playerRect.left + (playerRect.width / 2);
    final normalizedX = ((playerCenterX / Get.width) * 2 - 1).clamp(-1.0, 1.0);
    return Alignment(normalizedX, 1.0);
  }

  double get activeSpeed => isBoosting ? speed * boostMultiplier : speed;

  Duration get treeAnimationSpeed {
    final slopeRange = (maxSlopeAngle - flatSlopeThreshold).clamp(0.01, 1.0);
    final normalizedSlope = ((slopeStrength - flatSlopeThreshold) / slopeRange)
        .clamp(0.0, 1.0);
    final slopeVisualMultiplier = 0.8 + (normalizedSlope * 1.4);
    final normalizedSpeed = ((activeSpeed / 5) * slopeVisualMultiplier).clamp(
      0.2,
      3.5,
    );
    return Duration(milliseconds: (3000 / normalizedSpeed).round());
  }

  @override
  void initState() {
    super.initState();
    init();
    _ticker = createTicker((dur) => onTick(dur));
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    gyroStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onLongPressDown: (_) => startInvincable(),
        onLongPressEnd: (_) => endInvincable(),
        onLongPressCancel: () => endInvincable(),
        onPanUpdate: (details) {
          if (details.delta.dy > 8) {
            startBoost();
            return;
          }
          if (details.delta.dx > 5) {
            pauseGame();
            Get.dialog(
              Dialog(
                child: SizedBox(
                  width: Get.width * .8,
                  height: Get.height * .4,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("The game is in progress. Are you sure to quit?"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              width: Get.width * .3,
                              height: 60,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(),
                                  ),
                                  backgroundColor: WidgetStatePropertyAll(
                                    Color(0xff9dd4fa),
                                  ),
                                  foregroundColor: WidgetStatePropertyAll(
                                    Colors.black,
                                  ),
                                ),
                                onPressed: () => Get.to(() => Homepage()),
                                child: Text("Yes"),
                              ),
                            ),
                            SizedBox(
                              width: Get.width * .3,
                              height: 60,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  shape: WidgetStatePropertyAll(
                                    RoundedRectangleBorder(),
                                  ),
                                  backgroundColor: WidgetStatePropertyAll(
                                    Color(0xff9dd4fa),
                                  ),
                                  foregroundColor: WidgetStatePropertyAll(
                                    Colors.black,
                                  ),
                                ),
                                onPressed: () {
                                  Get.back();
                                  unPause();
                                },
                                child: Text("No"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        },
        onTap: () => jump(),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset("assets/images/bg.jpg", fit: BoxFit.cover),
            ),
            Trees(
              animationSpeed: treeAnimationSpeed,
              isPaused: isPaused || isGameOver,
            ),

            TopRightBar(
              userProvider: userProvider,
              coins: coins,
              duration: duration,
            ),

            Positioned(
              left: -Get.width * 0.25,
              bottom: -50,
              height: 100,
              child: Transform.rotate(
                angle: angle,
                alignment: slopeRotationAlignment,
                child: Transform.scale(
                  scaleY: 1.7,
                  scaleX: 1.2,
                  origin: Offset(0, -angle * 50),
                  child: Container(width: Get.width * 1.5, color: Colors.white),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: 500.milliseconds,
              height: playerRect.height,
              width: playerRect.width,
              top: playerRect.top,
              left: playerRect.left,
              child: Transform.rotate(
                angle: angle,
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      colors: isInvincable
                          ? [Colors.black, Colors.black]
                          : [
                              userProvider.color.value,
                              userProvider.color.value,
                            ],
                    ).createShader(bounds);
                  },
                  child: Image.asset("assets/images/skiing_person.png"),
                ),
              ),
            ),
            for (int i = 0; i < coinsRect.length; i++)
              if (showCoins[i])
                if (!isObstacle)
                  Positioned(
                    top: coinsRect[i].top,
                    left: coinsRect[i].left,
                    width: coinsRect[i].width,
                    height: coinsRect[i].height,
                    child: Image.asset("assets/images/coin.png"),
                  ),
            if (isObstacle)
              Positioned(
                top: obstacleRect.top,
                left: obstacleRect.left,
                width: obstacleRect.width,
                height: obstacleRect.height,
                child: Transform.rotate(
                  angle: angle,
                  child: Image.asset("assets/images/obstacle.png"),
                ),
              ),

            if (isPaused)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: Text(
                      "Game suspended...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

            Positioned(
              top: 24,
              left: 24,
              child: IconButton(
                onPressed: () {
                  if (isPaused) {
                    unPause();
                  } else {
                    pauseGame();
                  }
                },
                icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void init() async {
    HapticFeedback.heavyImpact();
    await backgroundPlayer.setAsset("assets/audio/bgm.mp3");
    backgroundPlayer.play();

    await jumpPlayer.setAsset("assets/audio/jump.wav");
    await gameOverPlayer.setAsset("assets/audio/game_over.wav");
    await coinPlayer.setAsset("assets/audio/coin.wav");

    gyroStream = gyroscopeEventStream().listen((event) => _changeAngle(event));
  }

  void onTick(Duration dur) {
    final previousTick = lastTick;
    lastTick = dur;
    final delta = previousTick == null ? Duration.zero : dur - previousTick;
    final deltaSeconds = delta.inMicroseconds / Duration.microsecondsPerSecond;
    final frameFactor = deltaSeconds * 60;

    duration = pauseDur + dur;
    updateSpeedFromSlope(deltaSeconds);

    if (speed <= 0.01) {
      endRun("You lost all your speed on the flat slope.");
      return;
    }

    moveObstacles(activeSpeed * frameFactor);

    handleRespawn();
    handleInvinsable();

    handleObstacleCollsion();
    handlleCoinCollision();

    setState(() {});
  }

  void handleInvinsable() {
    if (isInvincable && lastInvincableCoinUsed.inSeconds < duration.inSeconds) {
      lastInvincableCoinUsed = duration;
      if (coins > 0) {
        coins--;
      } else {
        isInvincable = false;
      }
    }
  }

  void handlleCoinCollision() {
    for (var i = 0; i < coinsRect.length; i++) {
      final coin = coinsRect[i];
      if (coin.overlaps(playerRect) && showCoins[i]) {
        coinPlayer.play();
        showCoins[i] = false;
        coins++;
      }
    }
  }

  void handleObstacleCollsion() {
    if (playerRect.overlaps(obstacleRect) && !isInvincable) {
      endRun("You hit an obstacle.");
    }
  }

  void endRun(String message) {
    if (isGameOver) return;

    HapticFeedback.heavyImpact();
    backgroundPlayer.stop();
    _ticker.stop();
    setState(() {
      isGameOver = true;
    });
    final latestRanking = Ranking(
      playerName: userProvider.name.value,
      coin: coins,
      duration: duration,
    );

    scoreProvider.addRanking(latestRanking);
    gameOverPlayer.play();

    Get.dialog(
      barrierDismissible: false,
      GameOverDialog(
        userProvider: userProvider,
        coins: coins,
        duration: duration,
        latestRanking: latestRanking,
        onReset: restart,
      ),
    );
  }

  void handleRespawn() {
    if (lastSpawn.inSeconds + 3 < duration.inSeconds) {
      isObstacle = !isObstacle;
      if (isObstacle) {
        if (obstacleRect.left < 0) {
          obstacleSlopeOffset = random.nextDouble() * 22 - 11;
          obstacleRect = _placeOnSlope(
            Rect.fromLTWH(Get.width, obstacleRect.top, 32, 32),
            obstacleSlopeOffset,
          );
        }
      } else {
        if (coinsRect.any((rect) => rect.left < 0)) {
          for (var i = 0; i < coinsRect.length; i++) {
            double spacing = 12;
            showCoins[i] = true;

            coinsRect[i] = _placeOnSlope(
              Rect.fromLTWH(
                Get.width + (32 * i) + (spacing * i),
                coinsRect[i].top,
                32,
                32,
              ),
              coinSlopeOffsets[i],
            );
          }
        }
      }
      lastSpawn = duration;
    }
  }

  void moveObstacles(double moveSpeed) {
    obstacleRect = _placeOnSlope(
      obstacleRect.shift(Offset(-moveSpeed, 0)),
      obstacleSlopeOffset,
    );
    for (var i = 0; i < coinsRect.length; i++) {
      coinsRect[i] = _placeOnSlope(
        coinsRect[i].shift(Offset(-moveSpeed, 0)),
        coinSlopeOffsets[i],
      );
    }
  }

  Rect _placeOnSlope(Rect rect, double verticalOffset) {
    final playerCenterX = playerRect.left + (playerRect.width / 2);
    final objectCenterX = rect.left + (rect.width / 2);
    final baseY = slopeBaseY;
    final centerY =
        baseY +
        math.tan(angle) * (objectCenterX - playerCenterX) +
        verticalOffset;
    return Rect.fromLTWH(
      rect.left,
      centerY - (rect.height / 2),
      rect.width,
      rect.height,
    );
  }

  void updateSpeedFromSlope(double deltaSeconds) {
    if (deltaSeconds <= 0) return;

    if (slopeStrength <= flatSlopeThreshold) {
      speed = (speed - (flatFriction * deltaSeconds)).clamp(0.0, maxSpeed);
      return;
    }

    final slopeBonus = (slopeStrength - flatSlopeThreshold) * slopeAcceleration;
    speed = (speed + (slopeBonus * deltaSeconds)).clamp(0.0, maxSpeed);
  }

  void startBoost() {
    if (isBoosting) return;
    if (duration - lastBoostAt < boostCooldown) return;
    lastBoostAt = duration;
    boostUntil = duration + boostDuration;
  }

  void jump() async {
    if (!isGameOver || !isPaused) {
      setState(() {
        playerRect = playerRect.shift(Offset(0, -Get.width * .5));
      });
      jumpPlayer.play();
      await Future.delayed(1.seconds);
      if (mounted) {
        setState(() {
          playerRect = Rect.fromLTWH(
            Get.width * .3,
            Get.height - 180,
            100,
            100,
          );
        });
      }
    }
  }

  void _changeAngle(GyroscopeEvent event) {
    angle = (angle + (event.y * slopeSensitivity)).clamp(
      minSlopeAngle,
      maxSlopeAngle,
    );
  }

  void pauseGame() {
    pauseDur = duration;
    _ticker.stop();
    backgroundPlayer.stop();
    setState(() {
      isPaused = true;
    });
  }

  void unPause() {
    duration = pauseDur;
    _ticker.start();
    backgroundPlayer.play();
    setState(() {
      isPaused = false;
    });
  }

  void restart() {
    _ticker.stop();
    _ticker.start();
    isGameOver = false;
    isPaused = false;
    speed = 5;
    coins = 10;
    angle = 0.2;
    coinsRect.clear();
    for (var i = 0; i < 3; i++) {
      coinSlopeOffsets[i] = 0;
      coinsRect.add(
        _placeOnSlope(Rect.fromLTWH(Get.width + (44 * i), 0, 32, 32), 0),
      );
      showCoins[i] = true;
    }
    obstacleSlopeOffset = 0;
    obstacleRect = _placeOnSlope(Rect.fromLTWH(Get.width * 2, 0, 32, 32), 0);
    lastSpawn = Duration.zero;
    boostUntil = Duration.zero;
    lastBoostAt = Duration.zero;
    lastTick = null;
    setState(() {});
    Get.back();
  }

  void startInvincable() {
    isInvincable = true;
  }

  void endInvincable() {
    isInvincable = false;
  }
}
