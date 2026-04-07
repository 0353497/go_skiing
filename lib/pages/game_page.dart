import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_skiing/models/ranking.dart';
import 'package:go_skiing/pages/homepage.dart';
import 'package:go_skiing/pages/rankings_page.dart';
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
  final ScoreProvider scoreProvider = Get.find<ScoreProvider>();
  final userProvider = Get.find<UserProvider>();
  Duration pauseDur = Duration.zero;
  Rect playerRect = Rect.fromLTWH(Get.width * .3, Get.height - 180, 100, 100);
  double angle = .2;
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
  Rect obstacleRect = Rect.fromLTWH(Get.width * 2, Get.height - 100, 32, 32);
  Duration lastSpawn = Duration.zero;

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
          if (details.delta.direction < 5) {
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
              animationSpeed: (3 - (angle * 2)).seconds,
              isPaused: isPaused || isGameOver,
            ),

            TopRightBar(
              userProvider: userProvider,
              coins: coins,
              duration: duration,
            ),
            Positioned(
              bottom: -50,
              height: 100,
              child: Transform.rotate(
                angle: angle,
                child: Transform.scale(
                  scale: 1.2,
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
    duration = pauseDur + dur;
    double moveSpeed = 5;
    moveObstacles(moveSpeed);

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
      _ticker.stop();
      setState(() {
        isGameOver = true;
      });
      scoreProvider.rankings.add(
        Ranking(
          playerName: userProvider.name.value,
          coin: coins,
          duration: duration,
        ),
      );
      gameOverPlayer.play();

      Get.dialog(
        GameOverDialog(
          userProvider: userProvider,
          coins: coins,
          duration: duration,
          onReset: restart,
        ),
      );
    }
  }

  void handleRespawn() {
    if (lastSpawn.inSeconds + 3 < duration.inSeconds) {
      isObstacle = !isObstacle;
      if (isObstacle) {
        if (obstacleRect.left < 0) {
          obstacleRect = Rect.fromLTWH(Get.width, Get.height - 100, 32, 32);
        }
      } else {
        if (coinsRect.any((rect) => rect.left < 0)) {
          for (var i = 0; i < coinsRect.length; i++) {
            double spacing = 12;
            showCoins[i] = true;

            coinsRect[i] = Rect.fromLTWH(
              Get.width + (32 * i) + (spacing * i),
              Get.height - 100,
              32,
              32,
            );
          }
        }
      }
      lastSpawn = duration;
    }
  }

  void moveObstacles(double moveSpeed) {
    obstacleRect = obstacleRect.shift(Offset(-moveSpeed, -(moveSpeed * .2)));
    for (var i = 0; i < coinsRect.length; i++) {
      coinsRect[i] = coinsRect[i].shift(Offset(-moveSpeed, 0));
    }
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
    double newAgle = (.2 + event.y * .2).abs();
    if (!angle.isNegative) {
      angle = newAgle;
    }
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
    coinsRect.clear();
    for (var i = 0; i < 3; i++) {
      coinsRect.add(Rect.fromLTWH(Get.width, Get.height - 180, 32, 32));
      showCoins[i] = true;
    }
    obstacleRect = Rect.fromLTWH(Get.width * 2, Get.height - 180, 32, 32);
    lastSpawn = Duration.zero;
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

class GameOverDialog extends StatelessWidget {
  const GameOverDialog({
    super.key,
    required this.userProvider,
    required this.coins,
    required this.duration,
    required this.onReset,
  });
  final VoidCallback onReset;

  final UserProvider userProvider;
  final int coins;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: Get.width * .8,
        height: Get.height * .5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text("Game Over"),
              Text("Player name: ${userProvider.name.value}"),
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 12,
                children: [
                  SizedBox(
                    height: 24,
                    child: Image.asset("assets/images/coin.png"),
                  ),
                  Text(
                    "$coins",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow,
                    ),
                  ),
                ],
              ),
              Text("Time: ${duration.inSeconds}"),
              Row(
                spacing: 24,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(onTap: onReset, child: Text("Restart")),
                  InkWell(
                    onTap: () => Get.to(() => RankingsPage()),
                    child: Text("Go To Rankings"),
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

class TopRightBar extends StatelessWidget {
  const TopRightBar({
    super.key,
    required this.userProvider,
    required this.coins,
    required this.duration,
  });

  final UserProvider userProvider;
  final int coins;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 24,
      top: 24,
      child: Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            userProvider.name.value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              SizedBox(
                height: 24,
                child: Image.asset("assets/images/coin.png"),
              ),
              Text(
                "$coins",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow,
                ),
              ),
            ],
          ),
          Text(
            "${duration.inSeconds} s",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class Trees extends StatelessWidget {
  Trees({super.key, required this.animationSpeed, required this.isPaused});
  final Duration animationSpeed;
  final bool isPaused;
  final Tween<double> movingTrees = Tween(begin: 0, end: -Get.width);

  @override
  Widget build(BuildContext context) {
    return RepeatingAnimationBuilder(
      paused: isPaused,
      animatable: movingTrees,
      duration: 3.seconds,
      builder: (context, value, child) {
        return Stack(
          children: [
            Positioned(
              bottom: 0,
              left: value + Get.width,
              child: Image.asset("assets/images/trees.png", scale: 2),
            ),
            Positioned(
              bottom: 0,
              left: value - Get.width,
              child: Image.asset("assets/images/trees.png", scale: 2),
            ),
            Positioned(
              bottom: 0,
              left: value,
              child: Image.asset("assets/images/trees.png", scale: 2),
            ),
          ],
        );
      },
    );
  }
}
