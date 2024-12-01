import 'package:hive_flutter/hive_flutter.dart';

part 'setting.g.dart';

@HiveType(typeId: 2)
class Setting extends HiveObject {
  @HiveField(0)
  bool isdarktheme = false;

  @HiveField(1)
  bool shoudspeak = false;

  Setting({
    required this.isdarktheme,
    required this.shoudspeak,
  });
}
