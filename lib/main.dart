import 'package:doxabot/hive/boxes.dart';
import 'package:doxabot/hive/chat_history.dart';
import 'package:doxabot/hive/setting.dart';
import 'package:doxabot/hive/user_model.dart';
import 'package:doxabot/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

void main() async {
  chatHistorybox = await Hive.box<ChatHistory>("chat_history_box");
  userbox = await Hive.box<UserMOdel>("user_box");
  settingbox = await Hive.box<Setting>("settings_box");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
