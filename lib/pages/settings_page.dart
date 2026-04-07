import 'package:flutter/material.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/route_manager.dart';
import 'package:go_skiing/providers/user_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int selectedValue = 0;
  final List<Color> colors = [Colors.blue, Colors.red, Colors.green];
  final provider = Get.find<UserProvider>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 32,
        children: [
          SizedBox(
            width: Get.width * .7,
            child: ShaderMask(
              shaderCallback: (Rect bounds) {
                return LinearGradient(
                  colors: [colors[selectedValue], colors[selectedValue]],
                ).createShader(bounds);
              },
              child: Image.asset("assets/images/skiing_person.png"),
            ),
          ),
          Slider(
            min: 0,
            divisions: colors.length - 1,
            max: 2,
            value: selectedValue.toDouble(),
            onChanged: (value) {
              setState(() {
                selectedValue = value.toInt();
              });
              provider.color.value = colors[selectedValue];
            },
          ),
          SizedBox(
            width: Get.width * .35,
            height: 60,
            child: ElevatedButton(
              style: ButtonStyle(
                shape: WidgetStatePropertyAll(RoundedRectangleBorder()),
                backgroundColor: WidgetStatePropertyAll(Color(0xff9dd4fa)),
                foregroundColor: WidgetStatePropertyAll(Colors.black),
              ),
              onPressed: () => Get.back(),
              child: Text("Done"),
            ),
          ),
        ],
      ),
    );
  }
}
