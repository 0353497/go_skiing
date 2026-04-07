import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/route_manager.dart';
import 'package:go_skiing/pages/homepage.dart';
import 'package:go_skiing/providers/score_provider.dart';

class RankingsPage extends StatefulWidget {
  const RankingsPage({super.key});

  @override
  State<RankingsPage> createState() => _RankingsPageState();
}

class _RankingsPageState extends State<RankingsPage> {
  final ScoreProvider scoreProvider = Get.find<ScoreProvider>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => Get.to(() => Homepage()),
                  child: Text("back"),
                ),
              ],
            ),
            Text(
              "Rankings",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            if (scoreProvider.rankings.isEmpty)
              Expanded(child: Center(child: Text("No Ranking"))),
            if (scoreProvider.rankings.isNotEmpty)
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "ranking",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "player name",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Coin",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Duration",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: scoreProvider.rankings.length,
                        itemBuilder: (context, index) {
                          scoreProvider.rankings.sort(
                            (a, b) => (a.duration.inMilliseconds.compareTo(
                              b.duration.inMilliseconds,
                            )),
                          );
                          return Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 1,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text("${index + 1}"),
                                Text(scoreProvider.rankings[index].playerName),
                                Text("${scoreProvider.rankings[index].coin}"),
                                Text(
                                  "${scoreProvider.rankings[index].duration.inSeconds} s",
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
