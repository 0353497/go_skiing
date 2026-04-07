import 'dart:convert';

import 'package:get/get.dart';
import 'package:go_skiing/models/ranking.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreProvider extends GetxController {
  static const String _storageKey = 'rankings';

  final RxList<Ranking> rankings = <Ranking>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadRankings();
  }

  List<Ranking> get sortedRankings {
    final rankingList = rankings.toList();
    rankingList.sort(
      (a, b) => a.duration.inMilliseconds.compareTo(b.duration.inMilliseconds),
    );
    return rankingList.reversed.toList();
  }

  Future<void> addRanking(Ranking ranking) async {
    rankings.add(ranking);
    rankings.sort(
      (a, b) => a.duration.inMilliseconds.compareTo(b.duration.inMilliseconds),
    );
    await _saveRankings();
  }

  Future<void> loadRankings() async {
    final preferences = await SharedPreferences.getInstance();
    final storedRankings = preferences.getStringList(_storageKey) ?? <String>[];

    final loadedRankings = storedRankings
        .map(
          (ranking) =>
              Ranking.fromJson(jsonDecode(ranking) as Map<String, dynamic>),
        )
        .toList();

    loadedRankings.sort(
      (a, b) => a.duration.inMilliseconds.compareTo(b.duration.inMilliseconds),
    );
    rankings.assignAll(loadedRankings);
  }

  Future<void> _saveRankings() async {
    final preferences = await SharedPreferences.getInstance();
    final rankingStrings = rankings
        .map((ranking) => jsonEncode(ranking.toJson()))
        .toList();
    await preferences.setStringList(_storageKey, rankingStrings);
  }
}
