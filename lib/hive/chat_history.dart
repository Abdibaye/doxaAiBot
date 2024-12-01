import 'package:hive_flutter/adapters.dart';

part 'chat_history.g.dart';

@HiveType(typeId: 0)
class ChatHistory extends HiveObject {
  @HiveField(0)
  final String chatid;

  @HiveField(1)
  final String promt;

  @HiveField(2)
  final String response;

  @HiveField(3)
  final List<String> imageUrl;

  @HiveField(4)
  final DateTime timestamp;

  // constructor
  ChatHistory({
    required this.chatid,
    required this.promt,
    required this.response,
    required this.imageUrl,
    required this.timestamp,
  });
}
