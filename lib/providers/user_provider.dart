import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserProvider extends GetxController {
  final RxString name = "".obs;
  final Rx<Color> color = Colors.blue.obs;
}
