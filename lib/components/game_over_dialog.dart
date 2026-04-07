import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_skiing/models/ranking.dart';
import 'package:go_skiing/pages/rankings_page.dart';
import 'package:go_skiing/providers/user_provider.dart';

class GameOverDialog extends StatelessWidget {
  const GameOverDialog({
    super.key,
    required this.userProvider,
    required this.coins,
    required this.duration,
    required this.latestRanking,
    required this.onReset,
  });
  final VoidCallback onReset;

  final UserProvider userProvider;
  final int coins;
  final Duration duration;
  final Ranking latestRanking;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: Get.width * .8,
        height: Get.height * .3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "Game Over",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              Text(
                "Player name: ${userProvider.name.value}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
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
                "Time: ${duration.inSeconds} s",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Row(
                spacing: 24,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: onReset,
                    child: Text(
                      "Restart",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Get.to(
                      () => RankingsPage(highlightedRanking: latestRanking),
                    ),
                    child: Text(
                      "Go To Rankings",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
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
