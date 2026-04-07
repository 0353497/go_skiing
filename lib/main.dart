import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/instance_manager.dart';
import 'package:go_skiing/pages/homepage.dart';
import 'package:go_skiing/providers/user_provider.dart';

void main() {
  runApp(const MainApp());
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  Get.put<UserProvider>(UserProvider());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(home: Homepage());
  }
}
