import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_skiing/pages/game_page.dart';
import 'package:go_skiing/pages/rankings_page.dart';
import 'package:go_skiing/pages/settings_page.dart';
import 'package:go_skiing/providers/user_provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final UserProvider provider = Get.find<UserProvider>();
  final TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/bg.jpg", fit: BoxFit.cover),
          ),
          Positioned.fill(child: Container(color: Colors.white60)),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 24,
                children: [
                  Text(
                    "Go Skiing",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Player name",
                    ),
                  ),
                  SizedBox(
                    width: Get.width * .35,
                    height: 60,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder()),
                        backgroundColor: WidgetStatePropertyAll(
                          Color(0xff9dd4fa),
                        ),
                        foregroundColor: WidgetStatePropertyAll(Colors.black),
                      ),
                      onPressed: () {
                        if (nameController.value.text.isEmpty) {
                          Get.dialog(Dialog(child: Text("Invalid")));
                        } else {
                          provider.name.value = nameController.value.text;
                          Get.to(() => GamePage());
                        }
                      },
                      child: Text("Start Game"),
                    ),
                  ),
                  SizedBox(
                    width: Get.width * .35,
                    height: 60,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder()),
                        backgroundColor: WidgetStatePropertyAll(
                          Color(0xff9dd4fa),
                        ),
                        foregroundColor: WidgetStatePropertyAll(Colors.black),
                      ),
                      onPressed: () => Get.to(() => RankingsPage()),
                      child: Text("Rankings"),
                    ),
                  ),
                  SizedBox(
                    width: Get.width * .35,
                    height: 60,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder()),
                        backgroundColor: WidgetStatePropertyAll(
                          Color(0xff9dd4fa),
                        ),
                        foregroundColor: WidgetStatePropertyAll(Colors.black),
                      ),
                      onPressed: () => Get.to(() => SettingsPage()),
                      child: Text("Setting"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
