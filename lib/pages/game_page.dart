import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
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
  final userProvider = Get.find<UserProvider>();
  Rect playerRect = Rect.fromLTWH(Get.width * .3, Get.height - 180, 100, 100);
  double angle = .2;
  bool isPaused = false;
  int coins = 10;
  Duration duration = Duration.zero;
  AudioPlayer backgroundPlayer = AudioPlayer();
  AudioPlayer jumpPlayer = AudioPlayer();
  AudioPlayer gameOverPlayer = AudioPlayer();
  AudioPlayer coinPlayer = AudioPlayer();
  late Ticker _ticker;
  late final StreamSubscription gyroStream;

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
        onTap: () => jump(),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset("assets/images/bg.jpg", fit: BoxFit.cover),
            ),
            Trees(animationSpeed: 3.seconds, isPaused: isPaused),
            Positioned(
              top: 24,
              left: 24,
              child: IconButton(
                onPressed: () {},
                icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
              ),
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
                      colors: [
                        userProvider.color.value,
                        userProvider.color.value,
                      ],
                    ).createShader(bounds);
                  },
                  child: Image.asset("assets/images/skiing_person.png"),
                ),
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
    duration = dur;
    setState(() {});
  }

  void jump() async {
    setState(() {
      playerRect = playerRect.shift(Offset(0, -Get.width * .5));
    });
    await Future.delayed(1.seconds);
    if (mounted) {
      setState(() {
        playerRect = Rect.fromLTWH(Get.width * .3, Get.height - 180, 100, 100);
      });
    }
  }

  void _changeAngle(GyroscopeEvent event) {
    double newAgle = (.2 + event.y * .2).abs();
    if (!angle.isNegative) {
      angle = newAgle;
    }
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
