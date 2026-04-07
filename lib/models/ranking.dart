class Ranking {
  final String playerName;
  final int coin;
  final Duration duration;

  Ranking({
    required this.playerName,
    required this.coin,
    required this.duration,
  });

  factory Ranking.fromJson(Map<String, dynamic> json) {
    return Ranking(
      playerName: json["playerName"] ?? json["playername"] ?? "",
      coin: (json["coin"] as num).toInt(),
      duration: Duration(milliseconds: (json["duration"] as num).toInt()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "playerName": playerName,
      "coin": coin,
      "duration": duration.inMilliseconds,
    };
  }
}
