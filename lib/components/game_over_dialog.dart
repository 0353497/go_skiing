import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_skiing/pages/rankings_page.dart';
import 'package:go_skiing/providers/user_provider.dart';

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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
              Text("Time: ${duration.inSeconds} s"),
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
