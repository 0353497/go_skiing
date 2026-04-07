import 'package:flutter/material.dart';
import 'package:go_skiing/providers/user_provider.dart';

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
