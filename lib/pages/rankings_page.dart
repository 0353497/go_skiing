import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_skiing/models/ranking.dart';
import 'package:go_skiing/pages/homepage.dart';
import 'package:go_skiing/providers/score_provider.dart';

class RankingsPage extends StatefulWidget {
  const RankingsPage({super.key, this.highlightedRanking});

  final Ranking? highlightedRanking;

  @override
  State<RankingsPage> createState() => _RankingsPageState();
}

class _RankingsPageState extends State<RankingsPage> {
  final ScoreProvider scoreProvider = Get.find<ScoreProvider>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rankings = scoreProvider.sortedRankings;

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
              if (rankings.isEmpty)
                Expanded(child: Center(child: Text("No Ranking"))),
              if (rankings.isNotEmpty)
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
                          itemCount: rankings.length,
                          itemBuilder: (context, index) {
                            final ranking = rankings[index];
                            final isHighlighted = _isHighlighted(ranking);

                            return Container(
                              decoration: BoxDecoration(
                                color: isHighlighted
                                    ? Colors.amber.withValues(alpha: 0.25)
                                    : null,
                                border: Border(
                                  bottom: BorderSide(
                                    width: 1,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 4,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    "${index + 1}",
                                    style: TextStyle(
                                      fontWeight: isHighlighted
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  Text(
                                    ranking.playerName,
                                    style: TextStyle(
                                      fontWeight: isHighlighted
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  Text(
                                    "${ranking.coin}",
                                    style: TextStyle(
                                      fontWeight: isHighlighted
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  Text(
                                    "${ranking.duration.inSeconds} s",
                                    style: TextStyle(
                                      fontWeight: isHighlighted
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
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
    });
  }

  bool _isHighlighted(Ranking ranking) {
    final highlighted = widget.highlightedRanking;
    if (highlighted == null) return false;

    return identical(highlighted, ranking) ||
        (highlighted.playerName == ranking.playerName &&
            highlighted.coin == ranking.coin &&
            highlighted.duration == ranking.duration);
  }
}
