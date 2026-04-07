import 'package:get/get.dart';
import 'package:go_skiing/models/ranking.dart';

class ScoreProvider extends GetxController {
  final RxList<Ranking> rankings = <Ranking>[].obs;
}
